package main

import (
	"bufio"
	"encoding/csv"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"sync"
	"time"
)

// ModuleInfo holds information about a code module
type ModuleInfo struct {
	Name       string            // Module name
	Path       string            // Path to the module
	Files      []string          // List of source files
	TotalLOC   int               // Total lines of code
	LOCByExt   map[string]int    // Lines of code by file extension
	FilesByExt map[string]int    // Count of files by extension
}

// Results holds the analysis results
type Results struct {
	Modules       []*ModuleInfo             // All modules
	TotalLOC      int                       // Total lines of code
	TotalFiles    int                       // Total number of files
	FilesByExt    map[string]int            // Count of files by extension
	LOCByExt      map[string]int            // Lines of code by extension
	ModulesBySize map[string][]*ModuleInfo  // Modules grouped by size
	mutex         sync.Mutex                // Mutex for thread-safe updates
}

// File extensions to consider as source code
var sourceExtensions = map[string]bool{
	".swift": true,
	".h":     true,
	".m":     true,
	".mm":    true,
	".c":     true,
	".cpp":   true,
	".java":  true,
	".kt":    true,
	".py":    true,
	".go":    true,
}

// Directories to exclude from analysis
var excludeDirs = map[string]bool{
	".git":        true,
	".build":      true,
	"bazel-bin":   true,
	"bazel-out":   true,
	"bazel-testlogs": true,
	"bazel-UmbraCore": true,
	"third_party": true,
	"node_modules": true,
}

// Size categories for grouping modules
var sizeCategories = []struct {
	Name  string
	Min   int
	Max   int
}{
	{"Tiny (1-5 files)", 1, 5},
	{"Small (6-10 files)", 6, 10},
	{"Medium (11-20 files)", 11, 20},
	{"Large (21-50 files)", 21, 50},
	{"X-Large (51-100 files)", 51, 100},
	{"XX-Large (100+ files)", 101, -1}, // -1 means no upper limit
}

// getSizeCategory returns the size category for a given file count
func getSizeCategory(fileCount int) string {
	for _, category := range sizeCategories {
		if fileCount >= category.Min && (category.Max == -1 || fileCount <= category.Max) {
			return category.Name
		}
	}
	return "Unknown"
}

func main() {
	// Parse command line flags
	rootDir := flag.String("root", ".", "Root directory to start scanning")
	outputFile := flag.String("output", "code_size_analysis.csv", "Output CSV file")
	verbose := flag.Bool("verbose", false, "Verbose output")
	concurrency := flag.Int("concurrency", 10, "Number of workers to process files concurrently")
	flag.Parse()

	// Validate root directory exists
	if _, err := os.Stat(*rootDir); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "Error: Root directory %s does not exist\n", *rootDir)
		os.Exit(1)
	}

	// Get absolute path of root directory
	rootDirAbs, err := filepath.Abs(*rootDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: Cannot get absolute path of %s: %v\n", *rootDir, err)
		os.Exit(1)
	}

	startTime := time.Now()
	fmt.Println("Starting analysis of UmbraCore codebase...")
	fmt.Printf("Root directory: %s\n", rootDirAbs)

	// Analyse the codebase
	results := analyseCodebase(rootDirAbs, *verbose, *concurrency)

	// Write results to CSV
	err = writeResultsToCSV(results, *outputFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing results to CSV: %v\n", err)
		os.Exit(1)
	}

	elapsedTime := time.Since(startTime)
	fmt.Printf("Analysis complete in %v.\n", elapsedTime.Round(time.Millisecond))
	fmt.Printf("Total files analyzed: %d\n", results.TotalFiles)
	fmt.Printf("Total lines of code: %d\n", results.TotalLOC)
	fmt.Printf("Results written to %s\n", *outputFile)
}

// analyseCodebase analyses the entire codebase starting from the root directory
func analyseCodebase(rootDir string, verbose bool, concurrency int) *Results {
	results := &Results{
		Modules:       make([]*ModuleInfo, 0),
		FilesByExt:    make(map[string]int),
		LOCByExt:      make(map[string]int),
		ModulesBySize: make(map[string][]*ModuleInfo),
	}

	// Find all source directories (potential modules)
	modules, err := findModules(rootDir, verbose)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error finding modules: %v\n", err)
		return results
	}

	fmt.Printf("Found %d potential modules to analyze\n", len(modules))

	// Create a channel for the worker pool
	moduleChan := make(chan *ModuleInfo, len(modules))
	resultsChan := make(chan *ModuleInfo, len(modules))

	// Create workers
	var wg sync.WaitGroup
	for i := 0; i < concurrency; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for module := range moduleChan {
				if verbose {
					fmt.Printf("Processing module: %s\n", module.Name)
				}
				
				// Process module
				analyseModuleFiles(module, verbose)
				
				resultsChan <- module
			}
		}()
	}

	// Send modules to workers
	for _, module := range modules {
		moduleChan <- module
	}
	close(moduleChan)

	// Collect results
	go func() {
		wg.Wait()
		close(resultsChan)
	}()

	// Process results
	for module := range resultsChan {
		// Skip modules with no source files
		if len(module.Files) == 0 {
			continue
		}
		
		// Add module to results
		results.mutex.Lock()
		results.Modules = append(results.Modules, module)
		results.TotalLOC += module.TotalLOC
		results.TotalFiles += len(module.Files)
		
		// Aggregate file counts and LOC by extension
		for ext, count := range module.FilesByExt {
			results.FilesByExt[ext] += count
		}
		for ext, loc := range module.LOCByExt {
			results.LOCByExt[ext] += loc
		}
		
		// Group modules by size category
		sizeCategory := getSizeCategory(len(module.Files))
		results.ModulesBySize[sizeCategory] = append(results.ModulesBySize[sizeCategory], module)
		results.mutex.Unlock()
	}

	// Sort modules within each size category by total LOC
	for category, modules := range results.ModulesBySize {
		sort.Slice(modules, func(i, j int) bool {
			return modules[i].TotalLOC > modules[j].TotalLOC
		})
		results.ModulesBySize[category] = modules
	}

	// Sort modules by total LOC
	sort.Slice(results.Modules, func(i, j int) bool {
		return results.Modules[i].TotalLOC > results.Modules[j].TotalLOC
	})

	return results
}

// findModules finds all potentially source code modules in the given directory
func findModules(rootDir string, verbose bool) ([]*ModuleInfo, error) {
	var modules []*ModuleInfo
	
	// Create a module for the root directory
	rootModule := &ModuleInfo{
		Name:       filepath.Base(rootDir),
		Path:       rootDir,
		Files:      []string{},
		LOCByExt:   make(map[string]int),
		FilesByExt: make(map[string]int),
	}
	modules = append(modules, rootModule)
	
	// Find potential module directories (Sources, Tests, etc.)
	sourcesDir := filepath.Join(rootDir, "Sources")
	if dirExists(sourcesDir) {
		// Check if Sources contains subdirectories
		subdirs, err := findSubdirectories(sourcesDir)
		if err != nil {
			return nil, err
		}
		
		for _, subdir := range subdirs {
			moduleName := filepath.Base(subdir)
			modules = append(modules, &ModuleInfo{
				Name:       moduleName,
				Path:       subdir,
				Files:      []string{},
				LOCByExt:   make(map[string]int),
				FilesByExt: make(map[string]int),
			})
			
			// Check if this subdir has its own Sources dir
			moduleSourcesDir := filepath.Join(subdir, "Sources")
			if dirExists(moduleSourcesDir) {
				modules = append(modules, &ModuleInfo{
					Name:       moduleName + "/Sources",
					Path:       moduleSourcesDir,
					Files:      []string{},
					LOCByExt:   make(map[string]int),
					FilesByExt: make(map[string]int),
				})
			}
		}
	}
	
	// Add Tests directory if it exists
	testsDir := filepath.Join(rootDir, "Tests")
	if dirExists(testsDir) {
		// Find test module directories
		subdirs, err := findSubdirectories(testsDir)
		if err != nil {
			return nil, err
		}
		
		for _, subdir := range subdirs {
			moduleName := filepath.Base(subdir)
			modules = append(modules, &ModuleInfo{
				Name:       "Tests/" + moduleName,
				Path:       subdir,
				Files:      []string{},
				LOCByExt:   make(map[string]int),
				FilesByExt: make(map[string]int),
			})
		}
	}
	
	return modules, nil
}

// analyseModuleFiles finds and analyzes all source files in a module
func analyseModuleFiles(module *ModuleInfo, verbose bool) {
	// Find all source files in this module
	var sourceFiles []string
	err := filepath.Walk(module.Path, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		
		// Skip excluded directories
		if info.IsDir() {
			if excludeDirs[info.Name()] {
				return filepath.SkipDir
			}
			return nil
		}
		
		// Check file extension
		ext := filepath.Ext(path)
		if sourceExtensions[ext] {
			sourceFiles = append(sourceFiles, path)
		}
		
		return nil
	})
	
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error walking directory %s: %v\n", module.Path, err)
		return
	}
	
	module.Files = sourceFiles
	
	// Analyze each file
	for _, filePath := range sourceFiles {
		// Get file extension
		ext := filepath.Ext(filePath)
		
		// Count lines in the file
		lines, err := countLines(filePath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error counting lines in %s: %v\n", filePath, err)
			continue
		}
		
		// Update module statistics
		module.TotalLOC += lines
		module.LOCByExt[ext] += lines
		module.FilesByExt[ext]++
	}
}

// findSubdirectories returns all immediate subdirectories of the given directory
func findSubdirectories(dir string) ([]string, error) {
	var subdirs []string
	
	files, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}
	
	for _, file := range files {
		if file.IsDir() {
			// Skip excluded directories
			if excludeDirs[file.Name()] {
				continue
			}
			subdirs = append(subdirs, filepath.Join(dir, file.Name()))
		}
	}
	
	return subdirs, nil
}

// dirExists checks if a directory exists
func dirExists(path string) bool {
	info, err := os.Stat(path)
	if os.IsNotExist(err) {
		return false
	}
	return info.IsDir()
}

// countLines counts the number of lines in a file
func countLines(filePath string) (int, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return 0, err
	}
	defer file.Close()
	
	scanner := bufio.NewScanner(file)
	lineCount := 0
	
	for scanner.Scan() {
		lineCount++
	}
	
	if err := scanner.Err(); err != nil {
		return 0, err
	}
	
	return lineCount, nil
}

// writeResultsToCSV writes the analysis results to a CSV file
func writeResultsToCSV(results *Results, outputFile string) error {
	file, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	defer file.Close()
	
	writer := csv.NewWriter(file)
	defer writer.Flush()
	
	// Write header
	header := []string{
		"Module", "File Count", "Total LOC", 
		"Swift Files", "Swift LOC",
		"Obj-C Files", "Obj-C LOC", 
		"C/C++ Files", "C/C++ LOC", 
		"Header Files", "Header LOC",
		"Avg LOC/File", "Size Category",
	}
	if err := writer.Write(header); err != nil {
		return err
	}
	
	// Write summary row
	swiftFiles := results.FilesByExt[".swift"]
	swiftLOC := results.LOCByExt[".swift"]
	objcFiles := results.FilesByExt[".m"] + results.FilesByExt[".mm"]
	objcLOC := results.LOCByExt[".m"] + results.LOCByExt[".mm"]
	cppFiles := results.FilesByExt[".c"] + results.FilesByExt[".cpp"]
	cppLOC := results.LOCByExt[".c"] + results.LOCByExt[".cpp"]
	headerFiles := results.FilesByExt[".h"]
	headerLOC := results.LOCByExt[".h"]
	
	avgLinesPerFile := 0
	if results.TotalFiles > 0 {
		avgLinesPerFile = results.TotalLOC / results.TotalFiles
	}
	
	summaryRow := []string{
		"ALL MODULES", 
		strconv.Itoa(results.TotalFiles), 
		strconv.Itoa(results.TotalLOC),
		strconv.Itoa(swiftFiles),
		strconv.Itoa(swiftLOC),
		strconv.Itoa(objcFiles),
		strconv.Itoa(objcLOC),
		strconv.Itoa(cppFiles),
		strconv.Itoa(cppLOC),
		strconv.Itoa(headerFiles),
		strconv.Itoa(headerLOC),
		strconv.Itoa(avgLinesPerFile),
		"",
	}
	if err := writer.Write(summaryRow); err != nil {
		return err
	}
	
	// Write a blank row
	if err := writer.Write([]string{""}); err != nil {
		return err
	}

	// Write data for each module, grouped by size category
	for _, category := range sizeCategories {
		modules := results.ModulesBySize[category.Name]
		
		// Skip empty categories
		if len(modules) == 0 {
			continue
		}
		
		// Write category header
		if err := writer.Write([]string{category.Name, "", "", "", "", "", "", "", "", "", "", "", ""}); err != nil {
			return err
		}
		
		// Write modules in this category
		for _, module := range modules {
			swiftFiles := module.FilesByExt[".swift"]
			swiftLOC := module.LOCByExt[".swift"]
			objcFiles := module.FilesByExt[".m"] + module.FilesByExt[".mm"]
			objcLOC := module.LOCByExt[".m"] + module.LOCByExt[".mm"]
			cppFiles := module.FilesByExt[".c"] + module.FilesByExt[".cpp"]
			cppLOC := module.LOCByExt[".c"] + module.LOCByExt[".cpp"]
			headerFiles := module.FilesByExt[".h"]
			headerLOC := module.LOCByExt[".h"]
			
			avgLinesPerFile := 0
			if len(module.Files) > 0 {
				avgLinesPerFile = module.TotalLOC / len(module.Files)
			}
			
			row := []string{
				module.Name,
				strconv.Itoa(len(module.Files)),
				strconv.Itoa(module.TotalLOC),
				strconv.Itoa(swiftFiles),
				strconv.Itoa(swiftLOC),
				strconv.Itoa(objcFiles),
				strconv.Itoa(objcLOC),
				strconv.Itoa(cppFiles),
				strconv.Itoa(cppLOC),
				strconv.Itoa(headerFiles),
				strconv.Itoa(headerLOC),
				strconv.Itoa(avgLinesPerFile),
				getSizeCategory(len(module.Files)),
			}
			
			if err := writer.Write(row); err != nil {
				return err
			}
		}
		
		// Write a blank row after each category
		if err := writer.Write([]string{""}); err != nil {
			return err
		}
	}
	
	return nil
}
