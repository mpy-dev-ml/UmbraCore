package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

// Configuration holds the program settings
type Config struct {
	SourceDir        string   // Root source directory to scan
	OutputDir        string   // Output directory for reports
	ModulesToAnalyze []string // Specific modules to analyse (empty = all)
	VerboseOutput    bool     // Whether to print verbose output
}

// SwiftFileInfo contains analysis data for a Swift file
type SwiftFileInfo struct {
	FilePath      string            `json:"file_path"`
	ModuleName    string            `json:"module_name"`
	IsIsolation   bool              `json:"is_isolation_file"`
	Imports       []string          `json:"imports"`
	TypeAliases   map[string]string `json:"type_aliases"`
	ErrorMapFuncs []string          `json:"error_mapping_functions"`
}

// ModuleAnalysis contains the analysis results for a module
type ModuleAnalysis struct {
	ModuleName         string          `json:"module_name"`
	SwiftFiles         []SwiftFileInfo `json:"swift_files"`
	IsolationFiles     []string        `json:"isolation_files"`
	TotalTypeAliases   int             `json:"total_type_aliases"`
	TotalErrorMapFuncs int             `json:"total_error_mapping_functions"`
	ImportsByModule    map[string]int  `json:"imports_by_module"`
}

// AnalysisReport contains the overall report
type AnalysisReport struct {
	TotalModules       int                      `json:"total_modules"`
	TotalSwiftFiles    int                      `json:"total_swift_files"`
	TotalIsolationFiles int                     `json:"total_isolation_files"`
	TotalTypeAliases   int                      `json:"total_type_aliases"`
	ModuleAnalysis     map[string]ModuleAnalysis `json:"module_analysis"`
	TopIsolationModules []string                `json:"top_isolation_modules"`
	IsolationPatterns  []string                 `json:"isolation_patterns"`
}

// Regular expressions for Swift code analysis
var (
	importRegex       = regexp.MustCompile(`import\s+([A-Za-z0-9_]+)`)
	typeAliasRegex    = regexp.MustCompile(`typealias\s+([A-Za-z0-9_]+)\s*=\s*([A-Za-z0-9_\.]+)`)
	errorMapFuncRegex = regexp.MustCompile(`func\s+map([A-Za-z0-9_]+)To([A-Za-z0-9_]+)Error`)
)

func main() {
	// Parse command line flags
	sourceDir := flag.String("source", "./Sources", "Source directory to scan")
	outputDir := flag.String("output", "refactoring_plan/swift_analysis", "Output directory for reports")
	moduleList := flag.String("modules", "", "Comma-separated list of modules to analyse (empty = all)")
	verbose := flag.Bool("verbose", false, "Print verbose output")
	flag.Parse()

	// Create config object
	config := Config{
		SourceDir:     *sourceDir,
		OutputDir:     *outputDir,
		VerboseOutput: *verbose,
	}

	// Process module list if provided
	if *moduleList != "" {
		config.ModulesToAnalyze = strings.Split(*moduleList, ",")
	}

	// Create output directory
	if err := os.MkdirAll(config.OutputDir, 0755); err != nil {
		fmt.Printf("Error creating output directory: %v\n", err)
		os.Exit(1)
	}

	// Run the analysis
	report, err := analyzeSwiftCode(config)
	if err != nil {
		fmt.Printf("Error analyzing Swift code: %v\n", err)
		os.Exit(1)
	}

	// Write the reports
	if err := writeReports(report, config); err != nil {
		fmt.Printf("Error writing reports: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Swift code analysis complete.")
}

func analyzeSwiftCode(config Config) (*AnalysisReport, error) {
	report := &AnalysisReport{
		ModuleAnalysis: make(map[string]ModuleAnalysis),
	}

	// Get all modules in the source directory
	modules, err := getModules(config.SourceDir)
	if err != nil {
		return nil, fmt.Errorf("error getting modules: %w", err)
	}

	// Filter modules if specified
	if len(config.ModulesToAnalyze) > 0 {
		filteredModules := []string{}
		for _, module := range modules {
			for _, targetModule := range config.ModulesToAnalyze {
				if module == targetModule {
					filteredModules = append(filteredModules, module)
					break
				}
			}
		}
		modules = filteredModules
	}

	if config.VerboseOutput {
		fmt.Printf("Analyzing %d modules: %v\n", len(modules), modules)
	}

	// Analyze each module
	totalSwiftFiles := 0
	totalIsolationFiles := 0
	totalTypeAliases := 0

	for _, module := range modules {
		if config.VerboseOutput {
			fmt.Printf("Analyzing module: %s\n", module)
		}

		moduleAnalysis, err := analyzeModule(filepath.Join(config.SourceDir, module), module, config)
		if err != nil {
			return nil, fmt.Errorf("error analyzing module %s: %w", module, err)
		}

		report.ModuleAnalysis[module] = moduleAnalysis
		totalSwiftFiles += len(moduleAnalysis.SwiftFiles)
		totalIsolationFiles += len(moduleAnalysis.IsolationFiles)
		totalTypeAliases += moduleAnalysis.TotalTypeAliases
	}

	// Set report totals
	report.TotalModules = len(modules)
	report.TotalSwiftFiles = totalSwiftFiles
	report.TotalIsolationFiles = totalIsolationFiles
	report.TotalTypeAliases = totalTypeAliases

	// Find the modules with the most isolation files
	type moduleIsolationCount struct {
		module string
		count  int
	}
	var moduleIsolationCounts []moduleIsolationCount
	for module, analysis := range report.ModuleAnalysis {
		if len(analysis.IsolationFiles) > 0 {
			moduleIsolationCounts = append(moduleIsolationCounts, moduleIsolationCount{
				module: module,
				count:  len(analysis.IsolationFiles),
			})
		}
	}

	// Sort by isolation file count
	// Note: Simple insertion sort for small number of modules
	for i := 0; i < len(moduleIsolationCounts); i++ {
		for j := i + 1; j < len(moduleIsolationCounts); j++ {
			if moduleIsolationCounts[j].count > moduleIsolationCounts[i].count {
				moduleIsolationCounts[i], moduleIsolationCounts[j] = moduleIsolationCounts[j], moduleIsolationCounts[i]
			}
		}
	}

	// Add top isolation modules to report
	maxLen := min(5, len(moduleIsolationCounts))
	for i := 0; i < maxLen; i++ {
		report.TopIsolationModules = append(report.TopIsolationModules, 
			fmt.Sprintf("%s (%d isolation files)", moduleIsolationCounts[i].module, moduleIsolationCounts[i].count))
	}

	// Extract common isolation patterns
	report.IsolationPatterns = extractIsolationPatterns(report)

	return report, nil
}

func analyzeModule(modulePath, moduleName string, config Config) (ModuleAnalysis, error) {
	analysis := ModuleAnalysis{
		ModuleName:      moduleName,
		IsolationFiles:  []string{},
		ImportsByModule: make(map[string]int),
	}

	// Get all Swift files in the module
	swiftFiles, err := findSwiftFiles(modulePath)
	if err != nil {
		return analysis, fmt.Errorf("error finding Swift files: %w", err)
	}

	// Analyze each Swift file
	for _, filePath := range swiftFiles {
		if config.VerboseOutput {
			fmt.Printf("  Analyzing file: %s\n", filepath.Base(filePath))
		}

		fileInfo, err := analyzeSwiftFile(filePath, moduleName)
		if err != nil {
			return analysis, fmt.Errorf("error analyzing file %s: %w", filePath, err)
		}

		analysis.SwiftFiles = append(analysis.SwiftFiles, fileInfo)

		// Track isolation files
		if fileInfo.IsIsolation {
			analysis.IsolationFiles = append(analysis.IsolationFiles, filepath.Base(filePath))
		}

		// Count imports by module
		for _, imp := range fileInfo.Imports {
			analysis.ImportsByModule[imp]++
		}

		// Count type aliases
		analysis.TotalTypeAliases += len(fileInfo.TypeAliases)

		// Count error mapping functions
		analysis.TotalErrorMapFuncs += len(fileInfo.ErrorMapFuncs)
	}

	return analysis, nil
}

func analyzeSwiftFile(filePath, moduleName string) (SwiftFileInfo, error) {
	fileInfo := SwiftFileInfo{
		FilePath:      filePath,
		ModuleName:    moduleName,
		IsIsolation:   strings.Contains(filepath.Base(filePath), "Isolation"),
		Imports:       []string{},
		TypeAliases:   make(map[string]string),
		ErrorMapFuncs: []string{},
	}

	// Open the file
	file, err := os.Open(filePath)
	if err != nil {
		return fileInfo, fmt.Errorf("error opening file: %w", err)
	}
	defer file.Close()

	// Scan the file line by line
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		
		// Check for imports
		importMatches := importRegex.FindStringSubmatch(line)
		if len(importMatches) > 1 {
			fileInfo.Imports = append(fileInfo.Imports, importMatches[1])
			continue
		}
		
		// Check for type aliases
		typeAliasMatches := typeAliasRegex.FindStringSubmatch(line)
		if len(typeAliasMatches) > 2 {
			fileInfo.TypeAliases[typeAliasMatches[1]] = typeAliasMatches[2]
			continue
		}
		
		// Check for error mapping functions
		errorMapMatches := errorMapFuncRegex.FindStringSubmatch(line)
		if len(errorMapMatches) > 2 {
			mappingFunc := fmt.Sprintf("map%sTo%sError", errorMapMatches[1], errorMapMatches[2])
			fileInfo.ErrorMapFuncs = append(fileInfo.ErrorMapFuncs, mappingFunc)
		}
	}

	if err := scanner.Err(); err != nil {
		return fileInfo, fmt.Errorf("error scanning file: %w", err)
	}

	return fileInfo, nil
}

func getModules(sourceDir string) ([]string, error) {
	// List the directories in the source directory
	entries, err := os.ReadDir(sourceDir)
	if err != nil {
		return nil, fmt.Errorf("error reading source directory: %w", err)
	}

	var modules []string
	for _, entry := range entries {
		if entry.IsDir() {
			modules = append(modules, entry.Name())
		}
	}

	return modules, nil
}

func findSwiftFiles(modulePath string) ([]string, error) {
	var swiftFiles []string

	err := filepath.Walk(modulePath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(info.Name(), ".swift") {
			swiftFiles = append(swiftFiles, path)
		}
		return nil
	})

	if err != nil {
		return nil, fmt.Errorf("error walking directory: %w", err)
	}

	return swiftFiles, nil
}

func extractIsolationPatterns(report *AnalysisReport) []string {
	// Collect all isolation file names to look for patterns
	isolationFiles := []string{}
	for _, moduleAnalysis := range report.ModuleAnalysis {
		isolationFiles = append(isolationFiles, moduleAnalysis.IsolationFiles...)
	}

	// Extract common patterns (simple implementation)
	patterns := []string{
		"Files with 'Isolation' in the name are used to manage namespace conflicts",
		"Type aliases are heavily used to redirect types from other modules",
		"Error mapping functions follow the pattern 'mapXXXToYYYError'",
	}

	return patterns
}

func writeReports(report *AnalysisReport, config Config) error {
	// Write JSON report
	jsonFile := filepath.Join(config.OutputDir, "swift_analysis_report.json")
	jsonData, err := json.MarshalIndent(report, "", "  ")
	if err != nil {
		return fmt.Errorf("error marshaling report to JSON: %w", err)
	}
	
	if err := os.WriteFile(jsonFile, jsonData, 0644); err != nil {
		return fmt.Errorf("error writing JSON report: %w", err)
	}
	
	// Write Markdown summary
	mdFile := filepath.Join(config.OutputDir, "swift_analysis_report.md")
	var md strings.Builder
	
	md.WriteString("# Swift Code Analysis Report\n\n")
	md.WriteString(fmt.Sprintf("Generated: %s\n\n", formatDate()))
	
	md.WriteString("## Summary\n\n")
	md.WriteString(fmt.Sprintf("- Total Modules Analyzed: %d\n", report.TotalModules))
	md.WriteString(fmt.Sprintf("- Total Swift Files: %d\n", report.TotalSwiftFiles))
	md.WriteString(fmt.Sprintf("- Total Isolation Files: %d\n", report.TotalIsolationFiles))
	md.WriteString(fmt.Sprintf("- Total Type Aliases: %d\n", report.TotalTypeAliases))
	
	md.WriteString("\n## Modules with Isolation Patterns\n\n")
	for _, module := range report.TopIsolationModules {
		md.WriteString(fmt.Sprintf("- %s\n", module))
	}
	
	md.WriteString("\n## Common Isolation Patterns\n\n")
	for _, pattern := range report.IsolationPatterns {
		md.WriteString(fmt.Sprintf("- %s\n", pattern))
	}
	
	md.WriteString("\n## Module Analysis\n\n")
	
	// List modules with most isolation files first
	type moduleWithIsolation struct {
		name  string
		count int
	}
	
	var modulesWithIsolation []moduleWithIsolation
	for name, analysis := range report.ModuleAnalysis {
		if len(analysis.IsolationFiles) > 0 {
			modulesWithIsolation = append(modulesWithIsolation, moduleWithIsolation{
				name:  name,
				count: len(analysis.IsolationFiles),
			})
		}
	}
	
	// Sort modules by isolation file count (descending)
	for i := 0; i < len(modulesWithIsolation); i++ {
		for j := i + 1; j < len(modulesWithIsolation); j++ {
			if modulesWithIsolation[j].count > modulesWithIsolation[i].count {
				modulesWithIsolation[i], modulesWithIsolation[j] = modulesWithIsolation[j], modulesWithIsolation[i]
			}
		}
	}
	
	// Write details for modules with isolation files
	for _, module := range modulesWithIsolation {
		analysis := report.ModuleAnalysis[module.name]
		
		md.WriteString(fmt.Sprintf("### %s\n\n", module.name))
		md.WriteString(fmt.Sprintf("- Isolation Files: %d\n", len(analysis.IsolationFiles)))
		md.WriteString(fmt.Sprintf("- Type Aliases: %d\n", analysis.TotalTypeAliases))
		md.WriteString(fmt.Sprintf("- Error Mapping Functions: %d\n", analysis.TotalErrorMapFuncs))
		
		if len(analysis.IsolationFiles) > 0 {
			md.WriteString("\nIsolation Files:\n")
			for _, file := range analysis.IsolationFiles {
				md.WriteString(fmt.Sprintf("- %s\n", file))
			}
		}
		
		if len(analysis.ImportsByModule) > 0 {
			md.WriteString("\nTop Imports:\n")
			count := 0
			for imp, num := range analysis.ImportsByModule {
				if count < 5 {
					md.WriteString(fmt.Sprintf("- %s (%d files)\n", imp, num))
					count++
				} else {
					break
				}
			}
		}
		
		md.WriteString("\n")
	}
	
	md.WriteString("\n## Refactoring Recommendations\n\n")
	
	// Add recommendations
	md.WriteString("1. **Create dedicated adapter modules** to replace isolation files\n")
	md.WriteString("2. **Eliminate type aliases** by using proper namespacing\n")
	md.WriteString("3. **Standardise error handling** across modules\n")
	md.WriteString("4. **Reduce circular dependencies** by proper architectural boundaries\n")
	
	if err := os.WriteFile(mdFile, []byte(md.String()), 0644); err != nil {
		return fmt.Errorf("error writing Markdown report: %w", err)
	}
	
	fmt.Printf("Analysis complete. Reports written to:\n")
	fmt.Printf("- JSON: %s\n", jsonFile)
	fmt.Printf("- Markdown: %s\n", mdFile)
	
	return nil
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

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
