package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// Define patterns to search for that could indicate potential issues
var (
	// Namespace ambiguity patterns
	moduleEnumPattern = regexp.MustCompile(`(?m)public enum (SecurityProtocolsCore|XPCProtocolsCore)\s*\{`)

	// Error type casting patterns that might be problematic
	errorCastingPatterns = []*regexp.Regexp{
		regexp.MustCompile(`(?m)(let|var)\s+\w+\s*=\s*error\s+as\?\s+(SecurityError|SecurityProtocolsCore\.SecurityError|XPCProtocolsCore\.SecurityProtocolError|CoreErrors\.SecurityError)`),
		regexp.MustCompile(`(?m)if\s+let\s+\w+\s*=\s*error\s+as\?\s+(SecurityError|SecurityProtocolsCore\.SecurityError|XPCProtocolsCore\.SecurityProtocolError|CoreErrors\.SecurityError)`),
	}

	// Manual error mapping patterns
	manualErrorMappingPatterns = []*regexp.Regexp{
		regexp.MustCompile(`(?m)(switch|case).+(SecurityError|XPCSecurityError)`),
		regexp.MustCompile(`(?m)func\s+\w*map\w*Error`),
		regexp.MustCompile(`(?m)func\s+\w*to(\w*)Error`),
	}

	// Should be using the centralized mapper
	nonCentralizedMapperPatterns = []*regexp.Regexp{
		regexp.MustCompile(`(?m)(SecurityErrorMapper|ErrorMappers)\.to\w+Error\(`),
		regexp.MustCompile(`(?m)mapToSecurityError\(`),
		regexp.MustCompile(`(?m)mapToCoreError\(`),
		regexp.MustCompile(`(?m)mapToXPCError\(`),
	}

	// Centralized mapper usage (this is good)
	centralizedMapperPattern = regexp.MustCompile(`(?m)CoreErrors\.SecurityErrorMapper\.map(To\w+Error|From\w+Error)\(`)
)

type Issue struct {
	File        string
	Line        int
	Pattern     string
	Text        string
	Type        string
	Recommendation string
}

// List of files to exclude from analysis (e.g., the security mapper itself)
var excludeFiles = []string{
	// The central error mapper itself will contain error mapping code
	"SecurityErrorMapper.swift",
	// Test files may have intentional error conversions for testing
	"ErrorAdaptersTests.swift",
}

func shouldExcludeFile(path string) bool {
	for _, excludePattern := range excludeFiles {
		if strings.Contains(path, excludePattern) {
			return true
		}
	}
	return false
}

func main() {
	// Define command-line flags
	rootDir := flag.String("dir", ".", "Root directory to search")
	verbose := flag.Bool("verbose", false, "Show matched lines")
	includeAll := flag.Bool("include-all", false, "Include files that would normally be excluded")
	flag.Parse()

	// Get absolute path
	absRootDir, err := filepath.Abs(*rootDir)
	if err != nil {
		fmt.Printf("Error resolving path: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Scanning directory: %s\n", absRootDir)
	if !*includeAll {
		fmt.Println("Excluding files:", excludeFiles)
		fmt.Println("Use -include-all flag to analyze all files")
	}

	// Track statistics
	stats := struct {
		FilesScanned        int
		FilesWithIssues     int
		NamespaceAmbiguity  int
		ErrorCasting        int
		ManualErrorMapping  int
		NonCentralizedUsage int
		CentralizedUsage    int
	}{}

	// List to collect issues by category
	issuesByFile := make(map[string][]Issue)

	// Walk through all Swift files
	err = filepath.Walk(absRootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Skip non-Swift files
		if !strings.HasSuffix(path, ".swift") {
			return nil
		}

		// Skip directories
		if info.IsDir() {
			// Skip .git directory
			if info.Name() == ".git" {
				return filepath.SkipDir
			}
			return nil
		}

		// Skip excluded files
		if !*includeAll && shouldExcludeFile(path) {
			return nil
		}

		// Scan the file
		fileIssues, fileStats := scanFile(path, *verbose)
		stats.FilesScanned++
		if len(fileIssues) > 0 {
			stats.FilesWithIssues++
			relPath, _ := filepath.Rel(absRootDir, path)
			issuesByFile[relPath] = fileIssues
		}

		// Update stats
		stats.NamespaceAmbiguity += fileStats.namespaceAmbiguity
		stats.ErrorCasting += fileStats.errorCasting
		stats.ManualErrorMapping += fileStats.manualErrorMapping
		stats.NonCentralizedUsage += fileStats.nonCentralizedUsage
		stats.CentralizedUsage += fileStats.centralizedUsage

		return nil
	})

	if err != nil {
		fmt.Printf("Error walking directory: %v\n", err)
		os.Exit(1)
	}

	// Print statistics
	fmt.Println("\n=== Error Handling Analysis Results ===")
	fmt.Printf("Files scanned: %d\n", stats.FilesScanned)
	fmt.Printf("Files with potential issues: %d\n", stats.FilesWithIssues)
	fmt.Printf("\nIssues found by category:\n")
	fmt.Printf("1. Namespace ambiguity: %d\n", stats.NamespaceAmbiguity)
	fmt.Printf("2. Error type casting: %d\n", stats.ErrorCasting)
	fmt.Printf("3. Manual error mapping: %d\n", stats.ManualErrorMapping)
	fmt.Printf("4. Non-centralised mapper usage: %d\n", stats.NonCentralizedUsage)
	fmt.Printf("\nGood practices found:\n")
	fmt.Printf("- Centralised mapper usage: %d instances\n", stats.CentralizedUsage)

	// Sort files by path for consistent output
	var sortedFiles []string
	for file := range issuesByFile {
		sortedFiles = append(sortedFiles, file)
	}
	sort.Strings(sortedFiles)

	// Detailed issue report by file
	if len(issuesByFile) > 0 {
		fmt.Println("\n=== Files Requiring Attention ===")
		for _, file := range sortedFiles {
			issues := issuesByFile[file]
			
			// Count issue types in this file
			typeCounts := make(map[string]int)
			for _, issue := range issues {
				typeCounts[issue.Type]++
			}
			
			// Print file summary
			fmt.Printf("\n📄 %s\n", file)
			for issueType, count := range typeCounts {
				fmt.Printf("  - %s: %d issues\n", issueType, count)
			}
			
			// Print detailed issues if verbose
			if *verbose {
				fmt.Println("  Details:")
				for _, issue := range issues {
					fmt.Printf("  • Line %d: %s\n", issue.Line, issue.Text)
					fmt.Printf("    ↳ %s\n", issue.Recommendation)
				}
			}
		}
	}

	// Summary and action items
	fmt.Println("\n=== Recommendations ===")
	
	if stats.FilesWithIssues == 0 {
		fmt.Println("✅ No issues found! The codebase appears to be using the centralised error mapper consistently.")
	} else {
		fmt.Println("Here are the key refactoring actions needed:")
		
		if stats.NamespaceAmbiguity > 0 {
			fmt.Println("⚠️  Namespace Ambiguity:")
			fmt.Println("   Replace module-level enums with structs to avoid naming conflicts")
		}
		
		if stats.ErrorCasting > 0 {
			fmt.Println("⚠️  Error Type Casting:")
			fmt.Println("   Replace direct error type checking with CoreErrors.SecurityErrorMapper")
			fmt.Println("   Example: Replace 'if let error as? SecurityError' with 'CoreErrors.SecurityErrorMapper.mapToSPCError(error)'")
		}
		
		if stats.ManualErrorMapping > 0 {
			fmt.Println("⚠️  Manual Error Mapping:")
			fmt.Println("   Replace switch statements and custom mappers with centralised mapper calls")
		}
		
		if stats.NonCentralizedUsage > 0 {
			fmt.Println("⚠️  Non-Centralised Mapper Usage:")
			fmt.Println("   Update all error mapping calls to use CoreErrors.SecurityErrorMapper methods:")
			fmt.Println("   - mapToSPCError() for SecurityProtocolsCore.SecurityError")
			fmt.Println("   - mapToXPCError() for XPCProtocolsCore.SecurityError")
			fmt.Println("   - mapToCoreError() for CoreErrors.SecurityError")
		}
	}
}

func scanFile(filePath string, verbose bool) ([]Issue, struct {
	namespaceAmbiguity  int
	errorCasting        int
	manualErrorMapping  int
	nonCentralizedUsage int
	centralizedUsage    int
}) {
	stats := struct {
		namespaceAmbiguity  int
		errorCasting        int
		manualErrorMapping  int
		nonCentralizedUsage int
		centralizedUsage    int
	}{}

	file, err := os.Open(filePath)
	if err != nil {
		fmt.Printf("Error opening file %s: %v\n", filePath, err)
		return nil, stats
	}
	defer file.Close()

	var issues []Issue
	scanner := bufio.NewScanner(file)
	lineNum := 0

	// Read the entire file content
	var fileContent strings.Builder
	for scanner.Scan() {
		lineNum++
		line := scanner.Text()
		fileContent.WriteString(line)
		fileContent.WriteString("\n")

		// Check for namespace ambiguity
		if moduleEnumPattern.MatchString(line) {
			stats.namespaceAmbiguity++
			issues = append(issues, Issue{
				File:    filePath,
				Line:    lineNum,
				Pattern: "Module-level enum with same name as module",
				Text:    line,
				Type:    "Namespace Ambiguity",
				Recommendation: "Replace enum with struct to avoid namespace conflicts",
			})
		}

		// Check for error casting
		for _, pattern := range errorCastingPatterns {
			if pattern.MatchString(line) {
				stats.errorCasting++
				issues = append(issues, Issue{
					File:    filePath,
					Line:    lineNum,
					Pattern: pattern.String(),
					Text:    line,
					Type:    "Error Casting",
					Recommendation: "Replace with CoreErrors.SecurityErrorMapper.mapToSPCError(error)",
				})
			}
		}

		// Check for manual error mapping
		for _, pattern := range manualErrorMappingPatterns {
			if pattern.MatchString(line) {
				stats.manualErrorMapping++
				issues = append(issues, Issue{
					File:    filePath,
					Line:    lineNum,
					Pattern: pattern.String(),
					Text:    line,
					Type:    "Manual Error Mapping",
					Recommendation: "Replace with a call to the centralised CoreErrors.SecurityErrorMapper",
				})
			}
		}

		// Check for non-centralized mapper usage
		for _, pattern := range nonCentralizedMapperPatterns {
			if pattern.MatchString(line) {
				stats.nonCentralizedUsage++
				
				// Customize recommendation based on pattern
				var recommendation string
				if strings.Contains(line, "mapToSecurityError") {
					recommendation = "Replace with CoreErrors.SecurityErrorMapper.mapToSPCError(error)"
				} else if strings.Contains(line, "mapToCoreError") {
					recommendation = "Replace with CoreErrors.SecurityErrorMapper.mapToCoreError(error)"
				} else if strings.Contains(line, "mapToXPCError") {
					recommendation = "Replace with CoreErrors.SecurityErrorMapper.mapToXPCError(error)"
				} else {
					recommendation = "Update to use the centralised CoreErrors.SecurityErrorMapper"
				}
				
				issues = append(issues, Issue{
					File:    filePath,
					Line:    lineNum,
					Pattern: pattern.String(),
					Text:    line,
					Type:    "Non-Centralised Mapper",
					Recommendation: recommendation,
				})
			}
		}

		// Check for centralized mapper usage (good)
		if centralizedMapperPattern.MatchString(line) {
			stats.centralizedUsage++
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Printf("Error reading file %s: %v\n", filePath, err)
	}

	// Also perform content-based checks for multi-line patterns
	contentStr := fileContent.String()

	// Check for switch statements on error types (multi-line)
	switchPattern := regexp.MustCompile(`(?ms)switch\s+\w+\s*\{(\s*case\s+\.\w+:.*?)+\s*\}`)
	switchMatches := switchPattern.FindAllStringIndex(contentStr, -1)
	for _, match := range switchMatches {
		// Extract the switch statement
		switchStmt := contentStr[match[0]:match[1]]
		
		// Check if it's an error mapping switch
		if strings.Contains(switchStmt, "SecurityError") || 
		   strings.Contains(switchStmt, "XPCSecurityError") {
			// Count line numbers
			lineCount := strings.Count(contentStr[:match[0]], "\n") + 1
			stats.manualErrorMapping++
			issues = append(issues, Issue{
				File:    filePath,
				Line:    lineCount,
				Pattern: "Error mapping switch statement",
				Text:    switchStmt[:60] + "...", // Show beginning of switch
				Type:    "Complex Error Mapping",
				Recommendation: "Replace this switch statement with CoreErrors.SecurityErrorMapper.mapToSPCError() or mapToXPCError()",
			})
		}
	}

	return issues, stats
}
