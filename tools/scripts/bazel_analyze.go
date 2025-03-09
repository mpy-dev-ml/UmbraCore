package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Config defines program configuration parameters
type Config struct {
	TargetModule string // Module to analyse (e.g., "CoreTypes")
	OutputDir    string // Directory for output files
	ProjectRoot  string // Root of the Bazel project
}

// ModuleDependency represents a dependency relationship
type ModuleDependency struct {
	SourceModule string   `json:"source_module"`
	TargetModule string   `json:"target_module"`
	Dependencies []string `json:"dependencies"`
	ReverseDepBy []string `json:"reverse_dependencies"` 
}

// BazelAnalysisReport contains all the analysis results
type BazelAnalysisReport struct {
	TargetModule      string            `json:"target_module"`
	DirectDeps        []string          `json:"direct_dependencies"`
	TransitiveDeps    []string          `json:"transitive_dependencies"`
	ReverseDeps       []string          `json:"reverse_dependencies"`
	CircularDeps      []string          `json:"circular_dependencies"`
	DependencyDetails []ModuleDependency `json:"dependency_details"`
}

func main() {
	// Parse command-line flags
	targetModule := flag.String("module", "CoreTypes", "Target module to analyse")
	outputDir := flag.String("output", "bazel_analysis", "Output directory for reports")
	projectRoot := flag.String("root", ".", "Root directory of the Bazel project")
	flag.Parse()

	config := Config{
		TargetModule: *targetModule,
		OutputDir:    *outputDir,
		ProjectRoot:  *projectRoot,
	}

	// Create output directory if it doesn't exist
	if err := os.MkdirAll(config.OutputDir, 0755); err != nil {
		fmt.Printf("Error creating output directory: %v\n", err)
		return
	}

	// Run the analysis
	report, err := analyzeBazelDependencies(config)
	if err != nil {
		fmt.Printf("Error during analysis: %v\n", err)
		return
	}

	// Write report to file
	writeReport(report, config)
}

func analyzeBazelDependencies(config Config) (*BazelAnalysisReport, error) {
	report := &BazelAnalysisReport{
		TargetModule: config.TargetModule,
	}

	// Define the target in Bazel format
	target := fmt.Sprintf("//Sources/%s:%s", config.TargetModule, config.TargetModule)
	
	// Get direct dependencies
	directDeps, err := runBazelQuery(fmt.Sprintf("deps(%s, 1)", target), config)
	if err != nil {
		return nil, fmt.Errorf("error getting direct dependencies: %w", err)
	}
	report.DirectDeps = filterBazelTargets(directDeps)

	// Get all transitive dependencies
	allDeps, err := runBazelQuery(fmt.Sprintf("deps(%s)", target), config)
	if err != nil {
		return nil, fmt.Errorf("error getting all dependencies: %w", err)
	}
	report.TransitiveDeps = filterBazelTargets(allDeps)

	// Get reverse dependencies (modules that depend on the target)
	reverseDeps, err := runBazelQuery(fmt.Sprintf("rdeps(//..., %s)", target), config)
	if err != nil {
		return nil, fmt.Errorf("error getting reverse dependencies: %w", err)
	}
	report.ReverseDeps = filterBazelTargets(reverseDeps)

	// Check for circular dependencies
	circularDeps, err := runBazelQuery(fmt.Sprintf("allpaths(%s, %s)", target, target), config)
	if err == nil && len(circularDeps) > 0 {
		report.CircularDeps = circularDeps
	}

	// For each direct dependency, get its dependencies too
	var depDetails []ModuleDependency
	for _, dep := range report.DirectDeps {
		// Skip non-module dependencies
		if !strings.Contains(dep, "//Sources/") {
			continue
		}

		detail := ModuleDependency{
			SourceModule: config.TargetModule,
			TargetModule: extractModuleName(dep),
		}

		// Get the dependencies of this dependency
		depTarget := dep
		secondLevelDeps, err := runBazelQuery(fmt.Sprintf("deps(%s, 1)", depTarget), config)
		if err == nil {
			detail.Dependencies = filterBazelTargets(secondLevelDeps)
		}

		// Get what else depends on this dependency
		otherDeps, err := runBazelQuery(fmt.Sprintf("rdeps(//..., %s)", depTarget), config)
		if err == nil {
			detail.ReverseDepBy = filterBazelTargets(otherDeps)
		}

		depDetails = append(depDetails, detail)
	}

	report.DependencyDetails = depDetails

	return report, nil
}

func runBazelQuery(query string, config Config) ([]string, error) {
	cmd := exec.Command("bazel", "query", query, "--output=label")
	cmd.Dir = config.ProjectRoot

	output, err := cmd.Output()
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			return nil, fmt.Errorf("bazel query failed: %s\nstderr: %s", err, exitErr.Stderr)
		}
		return nil, err
	}

	// Split the output into lines
	lines := strings.Split(strings.TrimSpace(string(output)), "\n")
	return lines, nil
}

func filterBazelTargets(targets []string) []string {
	var filtered []string
	for _, target := range targets {
		if target == "" {
			continue
		}
		
		// Extract just the module name where possible
		if strings.Contains(target, "//Sources/") {
			moduleName := extractModuleName(target)
			if !contains(filtered, moduleName) {
				filtered = append(filtered, moduleName)
			}
		} else {
			// Keep the full target for external dependencies
			if !contains(filtered, target) {
				filtered = append(filtered, target)
			}
		}
	}
	return filtered
}

func extractModuleName(target string) string {
	// Handle formats like "//Sources/ModuleName:ModuleName"
	parts := strings.Split(target, ":")
	if len(parts) > 1 {
		return parts[1]
	}
	
	// Handle formats like "//Sources/ModuleName"
	parts = strings.Split(target, "/")
	if len(parts) > 2 {
		return parts[len(parts)-1]
	}
	
	return target
}

func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

func writeReport(report *BazelAnalysisReport, config Config) {
	// Write JSON report
	jsonFile := filepath.Join(config.OutputDir, fmt.Sprintf("%s_dependencies.json", report.TargetModule))
	jsonData, err := json.MarshalIndent(report, "", "  ")
	if err != nil {
		fmt.Printf("Error marshaling report to JSON: %v\n", err)
		return
	}
	
	if err := os.WriteFile(jsonFile, jsonData, 0644); err != nil {
		fmt.Printf("Error writing JSON report: %v\n", err)
		return
	}
	
	// Write Markdown summary
	mdFile := filepath.Join(config.OutputDir, fmt.Sprintf("%s_dependencies.md", report.TargetModule))
	var md strings.Builder
	
	md.WriteString(fmt.Sprintf("# Bazel Dependency Analysis: %s\n\n", report.TargetModule))
	md.WriteString(fmt.Sprintf("Generated: %s\n\n", formatDate()))
	
	md.WriteString("## Direct Dependencies\n\n")
	for _, dep := range report.DirectDeps {
		md.WriteString(fmt.Sprintf("- %s\n", dep))
	}
	
	md.WriteString("\n## Modules That Depend On This Module\n\n")
	for _, dep := range report.ReverseDeps {
		md.WriteString(fmt.Sprintf("- %s\n", dep))
	}
	
	if len(report.CircularDeps) > 0 {
		md.WriteString("\n## ⚠️ Circular Dependencies Detected\n\n")
		for _, dep := range report.CircularDeps {
			md.WriteString(fmt.Sprintf("- %s\n", dep))
		}
	}
	
	md.WriteString("\n## Dependency Analysis\n\n")
	md.WriteString("| Module | # of Dependencies | # of Dependents |\n")
	md.WriteString("|--------|-------------------|----------------|\n")
	
	for _, detail := range report.DependencyDetails {
		md.WriteString(fmt.Sprintf("| %s | %d | %d |\n", 
			detail.TargetModule, 
			len(detail.Dependencies),
			len(detail.ReverseDepBy)))
	}
	
	md.WriteString("\n## Refactoring Recommendations\n\n")
	
	// Add recommendations based on analysis
	if len(report.CircularDeps) > 0 {
		md.WriteString("- **High Priority**: Resolve circular dependencies\n")
	}
	
	if len(report.DirectDeps) > 7 {
		md.WriteString("- **Medium Priority**: Consider breaking down module with many direct dependencies\n")
	}
	
	if len(report.ReverseDeps) > 10 {
		md.WriteString("- **High Priority**: This module is heavily depended upon - changes should be made carefully\n")
	}
	
	if err := os.WriteFile(mdFile, []byte(md.String()), 0644); err != nil {
		fmt.Printf("Error writing Markdown report: %v\n", err)
		return
	}
	
	fmt.Printf("Analysis complete. Reports written to:\n")
	fmt.Printf("- JSON: %s\n", jsonFile)
	fmt.Printf("- Markdown: %s\n", mdFile)
}

func formatDate() string {
	return fmt.Sprintf("%s", strings.Split(strings.Split(strings.TrimSpace(
		runCommand("date", "+%Y-%m-%d %H:%M:%S")), "\n")[0], " output:")[0])
}

func runCommand(command string, args ...string) string {
	cmd := exec.Command(command, args...)
	output, _ := cmd.CombinedOutput()
	return string(output)
}
