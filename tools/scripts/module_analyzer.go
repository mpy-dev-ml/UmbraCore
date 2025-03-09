package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

// ModuleInfo represents basic information about a Swift module
type ModuleInfo struct {
	Name       string   `json:"name"`
	Path       string   `json:"path"`
	Files      []string `json:"files"`
	BuildFiles []string `json:"build_files"`
	Score      float64  `json:"health_score"`
	Issues     []string `json:"detected_issues"`
}

func main() {
	rootPath := flag.String("path", ".", "Path to Swift codebase root")
	outputPath := flag.String("output", "module_health.json", "Path for JSON output")
	flag.Parse()

	fmt.Printf("Analyzing Swift codebase at: %s\n", *rootPath)
	
	// 1. Find the Sources directory
	sourcesPath := filepath.Join(*rootPath, "Sources")
	if _, err := os.Stat(sourcesPath); os.IsNotExist(err) {
		fmt.Printf("Sources directory not found at %s\n", sourcesPath)
		return
	}
	
	// 2. Get all immediate subdirectories of Sources - these are likely modules
	modules, err := getModuleDirs(sourcesPath)
	if err != nil {
		fmt.Printf("Error scanning modules: %v\n", err)
		return
	}
	
	fmt.Printf("Found %d potential modules\n", len(modules))
	
	// 3. Analyze each module
	moduleInfos := analyzeModules(modules)
	
	// 4. Output results
	writeResults(moduleInfos, *outputPath)
	
	// 5. Display top issues
	fmt.Printf("\nTop modules with issues:\n")
	for i, info := range moduleInfos {
		if i >= 5 {
			break
		}
		fmt.Printf("%d. %s (Score: %.2f)\n", i+1, info.Name, info.Score)
		for j, issue := range info.Issues {
			if j >= 3 {
				fmt.Printf("   ...and %d more issues\n", len(info.Issues)-3)
				break
			}
			fmt.Printf("   - %s\n", issue)
		}
	}
}

// getModuleDirs returns all immediate subdirectories of the given path
func getModuleDirs(path string) ([]string, error) {
	var modules []string
	
	entries, err := ioutil.ReadDir(path)
	if err != nil {
		return nil, err
	}
	
	for _, entry := range entries {
		if entry.IsDir() {
			modules = append(modules, filepath.Join(path, entry.Name()))
		}
	}
	
	return modules, nil
}

// analyzeModules examines each module directory and returns information
func analyzeModules(modulePaths []string) []*ModuleInfo {
	var moduleInfos []*ModuleInfo
	
	for _, modulePath := range modulePaths {
		moduleName := filepath.Base(modulePath)
		fmt.Printf("Analyzing module: %s\n", moduleName)
		
		info := &ModuleInfo{
			Name:   moduleName,
			Path:   modulePath,
			Files:  []string{},
			Issues: []string{},
		}
		
		// Find Swift files
		swiftFiles, err := findFiles(modulePath, ".swift")
		if err != nil {
			fmt.Printf("Error finding Swift files: %v\n", err)
			continue
		}
		info.Files = swiftFiles
		
		// Find BUILD files
		buildFiles, err := findFiles(modulePath, "BUILD.bazel")
		if err != nil {
			fmt.Printf("Error finding build files: %v\n", err)
		}
		info.BuildFiles = buildFiles
		
		// Basic checks
		runBasicChecks(info)
		
		// Calculate score (0-10, lower is better)
		calculateScore(info)
		
		moduleInfos = append(moduleInfos, info)
	}
	
	// Sort by score (descending - higher scores mean more issues)
	for i := 0; i < len(moduleInfos)-1; i++ {
		for j := i + 1; j < len(moduleInfos); j++ {
			if moduleInfos[i].Score < moduleInfos[j].Score {
				moduleInfos[i], moduleInfos[j] = moduleInfos[j], moduleInfos[i]
			}
		}
	}
	
	return moduleInfos
}

// findFiles finds all files with the given extension in the directory (recursively)
func findFiles(dir, ext string) ([]string, error) {
	var files []string
	
	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		// Skip hidden directories
		if info.IsDir() && strings.HasPrefix(info.Name(), ".") {
			return filepath.SkipDir
		}
		
		// For BUILD files, check exact name match
		if ext == "BUILD.bazel" && info.Name() == "BUILD.bazel" {
			files = append(files, path)
		} else if strings.HasSuffix(path, ext) {
			// For other extensions like .swift
			files = append(files, path)
		}
		
		return nil
	})
	
	return files, err
}

// runBasicChecks performs simple analysis on the module
func runBasicChecks(info *ModuleInfo) {
	// Check 1: No build file
	if len(info.BuildFiles) == 0 {
		info.Issues = append(info.Issues, "No BUILD.bazel file found")
	}
	
	// Check 2: Few Swift files
	if len(info.Files) < 3 {
		info.Issues = append(info.Issues, "Very few Swift files (<3)")
	}
	
	// Check 3: Look for isolation files
	hasIsolationFile := false
	for _, file := range info.Files {
		filename := filepath.Base(file)
		if strings.Contains(filename, "Isolation") {
			hasIsolationFile = true
			info.Issues = append(info.Issues, "Uses isolation pattern")
			break
		}
	}
	
	// If we found isolation files, add a high-priority issue
	if hasIsolationFile {
		info.Issues = append(info.Issues, "Module using isolation pattern requires refactoring")
	}
	
	// Check 4: Look for proper namespacing with Extensions.swift files
	hasExtensionFile := false
	for _, file := range info.Files {
		filename := filepath.Base(file)
		if strings.HasSuffix(filename, "Extensions.swift") {
			hasExtensionFile = true
			break
		}
	}
	
	if !hasExtensionFile {
		info.Issues = append(info.Issues, "No Extensions file for namespacing")
	}
	
	// Examine file contents for specific patterns
	for _, file := range info.Files {
		// Only check a limited number of files to avoid performance issues
		if len(file) > 5 {
			break
		}
		
		data, err := ioutil.ReadFile(file)
		if err != nil {
			continue
		}
		
		content := string(data)
		
		// Check for typealias usage
		if strings.Contains(content, "typealias") {
			info.Issues = append(info.Issues, "Uses typealias potentially for namespace workarounds")
			break
		}
	}
}

// calculateScore computes an overall health score
func calculateScore(info *ModuleInfo) {
	baseScore := 5.0
	
	// Add points for each issue (higher score is worse)
	issueScore := float64(len(info.Issues)) * 1.0
	
	// Add points for isolation pattern
	for _, issue := range info.Issues {
		if strings.Contains(issue, "isolation") {
			issueScore += 2.0
			break
		}
	}
	
	// Final score (capped at 10)
	info.Score = baseScore + issueScore
	if info.Score > 10.0 {
		info.Score = 10.0
	}
}

// writeResults outputs the module information as JSON
func writeResults(infos []*ModuleInfo, outputPath string) {
	output, err := json.MarshalIndent(infos, "", "  ")
	if err != nil {
		fmt.Printf("Error marshaling JSON: %v\n", err)
		return
	}
	
	err = ioutil.WriteFile(outputPath, output, 0644)
	if err != nil {
		fmt.Printf("Error writing output file: %v\n", err)
	} else {
		fmt.Printf("Results written to %s\n", outputPath)
	}
}
