package main

import (
	"bufio"
	"encoding/csv"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"sync"
)

// TargetInfo holds information about a Bazel target
type TargetInfo struct {
	Name         string            // Target name
	Type         string            // Target type
	Files        []string          // List of source files
	FileCount    int               // Number of source files
	Module       string            // Module name
	TotalLOC     int               // Total lines of code
	LOCByExt     map[string]int    // Lines of code by file extension
}

// Results holds the analysis results
type Results struct {
	Targets      []*TargetInfo           // All targets
	TotalLOC     int                     // Total lines of code
	TotalFiles   int                     // Total number of files
	FilesPerExt  map[string]int          // Count of files by extension
	TargetsBySize map[string][]*TargetInfo // Targets grouped by size
	mutex        sync.Mutex              // Mutex for thread-safe updates
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

// Size categories for grouping targets
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
	concurrency := flag.Int("concurrency", 10, "Number of targets to process concurrently")
	flag.Parse()

	// Validate root directory exists
	if _, err := os.Stat(*rootDir); os.IsNotExist(err) {
		fmt.Fprintf(os.Stderr, "Error: Root directory %s does not exist\n", *rootDir)
		os.Exit(1)
	}

	fmt.Println("Starting analysis of UmbraCore codebase...")
	fmt.Printf("Root directory: %s\n", *rootDir)
	fmt.Printf("Processing targets with %d workers\n", *concurrency)

	// Analyse the codebase
	results := analyseCodebase(*rootDir, *verbose, *concurrency)
	if results == nil {
		fmt.Fprintln(os.Stderr, "Analysis failed")
		os.Exit(1)
	}

	// Write results to CSV
	err := writeResultsToCSV(results, *outputFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing results to CSV: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Analysis complete. Results written to %s\n", *outputFile)
}

// analyseCodebase analyses the entire codebase starting from the root directory
func analyseCodebase(rootDir string, verbose bool, concurrency int) *Results {
	// Get all targets using bazelisk query
	targets, err := getBazelTargets(rootDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error retrieving Bazel targets: %v\n", err)
		return nil
	}

	fmt.Printf("Found %d targets to process\n", len(targets))
	results := &Results{
		Targets:      make([]*TargetInfo, 0),
		FilesPerExt:  make(map[string]int),
		TargetsBySize: make(map[string][]*TargetInfo),
	}

	// Create a channel for the worker pool
	targetChan := make(chan string, len(targets))
	resultsChan := make(chan *TargetInfo, len(targets))

	// Create workers
	var wg sync.WaitGroup
	for i := 0; i < concurrency; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for targetName := range targetChan {
				if verbose {
					fmt.Printf("Processing target: %s\n", targetName)
				}
				
				// Process target
				targetInfo, err := processTarget(targetName, rootDir, verbose)
				if err != nil {
					fmt.Fprintf(os.Stderr, "Error processing target %s: %v\n", targetName, err)
					continue
				}
				
				// Analyse files in this target
				analyseTargetFiles(rootDir, targetInfo, results, verbose)
				
				resultsChan <- targetInfo
			}
		}()
	}

	// Send targets to workers
	for _, target := range targets {
		targetChan <- target
	}
	close(targetChan)

	// Collect results
	go func() {
		wg.Wait()
		close(resultsChan)
	}()

	// Process results
	for targetInfo := range resultsChan {
		// Add target to results
		results.mutex.Lock()
		results.Targets = append(results.Targets, targetInfo)
		results.TotalLOC += targetInfo.TotalLOC
		results.TotalFiles += targetInfo.FileCount
		
		// Group targets by size category
		sizeCategory := getSizeCategory(targetInfo.FileCount)
		results.TargetsBySize[sizeCategory] = append(results.TargetsBySize[sizeCategory], targetInfo)
		results.mutex.Unlock()
	}

	// Sort targets within each size category by total LOC
	for category, targets := range results.TargetsBySize {
		sort.Slice(targets, func(i, j int) bool {
			return targets[i].TotalLOC > targets[j].TotalLOC
		})
		results.TargetsBySize[category] = targets
	}

	return results
}

// Get all Bazel targets in the repository
func getBazelTargets(rootDir string) ([]string, error) {
	fmt.Println("Retrieving all Bazel targets...")
	
	// Run bazelisk query to list all targets
	cmd := exec.Command("bazelisk", "query", "//...")
	cmd.Dir = rootDir
	output, err := cmd.Output()
	if err != nil {
		// Handle Bazel query error by using a fallback approach
		fmt.Println("Warning: Bazel query failed. Using fallback approach to find targets.")
		return findBazelTargetsWithFind(rootDir)
	}
	
	// Process output
	targets := []string{}
	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	for scanner.Scan() {
		target := strings.TrimSpace(scanner.Text())
		if target != "" {
			targets = append(targets, target)
		}
	}
	
	return targets, nil
}

// Fallback method to find Bazel targets using find
func findBazelTargetsWithFind(rootDir string) ([]string, error) {
	var targets []string
	
	// Find all BUILD files
	cmd := exec.Command("find", ".", "-name", "BUILD", "-o", "-name", "BUILD.bazel")
	cmd.Dir = rootDir
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("error finding BUILD files: %v", err)
	}
	
	// Process BUILD files
	buildFiles := strings.Split(string(output), "\n")
	for _, buildFile := range buildFiles {
		if buildFile == "" {
			continue
		}
		
		// Get the directory containing the BUILD file
		dir := filepath.Dir(buildFile)
		if dir == "." {
			dir = ""
		} else {
			dir = strings.TrimPrefix(dir, "./")
		}
		
		// Create a target label for this directory
		target := fmt.Sprintf("//%s:all", dir)
		targets = append(targets, target)
	}
	
	return targets, nil
}

// Process a single target
func processTarget(targetName string, rootDir string, verbose bool) (*TargetInfo, error) {
	// Extract module and target name from the full target path
	parts := strings.Split(targetName, ":")
	if len(parts) != 2 {
		return nil, fmt.Errorf("invalid target name: %s", targetName)
	}
	
	modulePath := parts[0]
	name := parts[1]
	
	// Determine target type using bazelisk query
	cmd := exec.Command("bazelisk", "query", fmt.Sprintf("kind(*, %s)", targetName))
	cmd.Dir = rootDir
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("error determining target type: %v", err)
	}
	
	// Extract the target type (e.g., swift_library, objc_library)
	outputStr := strings.TrimSpace(string(output))
	targetType := "unknown"
	
	if strings.Contains(outputStr, "swift_library") {
		targetType = "swift_library"
	} else if strings.Contains(outputStr, "objc_library") {
		targetType = "objc_library"
	}
	
	return &TargetInfo{
		Name:         name,
		Type:         targetType,
		Module:       modulePath,
		LOCByExt:     make(map[string]int),
		Files:        []string{},
		FileCount:    0,
	}, nil
}

// analyseTargetFiles analyses the files in a target
func analyseTargetFiles(rootDir string, targetInfo *TargetInfo, results *Results, verbose bool) {
	// Get source files for this target
	files, err := getSourceFiles(rootDir, targetInfo.Name, verbose)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error getting source files for %s: %v\n", targetInfo.Name, err)
		return
	}
	
	targetInfo.Files = files
	targetInfo.FileCount = len(files)
	
	// Analyze each file
	for _, file := range files {
		// Get file extension
		ext := filepath.Ext(file)
		
		// Skip non-source files
		if !sourceExtensions[ext] {
			continue
		}
		
		// Add to files per extension
		results.mutex.Lock()
		results.FilesPerExt[ext]++
		results.mutex.Unlock()
		
		// Get full path to the file
		fullPath := getFilePath(rootDir, targetInfo.Name, file)
		if fullPath == "" {
			fmt.Fprintf(os.Stderr, "Error: Could not find path for file %s in target %s\n", file, targetInfo.Name)
			continue
		}
		
		// Count lines in the file
		lines, err := countLines(fullPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error counting lines in %s: %v\n", fullPath, err)
			continue
		}
		
		// Update target statistics
		targetInfo.TotalLOC += lines
		
		// Group by file extension
		if _, ok := targetInfo.LOCByExt[ext]; !ok {
			targetInfo.LOCByExt[ext] = 0
		}
		targetInfo.LOCByExt[ext] += lines
	}
}

// getSourceFiles gets the source files for a target
func getSourceFiles(rootDir string, targetName string, verbose bool) ([]string, error) {
	// Run bazelisk query to list all source files
	cmd := exec.Command("bazelisk", "query", fmt.Sprintf("labels(srcs, %s)", targetName))
	cmd.Dir = rootDir
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("bazelisk query failed: %v", err)
	}
	
	// Process output
	files := []string{}
	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	for scanner.Scan() {
		file := strings.TrimSpace(scanner.Text())
		if file != "" {
			files = append(files, file)
		}
	}
	
	return files, nil
}

// getFilePath gets the full path to a file
func getFilePath(rootDir string, targetName string, file string) string {
	// Convert Bazel label to file path
	filePath := filepath.Join(rootDir, strings.TrimPrefix(file, "//"))
	
	// Check if file exists
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		return ""
	}
	
	return filePath
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
		"Target", "Module", "Type", "File Count", "Total LOC", 
		"Swift LOC", "Obj-C LOC", "C/C++ LOC", "Header LOC", "Other Files",
		"Avg Lines/File", "Size Category",
	}
	if err := writer.Write(header); err != nil {
		return err
	}
	
	// Write summary row
	summaryRow := []string{
		"ALL TARGETS", "", "", strconv.Itoa(results.TotalFiles), strconv.Itoa(results.TotalLOC),
		strconv.Itoa(results.FilesPerExt[".swift"]), 
		strconv.Itoa(results.FilesPerExt[".m"] + results.FilesPerExt[".mm"]), 
		strconv.Itoa(results.FilesPerExt[".c"] + results.FilesPerExt[".cpp"]), 
		strconv.Itoa(results.FilesPerExt[".h"]),
		"", "", "",
	}
	if err := writer.Write(summaryRow); err != nil {
		return err
	}
	
	// Write a blank row
	if err := writer.Write([]string{""}); err != nil {
		return err
	}

	// Write data for each target, grouped by size category
	for _, category := range sizeCategories {
		targets := results.TargetsBySize[category.Name]
		
		// Skip empty categories
		if len(targets) == 0 {
			continue
		}
		
		// Write category header
		if err := writer.Write([]string{category.Name, "", "", "", "", "", "", "", "", "", "", ""}); err != nil {
			return err
		}
		
		// Write targets in this category
		for _, target := range targets {
			swiftLOC := target.LOCByExt[".swift"]
			objcLOC := target.LOCByExt[".m"] + target.LOCByExt[".mm"]
			cppLOC := target.LOCByExt[".c"] + target.LOCByExt[".cpp"]
			headerLOC := target.LOCByExt[".h"]
			
			avgLinesPerFile := 0
			if target.FileCount > 0 {
				avgLinesPerFile = target.TotalLOC / target.FileCount
			}
			
			row := []string{
				target.Name, 
				target.Module, 
				target.Type, 
				strconv.Itoa(target.FileCount), 
				strconv.Itoa(target.TotalLOC),
				strconv.Itoa(swiftLOC), 
				strconv.Itoa(objcLOC), 
				strconv.Itoa(cppLOC), 
				strconv.Itoa(headerLOC),
				strconv.Itoa(target.FileCount - len(target.LOCByExt)),
				strconv.Itoa(avgLinesPerFile),
				getSizeCategory(target.FileCount),
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
