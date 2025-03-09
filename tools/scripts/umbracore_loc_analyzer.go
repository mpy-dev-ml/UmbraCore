package main

import (
	"bufio"
	"encoding/csv"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

type Target struct {
	Name     string
	Type     string
	Files    []string
	TotalLOC int
}

type File struct {
	Path string
	LOC  int
}

// Results structure to store target analysis results
type TargetResult struct {
	Target     Target
	FileDetails []File
}

func main() {
	startTime := time.Now()
	
	// Set working directory to the project root
	projectRoot := "/Users/mpy/CascadeProjects/UmbraCore"
	err := os.Chdir(projectRoot)
	if err != nil {
		fmt.Printf("Error changing to project directory: %v\n", err)
		os.Exit(1)
	}

	// Get all targets using bazel query
	targets, err := getAllTargets()
	if err != nil {
		fmt.Printf("Error getting targets: %v\n", err)
		os.Exit(1)
	}

	// Create CSV writer
	csvFile, err := os.Create(filepath.Join(projectRoot, "umbracore_loc_analysis.csv"))
	if err != nil {
		fmt.Printf("Error creating CSV file: %v\n", err)
		os.Exit(1)
	}
	defer csvFile.Close()

	writer := csv.NewWriter(csvFile)
	defer writer.Flush()

	// Write CSV header
	err = writer.Write([]string{"Target", "Target Type", "Total LOC", "File", "File LOC"})
	if err != nil {
		fmt.Printf("Error writing CSV header: %v\n", err)
		os.Exit(1)
	}

	// Process targets concurrently
	fmt.Println("Analyzing UmbraCore project targets and source files...")

	// Filter out test targets for brevity, unless you want to include them
	var filteredTargets []Target
	for _, target := range targets {
		if strings.Contains(target.Name, "test") || strings.Contains(target.Name, "Test") {
			continue
		}
		filteredTargets = append(filteredTargets, target)
	}
	
	// Set up a channel to receive results
	resultsChan := make(chan TargetResult, len(filteredTargets))
	
	// Use a WaitGroup to wait for all goroutines to finish
	var wg sync.WaitGroup
	
	// Set up a worker pool with a reasonable number of concurrent workers
	// Too many concurrent bazel queries might overload the system
	const maxWorkers = 10
	targetChan := make(chan Target, len(filteredTargets))
	
	// Start worker goroutines
	for i := 0; i < maxWorkers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for target := range targetChan {
				processTarget(target, resultsChan)
			}
		}()
	}
	
	// Feed the targets into the channel
	for _, target := range filteredTargets {
		targetChan <- target
	}
	close(targetChan)
	
	// Start a goroutine to close the results channel when all workers are done
	go func() {
		wg.Wait()
		close(resultsChan)
	}()
	
	// Collect all results from the channel
	var results []TargetResult
	for result := range resultsChan {
		results = append(results, result)
	}
	
	// Sort results by target name for consistent output
	sort.Slice(results, func(i, j int) bool {
		return results[i].Target.Name < results[j].Target.Name
	})
	
	// Write results to CSV file
	csvMutex := sync.Mutex{}
	for _, result := range results {
		csvMutex.Lock()
		// Write target summary
		err = writer.Write([]string{result.Target.Name, result.Target.Type, strconv.Itoa(result.Target.TotalLOC), "", ""})
		if err != nil {
			fmt.Printf("Error writing target to CSV: %v\n", err)
			csvMutex.Unlock()
			continue
		}
		
		// Write file details for the target
		for _, file := range result.FileDetails {
			err = writer.Write([]string{"", "", "", file.Path, strconv.Itoa(file.LOC)})
			if err != nil {
				fmt.Printf("Error writing file to CSV: %v\n", err)
				continue
			}
		}
		csvMutex.Unlock()

		fmt.Printf("Processed target: %s with %d files and %d lines of code\n", 
			result.Target.Name, len(result.FileDetails), result.Target.TotalLOC)
	}

	elapsed := time.Since(startTime)
	fmt.Printf("Analysis complete in %s. Results written to umbracore_loc_analysis.csv\n", elapsed)
}

func processTarget(target Target, resultsChan chan<- TargetResult) {
	sourceFiles, err := getSourceFilesForTarget(target.Name)
	if err != nil {
		fmt.Printf("Error getting source files for target %s: %v\n", target.Name, err)
		return
	}
	
	totalLOC := 0
	var fileDetails []File
	
	// Process files concurrently
	fileChan := make(chan string, len(sourceFiles))
	resultFileChan := make(chan File, len(sourceFiles))
	
	var fileWg sync.WaitGroup
	
	// Use a reasonable number of workers for file processing
	const maxFileWorkers = 20
	workerCount := maxFileWorkers
	if len(sourceFiles) < maxFileWorkers {
		workerCount = len(sourceFiles)
	}
	
	// Start file worker goroutines
	for i := 0; i < workerCount; i++ {
		fileWg.Add(1)
		go func() {
			defer fileWg.Done()
			for file := range fileChan {
				loc := countLinesOfCode(file)
				resultFileChan <- File{Path: file, LOC: loc}
			}
		}()
	}
	
	// Feed files into the channel
	for _, file := range sourceFiles {
		fileChan <- file
	}
	close(fileChan)
	
	// Start a goroutine to close the result channel when all file workers are done
	go func() {
		fileWg.Wait()
		close(resultFileChan)
	}()
	
	// Collect file results
	for fileResult := range resultFileChan {
		fileDetails = append(fileDetails, fileResult)
		totalLOC += fileResult.LOC
	}
	
	// Sort files by path for consistent output
	sort.Slice(fileDetails, func(i, j int) bool {
		return fileDetails[i].Path < fileDetails[j].Path
	})
	
	target.TotalLOC = totalLOC
	
	// Send the result back via the channel
	resultsChan <- TargetResult{
		Target:      target,
		FileDetails: fileDetails,
	}
}

func getAllTargets() ([]Target, error) {
	fmt.Println("Querying all targets in the Sources directory...")
	cmd := exec.Command("bazelisk", "query", "--output=label", "//Sources/...")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("error running bazel query: %v", err)
	}

	var targets []Target
	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	
	// Channel for collecting target results
	resultChan := make(chan Target, 100)
	
	// Use a WaitGroup to coordinate goroutines
	var wg sync.WaitGroup
	
	// Worker pool for target type determination
	const maxConcurrentQueries = 8
	targetChan := make(chan string, maxConcurrentQueries*2)
	
	// Start worker goroutines
	for i := 0; i < maxConcurrentQueries; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for targetName := range targetChan {
				// Skip repository targets and non-source targets
				if strings.HasPrefix(targetName, "@") || 
				strings.Contains(targetName, "bazel_tools") ||
				strings.Contains(targetName, "local_config") {
					continue
				}
		
				// Get target type
				typeCmd := exec.Command("bazelisk", "query", "--output=build", targetName)
				typeOutput, err := typeCmd.Output()
				if err != nil {
					fmt.Printf("Warning: Could not determine type for target %s: %v\n", targetName, err)
					continue
				}
		
				// Extract target type using a regex to match swift_library, etc.
				re := regexp.MustCompile(`(swift_[a-z_]+|cc_[a-z_]+|objc_[a-z_]+|umbracore_[a-z_]+)`)
				matches := re.FindStringSubmatch(string(typeOutput))
				
				targetType := "unknown"
				if len(matches) > 0 {
					targetType = matches[0]
				}
		
				resultChan <- Target{
					Name: targetName,
					Type: targetType,
				}
			}
		}()
	}
	
	// Feed target names into the channel
	go func() {
		for scanner.Scan() {
			targetName := scanner.Text()
			targetChan <- targetName
		}
		close(targetChan)
	}()
	
	// Start a goroutine to close the result channel when all workers are done
	go func() {
		wg.Wait()
		close(resultChan)
	}()
	
	// Collect results
	for target := range resultChan {
		targets = append(targets, target)
	}
	
	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("error scanning bazel query output: %v", err)
	}

	fmt.Printf("Found %d targets.\n", len(targets))
	return targets, nil
}

func getSourceFilesForTarget(targetName string) ([]string, error) {
	// Use bazel query to get the source files for this target
	cmd := exec.Command("bazelisk", "query", "--output=build", targetName)
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("error querying target sources: %v", err)
	}

	outputStr := string(output)

	// Extract the target directory from the target name
	targetDir := extractTargetDir(targetName)
	
	// Try multiple approaches to find source files
	
	// 1. Look for standard srcs attribute
	srcFiles := extractSrcsFromAttribute(outputStr, targetDir)
	if len(srcFiles) > 0 {
		return srcFiles, nil
	}
	
	// 2. Look for glob patterns
	globFiles, err := extractSrcsFromGlob(outputStr, targetDir)
	if err != nil {
		fmt.Printf("Warning: Error processing glob for target %s: %v\n", targetName, err)
	}
	if len(globFiles) > 0 {
		return globFiles, nil
	}
	
	// 3. Try a direct filesystem approach - check Sources directory
	// This is a fallback when Bazel query doesn't provide the sources directly
	baseDir := strings.TrimPrefix(targetName, "//")
	baseDir = strings.Split(baseDir, ":")[0]
	
	// Look for Swift files in the directory
	swiftFiles, err := filepath.Glob(filepath.Join(baseDir, "**/*.swift"))
	if err != nil {
		return nil, fmt.Errorf("error finding Swift files: %v", err)
	}
	
	if len(swiftFiles) > 0 {
		return swiftFiles, nil
	}
	
	// 4. Try Sources subdirectory (common pattern in this project)
	sourcesDir := filepath.Join(baseDir, "Sources")
	if _, err := os.Stat(sourcesDir); err == nil {
		swiftFilesInSources, err := filepath.Glob(filepath.Join(sourcesDir, "*.swift"))
		if err != nil {
			return nil, fmt.Errorf("error finding Swift files in Sources: %v", err)
		}
		if len(swiftFilesInSources) > 0 {
			return swiftFilesInSources, nil
		}
	}
	
	return []string{}, nil
}

func extractSrcsFromAttribute(buildOutput, targetDir string) []string {
	// Check for srcs attribute in umbracore_foundation_free_module, swift_library, etc.
	re := regexp.MustCompile(`srcs\s*=\s*\[(.*?)\]`)
	srcMatch := re.FindStringSubmatch(buildOutput)
	
	if len(srcMatch) < 2 {
		return []string{}
	}
	
	srcStr := srcMatch[1]
	return parseSourceFiles(srcStr, targetDir)
}

func extractSrcsFromGlob(buildOutput, targetDir string) ([]string, error) {
	// Look for glob patterns
	globRe := regexp.MustCompile(`srcs\s*=\s*glob\(\[(.*?)\]`)
	globMatch := globRe.FindStringSubmatch(buildOutput)
	
	if len(globMatch) < 2 {
		return []string{}, nil
	}
	
	patternStr := globMatch[1]
	patterns := parseGlobPatterns(patternStr)
	
	return findFilesMatchingPatterns(targetDir, patterns)
}

func parseGlobPatterns(patternStr string) []string {
	// Split by commas and clean up quotes and whitespace
	parts := strings.Split(patternStr, ",")
	var patterns []string
	
	for _, part := range parts {
		part = strings.TrimSpace(part)
		// Remove quotes
		part = strings.Trim(part, "\"'")
		if part != "" {
			patterns = append(patterns, part)
		}
	}
	
	return patterns
}

func extractTargetDir(targetName string) string {
	// Extract directory from target name (e.g., "//Sources/XPCProtocolsCore" -> "Sources/XPCProtocolsCore")
	targetName = strings.TrimPrefix(targetName, "//")
	targetName = strings.Split(targetName, ":")[0]
	return targetName
}

func findFilesMatchingPatterns(targetDir string, patterns []string) ([]string, error) {
	var matchingFiles []string
	
	for _, pattern := range patterns {
		// Handle exclusion patterns
		if strings.HasPrefix(pattern, "exclude=") {
			continue
		}
		
		// Convert glob pattern to a suitable pattern for filepath.Glob
		filePattern := filepath.Join(targetDir, pattern)
		
		// Find matching files
		matches, err := filepath.Glob(filePattern)
		if err != nil {
			return nil, fmt.Errorf("error matching glob pattern %s: %v", pattern, err)
		}
		
		matchingFiles = append(matchingFiles, matches...)
	}
	
	return matchingFiles, nil
}

func parseSourceFiles(srcStr string, targetDir string) []string {
	// Extract the base directory from the target name
	baseDir := strings.TrimPrefix(targetDir, "//")
	baseDir = strings.Split(baseDir, ":")[0]
	
	// Split by commas and clean up quotes and whitespace
	parts := strings.Split(srcStr, ",")
	var sourceFiles []string
	
	for _, part := range parts {
		part = strings.TrimSpace(part)
		// Remove quotes
		part = strings.Trim(part, "\"'")
		if part != "" {
			// Check if it's a relative path or a generated file
			if strings.HasPrefix(part, ":") || strings.HasPrefix(part, "//") {
				// For simplicity, skip generated files
				continue
			}
			
			// Construct the full path
			sourceFile := filepath.Join(baseDir, part)
			sourceFiles = append(sourceFiles, sourceFile)
		}
	}
	
	return sourceFiles
}

func countLinesOfCode(filePath string) int {
	file, err := os.Open(filePath)
	if err != nil {
		fmt.Printf("Warning: Could not open file %s: %v\n", filePath, err)
		return 0
	}
	defer file.Close()

	lineCount := 0
	reader := bufio.NewReader(file)
	for {
		_, err := reader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				break
			}
			fmt.Printf("Warning: Error reading file %s: %v\n", filePath, err)
			return 0
		}
		lineCount++
	}

	return lineCount
}
