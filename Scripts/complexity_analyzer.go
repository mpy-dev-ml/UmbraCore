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
	"strings"
	"sync"
)

// ComplexityInfo holds complexity metrics for a file
type ComplexityInfo struct {
	FilePath             string
	ModuleName           string
	LOC                  int     // Lines of code
	FunctionCount        int     // Number of functions
	AvgFunctionLength    float64 // Average function length in lines
	MaxFunctionLength    int     // Maximum function length
	MaxNestLevel         int     // Maximum nesting level
	ControlStructures    int     // Number of control structures (if, switch, loops)
	ComplexityScore      float64 // Overall complexity score
	LongFunctions        int     // Number of functions over 50 lines
	DeepNesting          int     // Number of spots with nesting level > 3
}

// Module represents a module in the codebase
type Module struct {
	Name    string
	Path    string
	Files   []string
	Metrics []*ComplexityInfo
}

// Results holds the analysis results
type Results struct {
	Modules        []*Module
	TopComplexFiles []*ComplexityInfo
	mutex          sync.Mutex
}

// Main function
func main() {
	// Parse command line flags
	rootDir := flag.String("root", ".", "Root directory to start scanning")
	outputFile := flag.String("output", "complexity_analysis.csv", "Output CSV file")
	reportMD := flag.String("report", "complexity_report.md", "Output markdown report")
	concurrency := flag.Int("concurrency", 10, "Number of workers to process files")
	limit := flag.Int("limit", 25, "Limit for top complex files")
	flag.Parse()

	fmt.Println("Starting complexity analysis of UmbraCore codebase...")
	fmt.Printf("Root directory: %s\n", *rootDir)

	// Analyze the codebase
	results := analyzeCodebase(*rootDir, *concurrency, *limit)

	// Write results to CSV
	if err := writeResultsToCSV(results, *outputFile); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing results to CSV: %v\n", err)
	}

	// Write markdown report
	if err := writeMarkdownReport(results, *reportMD); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing markdown report: %v\n", err)
	}

	fmt.Printf("Analysis complete.\n")
	fmt.Printf("CSV results written to: %s\n", *outputFile)
	fmt.Printf("Markdown report written to: %s\n", *reportMD)
}

// analyzeCodebase analyses the entire codebase for complexity
func analyzeCodebase(rootDir string, concurrency int, limit int) *Results {
	results := &Results{
		Modules:        make([]*Module, 0),
		TopComplexFiles: make([]*ComplexityInfo, 0),
	}

	// Find Swift files
	var swiftFiles []string
	err := filepath.Walk(rootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		
		// Skip some directories
		if info.IsDir() {
			dir := info.Name()
			if dir == ".git" || dir == "bazel-bin" || dir == "bazel-out" || 
			   dir == "bazel-testlogs" || dir == "bazel-UmbraCore" || 
			   dir == "third_party" || dir == "node_modules" {
				return filepath.SkipDir
			}
			return nil
		}
		
		// Only process Swift files
		if filepath.Ext(path) == ".swift" {
			swiftFiles = append(swiftFiles, path)
		}
		
		return nil
	})
	
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error walking directory %s: %v\n", rootDir, err)
		return results
	}
	
	fmt.Printf("Found %d Swift files to analyze\n", len(swiftFiles))
	
	// Group files by module
	moduleMap := make(map[string]*Module)
	
	for _, filePath := range swiftFiles {
		// Extract module name from path
		relPath, err := filepath.Rel(rootDir, filePath)
		if err != nil {
			continue
		}
		
		parts := strings.Split(relPath, string(os.PathSeparator))
		if len(parts) < 2 {
			continue
		}
		
		var moduleName string
		if parts[0] == "Sources" && len(parts) >= 3 {
			moduleName = parts[1]
		} else if parts[0] == "Tests" && len(parts) >= 3 {
			moduleName = "Tests/" + parts[1]
		} else {
			moduleName = parts[0]
		}
		
		// Add file to module
		if _, ok := moduleMap[moduleName]; !ok {
			moduleDir := filepath.Join(rootDir, moduleName)
			moduleMap[moduleName] = &Module{
				Name:    moduleName,
				Path:    moduleDir,
				Files:   []string{},
				Metrics: []*ComplexityInfo{},
			}
		}
		
		moduleMap[moduleName].Files = append(moduleMap[moduleName].Files, filePath)
	}
	
	// Convert map to slice
	for _, module := range moduleMap {
		results.Modules = append(results.Modules, module)
	}
	
	// Sort modules by file count (descending)
	sort.Slice(results.Modules, func(i, j int) bool {
		return len(results.Modules[i].Files) > len(results.Modules[j].Files)
	})
	
	// Create a channel for the worker pool
	fileChan := make(chan struct {
		filePath  string
		moduleName string
	}, len(swiftFiles))
	
	metricsChan := make(chan *ComplexityInfo, len(swiftFiles))
	
	// Create workers
	var wg sync.WaitGroup
	for i := 0; i < concurrency; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for fileInfo := range fileChan {
				metrics := analyzeSwiftFile(fileInfo.filePath, fileInfo.moduleName)
				if metrics != nil {
					metricsChan <- metrics
				}
			}
		}()
	}

	// Send files to workers
	for _, module := range results.Modules {
		for _, filePath := range module.Files {
			fileChan <- struct {
				filePath   string
				moduleName string
			}{
				filePath:   filePath,
				moduleName: module.Name,
			}
		}
	}
	close(fileChan)
	
	// Collect results
	go func() {
		wg.Wait()
		close(metricsChan)
	}()
	
	// Process metrics
	var allMetrics []*ComplexityInfo
	for metrics := range metricsChan {
		// Add to module
		for _, module := range results.Modules {
			if module.Name == metrics.ModuleName {
				module.Metrics = append(module.Metrics, metrics)
				break
			}
		}
		
		// Add to all metrics
		allMetrics = append(allMetrics, metrics)
	}
	
	// Sort all metrics by complexity score (descending)
	sort.Slice(allMetrics, func(i, j int) bool {
		return allMetrics[i].ComplexityScore > allMetrics[j].ComplexityScore
	})
	
	// Get top complex files
	topLimit := limit
	if len(allMetrics) < topLimit {
		topLimit = len(allMetrics)
	}
	results.TopComplexFiles = allMetrics[:topLimit]
	
	return results
}

// analyzeSwiftFile analyzes a single Swift file for complexity
func analyzeSwiftFile(filePath string, moduleName string) *ComplexityInfo {
	file, err := os.Open(filePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening file %s: %v\n", filePath, err)
		return nil
	}
	defer file.Close()
	
	scanner := bufio.NewScanner(file)
	
	metrics := &ComplexityInfo{
		FilePath:          filePath,
		ModuleName:        moduleName,
		LOC:               0,
		FunctionCount:     0,
		MaxFunctionLength: 0,
		MaxNestLevel:      0,
		ControlStructures: 0,
		LongFunctions:     0,
		DeepNesting:       0,
	}
	
	var lines []string
	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, line)
		metrics.LOC++
	}
	
	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "Error reading file %s: %v\n", filePath, err)
		return nil
	}
	
	// Process the file for complexity metrics
	inFunction := false
	inComment := false
	functionStartLine := 0
	currentNestLevel := 0
	maxNestLevel := 0
	
	controlKeywords := []string{"if ", "guard ", "for ", "while ", "switch ", "do ", "catch "}
	
	for i, line := range lines {
		trimmedLine := strings.TrimSpace(line)
		
		// Skip empty lines
		if trimmedLine == "" {
			continue
		}
		
		// Handle comments
		if strings.HasPrefix(trimmedLine, "//") {
			continue
		}
		
		// Handle multi-line comments
		if strings.Contains(trimmedLine, "/*") {
			inComment = true
		}
		if inComment {
			if strings.Contains(trimmedLine, "*/") {
				inComment = false
			}
			continue
		}
		
		// Check for function declarations
		if (strings.Contains(trimmedLine, "func ") && !strings.HasSuffix(trimmedLine, ";")) ||
		   (strings.Contains(trimmedLine, "init(") && !strings.HasSuffix(trimmedLine, ";")) {
			if !inFunction {
				inFunction = true
				functionStartLine = i
				metrics.FunctionCount++
			}
		}
		
		// Check for control structures
		for _, keyword := range controlKeywords {
			if strings.Contains(trimmedLine, keyword) && !strings.HasPrefix(trimmedLine, "//") {
				metrics.ControlStructures++
			}
		}
		
		// Track nesting level
		if strings.Contains(trimmedLine, "{") {
			currentNestLevel++
			if currentNestLevel > maxNestLevel {
				maxNestLevel = currentNestLevel
			}
			
			// Track deep nesting (nesting level > 3)
			if currentNestLevel > 3 {
				metrics.DeepNesting++
			}
		}
		
		if strings.Contains(trimmedLine, "}") {
			// End of function check
			if inFunction && currentNestLevel == 1 {
				functionLength := i - functionStartLine
				if functionLength > metrics.MaxFunctionLength {
					metrics.MaxFunctionLength = functionLength
				}
				
				// Count long functions (>50 lines)
				if functionLength > 50 {
					metrics.LongFunctions++
				}
				
				inFunction = false
			}
			
			currentNestLevel--
			if currentNestLevel < 0 {
				currentNestLevel = 0 // Safety check
			}
		}
	}
	
	metrics.MaxNestLevel = maxNestLevel
	
	// Calculate average function length
	if metrics.FunctionCount > 0 {
		// Use a simple heuristic: total lines / function count
		// This is an approximation since we don't track exact function boundaries
		metrics.AvgFunctionLength = float64(metrics.LOC) / float64(metrics.FunctionCount)
	}
	
	// Calculate complexity score based on various metrics
	// This is a simple weighted formula that can be adjusted
	metrics.ComplexityScore = (float64(metrics.LOC) * 0.1) +
		(float64(metrics.ControlStructures) * 0.3) +
		(float64(metrics.MaxNestLevel) * 5.0) +
		(float64(metrics.LongFunctions) * 10.0) +
		(float64(metrics.DeepNesting) * 8.0) +
		(metrics.AvgFunctionLength * 0.5)
	
	return metrics
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
		"Module", 
		"File Path", 
		"Lines of Code", 
		"Function Count", 
		"Avg Function Length", 
		"Max Function Length", 
		"Max Nesting Level", 
		"Control Structures", 
		"Long Functions", 
		"Deep Nesting", 
		"Complexity Score",
	}
	
	if err := writer.Write(header); err != nil {
		return err
	}
	
	// Write data for each file, sorted by complexity score
	for _, metrics := range results.TopComplexFiles {
		row := []string{
			metrics.ModuleName,
			metrics.FilePath,
			strconv.Itoa(metrics.LOC),
			strconv.Itoa(metrics.FunctionCount),
			fmt.Sprintf("%.1f", metrics.AvgFunctionLength),
			strconv.Itoa(metrics.MaxFunctionLength),
			strconv.Itoa(metrics.MaxNestLevel),
			strconv.Itoa(metrics.ControlStructures),
			strconv.Itoa(metrics.LongFunctions),
			strconv.Itoa(metrics.DeepNesting),
			fmt.Sprintf("%.1f", metrics.ComplexityScore),
		}
		
		if err := writer.Write(row); err != nil {
			return err
		}
	}
	
	return nil
}

// writeMarkdownReport writes the analysis results to a markdown report
func writeMarkdownReport(results *Results, reportMD string) error {
	file, err := os.Create(reportMD)
	if err != nil {
		return err
	}
	defer file.Close()
	
	writer := bufio.NewWriter(file)
	defer writer.Flush()
	
	// Write report header
	fmt.Fprintf(writer, "# UmbraCore Complexity Analysis Report\n\n")
	fmt.Fprintf(writer, "## Overview\n\n")
	
	// Count total files and total LOC across all modules
	totalFiles := 0
	totalLOC := 0
	for _, module := range results.Modules {
		totalFiles += len(module.Files)
		for _, metrics := range module.Metrics {
			totalLOC += metrics.LOC
		}
	}
	
	fmt.Fprintf(writer, "- **Total modules analysed**: %d\n", len(results.Modules))
	fmt.Fprintf(writer, "- **Total files analysed**: %d\n", totalFiles)
	fmt.Fprintf(writer, "- **Total lines of code**: %d\n", totalLOC)
	fmt.Fprintf(writer, "- **Average lines per file**: %.1f\n\n", float64(totalLOC)/float64(totalFiles))
	
	// Write top complex files section
	fmt.Fprintf(writer, "## Top %d Most Complex Files\n\n", len(results.TopComplexFiles))
	fmt.Fprintf(writer, "These files have been identified as the most complex in the codebase based on various metrics including size, nesting depth, and control structure density. They are prime candidates for refactoring.\n\n")
	
	fmt.Fprintf(writer, "| Module | File | LOC | Functions | Avg Func Length | Max Nesting | Long Functions | Deep Nesting | Complexity Score |\n")
	fmt.Fprintf(writer, "|--------|------|-----|-----------|----------------|-------------|---------------|--------------|------------------|\n")
	
	for _, metrics := range results.TopComplexFiles {
		// Extract just the filename rather than full path
		filename := filepath.Base(metrics.FilePath)
		
		fmt.Fprintf(writer, "| %s | %s | %d | %d | %.1f | %d | %d | %d | %.1f |\n",
			metrics.ModuleName,
			filename,
			metrics.LOC,
			metrics.FunctionCount,
			metrics.AvgFunctionLength,
			metrics.MaxNestLevel,
			metrics.LongFunctions,
			metrics.DeepNesting,
			metrics.ComplexityScore)
	}
	
	fmt.Fprintf(writer, "\n## Complexity by Module\n\n")
	
	// Sort modules by average complexity score (descending)
	type ModuleComplexity struct {
		Name           string
		AvgComplexity  float64
		TotalLOC       int
		FileCount      int
		WorstFile      string
		WorstComplexity float64
	}
	
	var moduleComplexities []ModuleComplexity
	
	// Calculate module complexities
	for _, module := range results.Modules {
		if len(module.Metrics) == 0 {
			continue
		}
		
		var totalComplexity float64
		totalLOC := 0
		worstFile := ""
		worstComplexity := 0.0
		
		for _, metrics := range module.Metrics {
			totalComplexity += metrics.ComplexityScore
			totalLOC += metrics.LOC
			
			if metrics.ComplexityScore > worstComplexity {
				worstComplexity = metrics.ComplexityScore
				worstFile = filepath.Base(metrics.FilePath)
			}
		}
		
		avgComplexity := totalComplexity / float64(len(module.Metrics))
		
		moduleComplexities = append(moduleComplexities, ModuleComplexity{
			Name:           module.Name,
			AvgComplexity:  avgComplexity,
			TotalLOC:       totalLOC,
			FileCount:      len(module.Files),
			WorstFile:      worstFile,
			WorstComplexity: worstComplexity,
		})
	}
	
	// Sort by average complexity
	sort.Slice(moduleComplexities, func(i, j int) bool {
		return moduleComplexities[i].AvgComplexity > moduleComplexities[j].AvgComplexity
	})
	
	// Display top 10 most complex modules
	count := 10
	if len(moduleComplexities) < count {
		count = len(moduleComplexities)
	}
	
	fmt.Fprintf(writer, "### Top %d Most Complex Modules\n\n", count)
	fmt.Fprintf(writer, "| Module | Files | Total LOC | Avg Complexity | Most Complex File | Highest Complexity |\n")
	fmt.Fprintf(writer, "|--------|-------|-----------|----------------|-------------------|--------------------|\n")
	
	for i := 0; i < count; i++ {
		mc := moduleComplexities[i]
		fmt.Fprintf(writer, "| %s | %d | %d | %.1f | %s | %.1f |\n",
			mc.Name,
			mc.FileCount,
			mc.TotalLOC,
			mc.AvgComplexity,
			mc.WorstFile,
			mc.WorstComplexity)
	}
	
	// Recommendations section
	fmt.Fprintf(writer, "\n## Refactoring Recommendations\n\n")
	fmt.Fprintf(writer, "Based on the complexity analysis, here are some recommendations for improving code quality:\n\n")
	
	// Find files with excessive nesting
	var deeplyNestedFiles []*ComplexityInfo
	for _, metrics := range results.TopComplexFiles {
		if metrics.MaxNestLevel > 4 {
			deeplyNestedFiles = append(deeplyNestedFiles, metrics)
		}
	}
	
	// Find files with very long functions
	var longFunctionFiles []*ComplexityInfo
	for _, metrics := range results.TopComplexFiles {
		if metrics.MaxFunctionLength > 100 {
			longFunctionFiles = append(longFunctionFiles, metrics)
		}
	}
	
	if len(deeplyNestedFiles) > 0 {
		fmt.Fprintf(writer, "### High Nesting Depth\n\n")
		fmt.Fprintf(writer, "These files contain deeply nested code blocks (more than 4 levels deep) which can be difficult to follow and maintain:\n\n")
		
		for i, metrics := range deeplyNestedFiles {
			if i >= 5 {
				break // Limit to top 5
			}
			fmt.Fprintf(writer, "- **%s** in module **%s** (max nesting: %d)\n", 
				filepath.Base(metrics.FilePath), 
				metrics.ModuleName,
				metrics.MaxNestLevel)
		}
		
		fmt.Fprintf(writer, "\n**Recommendation**: Consider extracting nested blocks into separate functions with descriptive names. Use early returns or guard clauses to reduce nesting.\n\n")
	}
	
	if len(longFunctionFiles) > 0 {
		fmt.Fprintf(writer, "### Excessively Long Functions\n\n")
		fmt.Fprintf(writer, "These files contain very long functions (over 100 lines) which can be difficult to understand and test:\n\n")
		
		for i, metrics := range longFunctionFiles {
			if i >= 5 {
				break // Limit to top 5
			}
			fmt.Fprintf(writer, "- **%s** in module **%s** (max function length: %d lines)\n", 
				filepath.Base(metrics.FilePath), 
				metrics.ModuleName,
				metrics.MaxFunctionLength)
		}
		
		fmt.Fprintf(writer, "\n**Recommendation**: Break down long functions into smaller, more focused functions that each do one thing well.\n\n")
	}
	
	// General recommendations
	fmt.Fprintf(writer, "### General Refactoring Strategies\n\n")
	fmt.Fprintf(writer, "1. **Extract Method**: Identify blocks of code that work together and move them into their own functions with descriptive names.\n\n")
	fmt.Fprintf(writer, "2. **Replace Conditionals with Polymorphism**: If there are large switch statements or if-else chains, consider using polymorphism instead.\n\n")
	fmt.Fprintf(writer, "3. **Introduce Parameter Object**: For functions with many parameters, group related parameters into a single object.\n\n")
	fmt.Fprintf(writer, "4. **Extract Class**: If a class has too many responsibilities, split it into multiple classes each with a single responsibility.\n\n")
	fmt.Fprintf(writer, "5. **Replace Temporary with Query**: Instead of using temporary variables, extract the expression into a function.\n\n")
	
	// Conclusion
	fmt.Fprintf(writer, "## Conclusion\n\n")
	fmt.Fprintf(writer, "This analysis identifies the most complex parts of the UmbraCore codebase that may benefit from refactoring. Focus on the top files and modules for the highest potential improvement in code maintainability.\n\n")
	fmt.Fprintf(writer, "Refactoring should be done incrementally with thorough testing to ensure no functionality is broken.\n")
	
	return nil
}
