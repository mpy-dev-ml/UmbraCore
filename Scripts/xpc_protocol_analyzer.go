package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"sync"
)

// Configuration for the analysis
type Config struct {
	RootDir          string   `json:"rootDir"`           // Root directory to start scanning
	ExcludeDirs      []string `json:"excludeDirs"`       // Directories to exclude from scanning
	LegacyImports    []string `json:"legacyImports"`     // Legacy import statements to look for
	LegacyProtocols  []string `json:"legacyProtocols"`   // Legacy protocol names to look for
	ModernImports    []string `json:"modernImports"`     // Modern import statements to look for
	ModernProtocols  []string `json:"modernProtocols"`   // Modern protocol names to look for
	OutputFile       string   `json:"outputFile"`        // Output file for the report
	IncludeModuleMap bool     `json:"includeModuleMap"`  // Whether to include module mapping in report
	MaxGoRoutines    int      `json:"maxGoRoutines"`     // Maximum number of goroutines to use
	VerboseOutput    bool     `json:"verboseOutput"`     // Whether to print verbose output
}

// Result of analyzing a file
type FileAnalysis struct {
	FilePath           string   `json:"filePath"`
	HasLegacyImports   bool     `json:"hasLegacyImports"`
	LegacyImports      []string `json:"legacyImports,omitempty"`
	HasLegacyProtocols bool     `json:"hasLegacyProtocols"`
	LegacyProtocols    []string `json:"legacyProtocols,omitempty"`
	HasModernImports   bool     `json:"hasModernImports"`
	ModernImports      []string `json:"modernImports,omitempty"`
	HasModernProtocols bool     `json:"hasModernProtocols"`
	ModernProtocols    []string `json:"modernProtocols,omitempty"`
	NeedsRefactoring   bool     `json:"needsRefactoring"`
	Module             string   `json:"module,omitempty"`
	Language           string   `json:"language,omitempty"`
}

// Summary of analysis results
type AnalysisReport struct {
	TotalFiles             int                    `json:"totalFiles"`
	FilesWithLegacyImports int                    `json:"filesWithLegacyImports"`
	FilesWithModernImports int                    `json:"filesWithModernImports"`
	FilesNeedingRefactoring int                   `json:"filesNeedingRefactoring"`
	ModulesToRefactor      []string               `json:"modulesToRefactor"`
	FileAnalyses           []*FileAnalysis        `json:"fileAnalyses"`
	ModuleMapping          map[string][]string    `json:"moduleMapping,omitempty"`
	BazelTargets           map[string][]string    `json:"bazelTargets,omitempty"`
}

var (
	defaultConfig = Config{
		RootDir: ".",
		ExcludeDirs: []string{
			".git", ".github", "bazel-*", "build", "Scripts",
		},
		LegacyImports: []string{
			"import SecurityInterfaces",
			"import SecurityInterfacesBase",
			"import SecurityInterfacesProtocols",
		},
		LegacyProtocols: []string{
			"XPCServiceProtocol",
			"XPCServiceProtocolDeprecated",
			"XPCCryptoServiceProtocol",
			"XPCSecurityServiceProtocol",
			"SecurityXPCProtocol",
		},
		ModernImports: []string{
			"import XPCProtocolsCore",
		},
		ModernProtocols: []string{
			"XPCServiceProtocolBasic",
			"XPCServiceProtocolStandard",
			"XPCServiceProtocolComplete",
		},
		OutputFile:       "xpc_protocol_analysis.json",
		IncludeModuleMap: true,
		MaxGoRoutines:    8,
		VerboseOutput:    false,
	}
)

// Regular expressions for identifying Bazel targets
var (
	bazelSwiftLibRe = regexp.MustCompile(`swift_library\(\s*name\s*=\s*"([^"]+)"`)
	bazelDepsRe     = regexp.MustCompile(`deps\s*=\s*\[\s*([^\]]+)\]`)
)

func main() {
	// Set up command line flags
	configFile := flag.String("config", "", "Path to configuration JSON file")
	outputFile := flag.String("output", "", "Path to output JSON file")
	rootDir := flag.String("root", "", "Root directory to start scanning")
	verbose := flag.Bool("verbose", false, "Enable verbose output")
	flag.Parse()

	// Load configuration
	config := defaultConfig
	if *configFile != "" {
		if err := loadConfig(&config, *configFile); err != nil {
			fmt.Fprintf(os.Stderr, "Error loading config: %v\n", err)
			os.Exit(1)
		}
	}

	// Override config with command line flags if provided
	if *rootDir != "" {
		config.RootDir = *rootDir
	}
	if *outputFile != "" {
		config.OutputFile = *outputFile
	}
	if *verbose {
		config.VerboseOutput = true
	}

	// Validate configuration
	absRootDir, err := filepath.Abs(config.RootDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error resolving absolute path: %v\n", err)
		os.Exit(1)
	}
	config.RootDir = absRootDir

	if config.VerboseOutput {
		fmt.Printf("Analyzing codebase in %s\n", config.RootDir)
		fmt.Printf("Looking for legacy imports: %v\n", config.LegacyImports)
		fmt.Printf("Looking for legacy protocols: %v\n", config.LegacyProtocols)
	}

	// Run the analysis
	report := analyzeCodebase(config)

	// Output the results
	outputReport(report, config)
}

func loadConfig(config *Config, configFile string) error {
	data, err := os.ReadFile(configFile)
	if err != nil {
		return fmt.Errorf("failed to read config file: %w", err)
	}

	if err := json.Unmarshal(data, config); err != nil {
		return fmt.Errorf("failed to parse config file: %w", err)
	}

	return nil
}

func analyzeCodebase(config Config) *AnalysisReport {
	report := &AnalysisReport{
		FileAnalyses:  make([]*FileAnalysis, 0),
		ModuleMapping: make(map[string][]string),
		BazelTargets:  make(map[string][]string),
	}

	// Create a semaphore to limit the number of goroutines
	sem := make(chan struct{}, config.MaxGoRoutines)
	var wg sync.WaitGroup
	var mu sync.Mutex

	// Walk through the directory tree
	filepath.WalkDir(config.RootDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// Skip excluded directories
		if d.IsDir() {
			for _, excludeDir := range config.ExcludeDirs {
				if matched, _ := filepath.Match(excludeDir, d.Name()); matched {
					if config.VerboseOutput {
						fmt.Printf("Skipping excluded directory: %s\n", path)
					}
					return filepath.SkipDir
				}
			}
			return nil
		}

		// Only process Swift, Objective-C, and Bazel build files
		ext := strings.ToLower(filepath.Ext(path))
		if ext != ".swift" && ext != ".h" && ext != ".m" && ext != ".mm" && d.Name() != "BUILD" && d.Name() != "BUILD.bazel" {
			return nil
		}

		// Acquire a slot in the semaphore
		sem <- struct{}{}
		wg.Add(1)

		go func(filePath string) {
			defer func() {
				<-sem // Release the semaphore slot
				wg.Done()
			}()

			if strings.HasSuffix(filePath, ".swift") || strings.HasSuffix(filePath, ".h") ||
				strings.HasSuffix(filePath, ".m") || strings.HasSuffix(filePath, ".mm") {
				// Analyze source file
				analysis := analyzeFile(filePath, config)
				if analysis != nil {
					mu.Lock()
					report.FileAnalyses = append(report.FileAnalyses, analysis)
					if analysis.HasLegacyImports {
						report.FilesWithLegacyImports++
					}
					if analysis.HasModernImports {
						report.FilesWithModernImports++
					}
					if analysis.NeedsRefactoring {
						report.FilesNeedingRefactoring++
					}
					mu.Unlock()
				}
			} else if d.Name() == "BUILD" || d.Name() == "BUILD.bazel" {
				// Analyze Bazel build file
				targets := analyzeBazelFile(filePath, config)
				if len(targets) > 0 {
					mu.Lock()
					report.BazelTargets[filePath] = targets
					mu.Unlock()
				}
			}
		}(path)

		return nil
	})

	// Wait for all goroutines to finish
	wg.Wait()

	// Sort the file analyses for consistent output
	sort.Slice(report.FileAnalyses, func(i, j int) bool {
		return report.FileAnalyses[i].FilePath < report.FileAnalyses[j].FilePath
	})

	// Build module mapping
	if config.IncludeModuleMap {
		for _, analysis := range report.FileAnalyses {
			if analysis.Module != "" {
				report.ModuleMapping[analysis.Module] = append(report.ModuleMapping[analysis.Module], analysis.FilePath)
			}
		}
	}

	// Find modules that need refactoring
	modulesNeedingRefactoring := make(map[string]bool)
	for _, analysis := range report.FileAnalyses {
		if analysis.NeedsRefactoring && analysis.Module != "" {
			modulesNeedingRefactoring[analysis.Module] = true
		}
	}

	// Convert map to sorted slice
	for module := range modulesNeedingRefactoring {
		report.ModulesToRefactor = append(report.ModulesToRefactor, module)
	}
	sort.Strings(report.ModulesToRefactor)

	// Set total file count
	report.TotalFiles = len(report.FileAnalyses)

	return report
}

func analyzeFile(filePath string, config Config) *FileAnalysis {
	file, err := os.Open(filePath)
	if err != nil {
		if config.VerboseOutput {
			fmt.Fprintf(os.Stderr, "Error opening file %s: %v\n", filePath, err)
		}
		return nil
	}
	defer file.Close()

	analysis := &FileAnalysis{
		FilePath:        filePath,
		LegacyImports:   make([]string, 0),
		LegacyProtocols: make([]string, 0),
		ModernImports:   make([]string, 0),
		ModernProtocols: make([]string, 0),
		Language:        strings.TrimPrefix(filepath.Ext(filePath), "."),
	}

	// Determine module from file path
	parts := strings.Split(filePath, string(filepath.Separator))
	for i, part := range parts {
		if part == "Sources" && i+1 < len(parts) {
			analysis.Module = parts[i+1]
			break
		}
	}

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()

		// Check for legacy imports
		for _, legacyImport := range config.LegacyImports {
			if strings.Contains(line, legacyImport) {
				analysis.HasLegacyImports = true
				analysis.LegacyImports = append(analysis.LegacyImports, legacyImport)
			}
		}

		// Check for legacy protocols
		for _, legacyProtocol := range config.LegacyProtocols {
			if strings.Contains(line, legacyProtocol) {
				analysis.HasLegacyProtocols = true
				analysis.LegacyProtocols = append(analysis.LegacyProtocols, legacyProtocol)
			}
		}

		// Check for modern imports
		for _, modernImport := range config.ModernImports {
			if strings.Contains(line, modernImport) {
				analysis.HasModernImports = true
				analysis.ModernImports = append(analysis.ModernImports, modernImport)
			}
		}

		// Check for modern protocols
		for _, modernProtocol := range config.ModernProtocols {
			if strings.Contains(line, modernProtocol) {
				analysis.HasModernProtocols = true
				analysis.ModernProtocols = append(analysis.ModernProtocols, modernProtocol)
			}
		}
	}

	if err := scanner.Err(); err != nil {
		if config.VerboseOutput {
			fmt.Fprintf(os.Stderr, "Error scanning file %s: %v\n", filePath, err)
		}
		return nil
	}

	// Determine if file needs refactoring
	analysis.NeedsRefactoring = (analysis.HasLegacyImports || analysis.HasLegacyProtocols) && !analysis.HasModernImports

	return analysis
}

func analyzeBazelFile(filePath string, config Config) []string {
	file, err := os.Open(filePath)
	if err != nil {
		if config.VerboseOutput {
			fmt.Fprintf(os.Stderr, "Error opening Bazel file %s: %v\n", filePath, err)
		}
		return nil
	}
	defer file.Close()

	var targets []string
	content, err := os.ReadFile(filePath)
	if err != nil {
		if config.VerboseOutput {
			fmt.Fprintf(os.Stderr, "Error reading Bazel file %s: %v\n", filePath, err)
		}
		return nil
	}

	contentStr := string(content)
	matches := bazelSwiftLibRe.FindAllStringSubmatch(contentStr, -1)
	for _, match := range matches {
		if len(match) > 1 {
			targetName := match[1]
			targets = append(targets, targetName)
		}
	}

	return targets
}

func outputReport(report *AnalysisReport, config Config) {
	// Create JSON output
	jsonData, err := json.MarshalIndent(report, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error generating JSON report: %v\n", err)
		os.Exit(1)
	}

	// Write to output file
	if err := os.WriteFile(config.OutputFile, jsonData, 0644); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing report to %s: %v\n", config.OutputFile, err)
		os.Exit(1)
	}

	// Print summary to console
	fmt.Println("\nXPC Protocol Migration Analysis Summary")
	fmt.Println("======================================")
	fmt.Printf("Total files analyzed: %d\n", report.TotalFiles)
	fmt.Printf("Files with legacy imports: %d\n", report.FilesWithLegacyImports)
	fmt.Printf("Files with modern imports: %d\n", report.FilesWithModernImports)
	fmt.Printf("Files needing refactoring: %d\n", report.FilesNeedingRefactoring)
	fmt.Printf("Modules to refactor: %d\n", len(report.ModulesToRefactor))
	fmt.Println("\nTop modules needing refactoring:")
	
	// Print the modules that need refactoring
	for i, module := range report.ModulesToRefactor {
		if i < 10 { // Show only top 10
			fileCount := len(report.ModuleMapping[module])
			fmt.Printf("  - %s (%d files)\n", module, fileCount)
		}
	}
	
	fmt.Printf("\nDetailed report written to: %s\n", config.OutputFile)
	fmt.Println("\nNext steps:")
	fmt.Println("1. Review the detailed report")
	fmt.Println("2. Prioritize modules with highest number of files to refactor")
	fmt.Println("3. Update imports and protocol conformances")
	fmt.Println("4. Run this tool again to track progress")
}
