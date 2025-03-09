package main

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// FileInfo stores information about a file
type FileInfo struct {
	Path         string
	Size         int64
	Lines        int
	IsSwift      bool
	Package      string
	Imports      []string
	ErrorDef     bool // Whether file defines an error type
	ErrorTypes   []string
	ErrorCases   []string
	ErrorDomains []string
}

// Basic stats about the codebase
type AnalysisStats struct {
	TotalFiles      int
	TotalSwiftFiles int
	TotalLines      int
	FilesWithErrors int
	Directories     map[string]int // Directory -> file count
	ErrorTypes      map[string][]string // Error type -> files containing it
	ErrorCases      map[string][]string // Error case -> files containing it
	ErrorDomains    map[string][]string // Error domain -> files containing it
	CommonWords     map[string]int      // Common words in error definitions
}

// Regular expressions for parsing Swift files
var (
	// Find error type definitions (enum, struct, or class with Error in name)
	errorTypeRegex  = regexp.MustCompile(`(?m)(enum|struct|class)\s+(\w+Error)\b`)
	
	// Find error domain definitions
	errorDomainRegex = regexp.MustCompile(`(?m)(static\s+)?let\s+(\w+)ErrorDomain\s*=\s*"([\w\.]+)"`)
	
	// Find imports
	importRegex     = regexp.MustCompile(`(?m)import\s+(\w+)`)
)

// Extracts individual case names from an enum block
func extractErrorCases(content string) []string {
	var cases []string
	
	// Find enum blocks that contain error types
	enumBlockRegex := regexp.MustCompile(`(?ms)enum\s+(\w+Error)[^{]*\{(.*?)\}`)
	enumBlocks := enumBlockRegex.FindAllStringSubmatch(content, -1)
	
	for _, block := range enumBlocks {
		enumBody := block[2]
		
		// Find all case declarations within the enum body
		// This pattern looks for lines starting with "case" followed by a name and optional parameters
		caseRegex := regexp.MustCompile(`(?m)^\s*case\s+([a-zA-Z0-9_]+)(\(.*\))?`)
		caseMatches := caseRegex.FindAllStringSubmatch(enumBody, -1)
		
		for _, caseMatch := range caseMatches {
			caseName := caseMatch[1]
			// Skip Swift keywords that might be mistakenly matched
			if !isSwiftKeyword(caseName) {
				cases = append(cases, caseName)
			}
		}
	}
	
	return cases
}

// Check if a string is a Swift keyword
func isSwiftKeyword(word string) bool {
	keywords := map[string]bool{
		"let": true, "var": true, "if": true, "else": true, "guard": true, 
		"return": true, "class": true, "struct": true, "enum": true, 
		"func": true, "for": true, "while": true, "switch": true, "case": true,
		"public": true, "private": true, "internal": true, "static": true,
		"self": true, "try": true, "catch": true, "throw": true, "throws": true,
		"typealias": true, "protocol": true, "extension": true, "import": true,
		"as": true, "is": true, "nil": true, "true": true, "false": true,
	}
	return keywords[word]
}

func main() {
	rootDir := "/Users/mpy/CascadeProjects/UmbraCore/Sources/ErrorHandling"
	
	// Initialize stats
	stats := AnalysisStats{
		Directories:  make(map[string]int),
		ErrorTypes:   make(map[string][]string),
		ErrorCases:   make(map[string][]string),
		ErrorDomains: make(map[string][]string),
		CommonWords:  make(map[string]int),
	}
	
	// Store file info for all files
	var files []FileInfo
	
	// Walk the directory tree
	err := filepath.Walk(rootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Printf("Error accessing path %s: %v\n", path, err)
			return err
		}
		
		// Skip directories, we only analyze files
		if info.IsDir() {
			// Record directory
			relPath, _ := filepath.Rel(rootDir, path)
			if relPath == "" {
				relPath = "."
			}
			stats.Directories[relPath] = 0
			return nil
		}
		
		// Get relative path
		relPath, _ := filepath.Rel(rootDir, path)
		
		// Record file count in directory
		dir := filepath.Dir(relPath)
		stats.Directories[dir]++
		
		// Skip non-Swift files
		if !strings.HasSuffix(path, ".swift") {
			stats.TotalFiles++
			return nil
		}
		
		// Read file content
		content, err := os.ReadFile(path)
		if err != nil {
			fmt.Printf("Error reading file %s: %v\n", path, err)
			return nil
		}
		
		contentStr := string(content)
		
		// Count lines
		lines := strings.Count(contentStr, "\n") + 1
		stats.TotalSwiftFiles++
		stats.TotalLines += lines
		
		// Extract error types, cases, and domains
		var errorTypes []string
		var errorCases []string
		var errorDomains []string
		var imports []string
		
		// Find error type definitions
		typeMatches := errorTypeRegex.FindAllStringSubmatch(contentStr, -1)
		hasErrorDef := len(typeMatches) > 0
		
		if hasErrorDef {
			stats.FilesWithErrors++
			
			// Extract error types
			for _, match := range typeMatches {
				errorType := match[2]
				errorTypes = append(errorTypes, errorType)
				stats.ErrorTypes[errorType] = append(stats.ErrorTypes[errorType], relPath)
				
				// Add words for frequency analysis
				words := strings.FieldsFunc(errorType, func(r rune) bool {
					return r == '_' || r == ' ' || r == '.' 
				})
				for _, word := range words {
					if word != "Error" {
						stats.CommonWords[word]++
					}
				}
			}
			
			// Extract error cases using the separate function
			extractedCases := extractErrorCases(contentStr)
			for _, errorCase := range extractedCases {
				errorCases = append(errorCases, errorCase)
				stats.ErrorCases[errorCase] = append(stats.ErrorCases[errorCase], relPath)
				
				// Add words for frequency analysis
				words := strings.FieldsFunc(errorCase, func(r rune) bool {
					return r == '_' || r == ' ' || r == '.' 
				})
				for _, word := range words {
					stats.CommonWords[word]++
				}
			}
		}
		
		// Find error domains
		domainMatches := errorDomainRegex.FindAllStringSubmatch(contentStr, -1)
		for _, match := range domainMatches {
			domainName := match[2]
			domainValue := match[3]
			errorDomains = append(errorDomains, domainName + "=" + domainValue)
			stats.ErrorDomains[domainName] = append(stats.ErrorDomains[domainName], relPath)
		}
		
		// Find imports
		importMatches := importRegex.FindAllStringSubmatch(contentStr, -1)
		for _, match := range importMatches {
			imports = append(imports, match[1])
		}
		
		// Create file info
		fileInfo := FileInfo{
			Path:         relPath,
			Size:         info.Size(),
			Lines:        lines,
			IsSwift:      true,
			Imports:      imports,
			ErrorDef:     hasErrorDef,
			ErrorTypes:   errorTypes,
			ErrorCases:   errorCases,
			ErrorDomains: errorDomains,
		}
		
		files = append(files, fileInfo)
		stats.TotalFiles++
		return nil
	})
	
	if err != nil {
		fmt.Printf("Error walking directory tree: %v\n", err)
		os.Exit(1)
	}
	
	// Print summary report
	fmt.Println("# ErrorHandling Module Analysis")
	fmt.Println()
	fmt.Printf("- Total files: %d\n", stats.TotalFiles)
	fmt.Printf("- Swift files: %d\n", stats.TotalSwiftFiles)
	fmt.Printf("- Total lines of code: %d\n", stats.TotalLines)
	fmt.Printf("- Files with error definitions: %d\n", stats.FilesWithErrors)
	fmt.Println()
	
	fmt.Println("## Directory Structure")
	fmt.Println()
	for dir, count := range stats.Directories {
		fmt.Printf("- %s: %d files\n", dir, count)
	}
	fmt.Println()
	
	fmt.Println("## Error Types (potentially duplicated across files)")
	fmt.Println()
	// Sort error types by frequency
	type errorTypeCount struct {
		name  string
		count int
	}
	var errorTypeCounts []errorTypeCount
	for errorType, files := range stats.ErrorTypes {
		if len(files) > 0 {
			errorTypeCounts = append(errorTypeCounts, errorTypeCount{errorType, len(files)})
		}
	}
	
	sort.Slice(errorTypeCounts, func(i, j int) bool {
		return errorTypeCounts[i].count > errorTypeCounts[j].count
	})
	
	for _, etc := range errorTypeCounts {
		files := stats.ErrorTypes[etc.name]
		fmt.Printf("- **%s** (%d occurrences):\n", etc.name, etc.count)
		for _, file := range files {
			fmt.Printf("  - %s\n", file)
		}
	}
	fmt.Println()
	
	fmt.Println("## Common Error Cases (across different error types)")
	fmt.Println()
	// Sort error cases by frequency
	type errorCaseCount struct {
		name  string
		count int
	}
	var errorCaseCounts []errorCaseCount
	for errorCase, files := range stats.ErrorCases {
		if len(files) > 1 {
			errorCaseCounts = append(errorCaseCounts, errorCaseCount{errorCase, len(files)})
		}
	}
	
	sort.Slice(errorCaseCounts, func(i, j int) bool {
		return errorCaseCounts[i].count > errorCaseCounts[j].count
	})
	
	// Only display the error cases if we have any
	if len(errorCaseCounts) > 0 {
		for _, ecc := range errorCaseCounts[:min(20, len(errorCaseCounts))] {
			files := stats.ErrorCases[ecc.name]
			fmt.Printf("- **%s** (%d occurrences):\n", ecc.name, ecc.count)
			for _, file := range files {
				fmt.Printf("  - %s\n", file)
			}
		}
	} else {
		fmt.Println("No common error cases found across different error types.")
	}
	fmt.Println()
	
	fmt.Println("## Error Domains")
	fmt.Println()
	// Sort error domains alphabetically
	var domains []string
	for domain := range stats.ErrorDomains {
		domains = append(domains, domain)
	}
	sort.Strings(domains)
	
	if len(domains) > 0 {
		for _, domain := range domains {
			files := stats.ErrorDomains[domain]
			fmt.Printf("- **%s** (%d occurrences):\n", domain, len(files))
			for _, file := range files {
				fmt.Printf("  - %s\n", file)
			}
		}
	} else {
		fmt.Println("No error domains found.")
	}
	fmt.Println()
	
	fmt.Println("## Common Words in Error Definitions")
	fmt.Println()
	// Sort words by frequency
	type wordCount struct {
		word  string
		count int
	}
	var wordCounts []wordCount
	for word, count := range stats.CommonWords {
		if count > 1 && len(word) > 3 {
			wordCounts = append(wordCounts, wordCount{word, count})
		}
	}
	
	sort.Slice(wordCounts, func(i, j int) bool {
		return wordCounts[i].count > wordCounts[j].count
	})
	
	fmt.Println("Most common words in error type and case names:")
	if len(wordCounts) > 0 {
		for _, wc := range wordCounts[:min(25, len(wordCounts))] {
			fmt.Printf("- %s: %d occurrences\n", wc.word, wc.count)
		}
	} else {
		fmt.Println("No common words found.")
	}
	fmt.Println()
	
	fmt.Println("## Files by Size (lines of code)")
	fmt.Println()
	
	// Sort files by line count
	sort.Slice(files, func(i, j int) bool {
		return files[i].Lines > files[j].Lines
	})
	
	for _, file := range files[:min(20, len(files))] {
		fmt.Printf("- %s: %d lines\n", file.Path, file.Lines)
	}
	fmt.Println()
	
	fmt.Println("## Potential Refactoring Recommendations")
	fmt.Println()
	fmt.Println("Based on this analysis, consider:")
	fmt.Println()
	fmt.Println("1. Consolidating duplicate error types:")
	foundDuplicates := false
	for _, etc := range errorTypeCounts {
		if etc.count > 1 {
			fmt.Printf("   - %s (%d occurrences)\n", etc.name, etc.count)
			foundDuplicates = true
		}
	}
	if !foundDuplicates {
		fmt.Println("   - No duplicate error types found")
	}
	fmt.Println()
	
	fmt.Println("2. Standardising error cases that appear in multiple types:")
	if len(errorCaseCounts) > 0 {
		for _, ecc := range errorCaseCounts[:min(10, len(errorCaseCounts))] {
			if ecc.count > 1 {
				fmt.Printf("   - %s (%d occurrences)\n", ecc.name, ecc.count)
			}
		}
	} else {
		fmt.Println("   - No common error cases found")
	}
	fmt.Println()
	
	fmt.Println("3. Reviewing largest files for potential splitting:")
	for _, file := range files[:min(5, len(files))] {
		fmt.Printf("   - %s: %d lines\n", file.Path, file.Lines)
	}
	
	// Add a section for UmbraErrors namespace structure analysis
	fmt.Println()
	fmt.Println("4. Error Namespace Structure Analysis:")
	fmt.Println("   - Review how the UmbraErrors namespace is structured")
	fmt.Println("   - Ensure consistent use of UmbraErrors.Security.Protocols pattern")
	fmt.Println("   - Validate error case naming conventions for consistency")
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
