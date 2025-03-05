package main

import (
	"bufio"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// SwiftTransformer handles Swift code transformations
type SwiftTransformer struct {
	// Track state of the parser
	insideResultFunction bool
	functionIndentLevel  int
	currentIndent        int
	resultType           string
	errorType            string
}

// Configuration options
type Config struct {
	FilePath     string
	DryRun       bool
	CreateBackup bool
	Verbose      bool
}

func main() {
	// Parse command line flags
	filePath := flag.String("file", "", "Path to the Swift file to transform")
	dirPath := flag.String("dir", "", "Path to directory containing Swift files to transform")
	dryRun := flag.Bool("dry-run", false, "Perform a dry run without modifying files")
	skipBackup := flag.Bool("skip-backup", false, "Skip creating backup files")
	verbose := flag.Bool("verbose", false, "Enable verbose output")
	flag.Parse()

	if *filePath == "" && *dirPath == "" {
		log.Fatal("Either -file or -dir must be specified")
	}

	config := Config{
		DryRun:       *dryRun,
		CreateBackup: !*skipBackup,
		Verbose:      *verbose,
	}

	if *filePath != "" {
		// Process a single file
		processFile(*filePath, config)
	} else {
		// Process all Swift files in a directory
		err := filepath.Walk(*dirPath, func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if !info.IsDir() && strings.HasSuffix(path, ".swift") {
				processFile(path, config)
			}
			return nil
		})
		if err != nil {
			log.Fatalf("Error walking directory: %v", err)
		}
	}
}

func processFile(filePath string, config Config) {
	if config.Verbose {
		fmt.Printf("Processing: %s\n", filePath)
	}

	// Read the file
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	// Create a backup if requested
	if config.CreateBackup && !config.DryRun {
		backupPath := filePath + ".gobackup"
		if err := ioutil.WriteFile(backupPath, content, 0644); err != nil {
			log.Fatalf("Error creating backup: %v", err)
		}
		if config.Verbose {
			fmt.Printf("Created backup at: %s\n", backupPath)
		}
	}

	// Transform the content
	transformer := NewSwiftTransformer()
	transformed := transformer.TransformContent(string(content))

	// Print a diff if in verbose mode
	if config.Verbose {
		fmt.Println("Changes to be made:")
		printDiff(string(content), transformed)
	}

	// Write the transformed content back to the file
	if !config.DryRun {
		if err := ioutil.WriteFile(filePath, []byte(transformed), 0644); err != nil {
			log.Fatalf("Error writing transformed file: %v", err)
		}
		fmt.Printf("Successfully transformed: %s\n", filePath)
	} else {
		fmt.Printf("Dry run completed for: %s\n", filePath)
	}
}

// NewSwiftTransformer creates a new Swift transformer
func NewSwiftTransformer() *SwiftTransformer {
	return &SwiftTransformer{
		insideResultFunction: false,
		functionIndentLevel:  0,
		currentIndent:        0,
		resultType:           "",
		errorType:            "XPCSecurityError",
	}
}

// TransformContent applies all transformations to the content
func (t *SwiftTransformer) TransformContent(content string) string {
	// Apply transformations in sequence
	content = t.transformAsyncThrows(content)
	content = t.transformThrowStatements(content)
	content = t.transformReturnStatements(content)
	content = t.transformTryCatchBlocks(content)
	return content
}

// Transform async throws method signatures to Result pattern
func (t *SwiftTransformer) transformAsyncThrows(content string) string {
	// Pattern for method signatures with async throws
	asyncThrowsPattern := regexp.MustCompile(`(func\s+\w+)(\(.*?\))\s+async\s+throws\s+->\s+(\w+)`)
	return asyncThrowsPattern.ReplaceAllString(content, "$1$2 async -> Result<$3, XPCSecurityError>")
}

// Transform throw statements to return .failure
func (t *SwiftTransformer) transformThrowStatements(content string) string {
	// Common error patterns
	content = regexp.MustCompile(`throw\s+(\w+)Error\.(\w+)`).
		ReplaceAllString(content, "return .failure(.$2)")

	// More complex throw statements
	content = regexp.MustCompile(`throw\s+(\w+)Error\((.+?)\)`).
		ReplaceAllString(content, "return .failure(.custom(message: $2))")

	// Simple throw statements
	content = regexp.MustCompile(`throw\s+([^(]+)`).
		ReplaceAllString(content, "return .failure(.custom(message: \"$1\"))")

	return content
}

// Transform return statements in Result functions to wrap with .success
func (t *SwiftTransformer) transformReturnStatements(content string) string {
	lines := strings.Split(content, "\n")
	resultLines := make([]string, 0, len(lines))
	
	// Keep track of function state
	inResultFunction := false
	braceCount := 0
	resultType := ""
	
	// Pattern to identify functions that return Result
	resultFuncPattern := regexp.MustCompile(`func\s+\w+(?:\(.*?\))?\s+.*?->\s+Result<([^,]+),\s*[^>]+>`)
	
	for _, line := range lines {
		// Detect if we're entering a function that returns Result
		if matches := resultFuncPattern.FindStringSubmatch(line); len(matches) > 1 && !inResultFunction {
			inResultFunction = true
			resultType = matches[1]
			braceCount = 0
		}
		
		// Track brace count to know when we exit the function
		if inResultFunction {
			braceCount += strings.Count(line, "{")
			braceCount -= strings.Count(line, "}")
			
			// If we're in a Result function, transform return statements
			if braceCount > 0 && strings.Contains(line, "return ") && 
			   !strings.Contains(line, "return .success") && 
			   !strings.Contains(line, "return .failure") {
				returnPattern := regexp.MustCompile(`(\s*)(return\s+)([^.].*)`)
				line = returnPattern.ReplaceAllString(line, "$1$2.success($3)")
			}
			
			// Exit the function when braces balance out
			if braceCount <= 0 {
				inResultFunction = false
				resultType = ""
			}
		}
		
		resultLines = append(resultLines, line)
	}
	
	return strings.Join(resultLines, "\n")
}

// Transform try-catch blocks to Result pattern
func (t *SwiftTransformer) transformTryCatchBlocks(content string) string {
	// Pattern for simple try statements
	tryPattern := regexp.MustCompile(`(\s+)try\s+(\w+\([^)]*\))`)
	content = tryPattern.ReplaceAllString(content, "$1do { return .success(try $2) } catch { return .failure(.custom(message: $_.localizedDescription)) }")
	
	// Remove redundant try in success wrappers
	content = regexp.MustCompile(`return\s+\.success\(try\s+`).ReplaceAllString(content, "return .success(")
	
	return content
}

// Print a diff between original and transformed content
func printDiff(original, transformed string) {
	originalLines := strings.Split(original, "\n")
	transformedLines := strings.Split(transformed, "\n")
	
	// Find the minimum length
	minLen := len(originalLines)
	if len(transformedLines) < minLen {
		minLen = len(transformedLines)
	}
	
	// Print differences
	for i := 0; i < minLen; i++ {
		if originalLines[i] != transformedLines[i] {
			fmt.Printf("Line %d:\n- %s\n+ %s\n", i+1, originalLines[i], transformedLines[i])
		}
	}
	
	// Print any extra lines
	if len(originalLines) > len(transformedLines) {
		for i := minLen; i < len(originalLines); i++ {
			fmt.Printf("Line %d:\n- %s\n", i+1, originalLines[i])
		}
	} else if len(transformedLines) > len(originalLines) {
		for i := minLen; i < len(transformedLines); i++ {
			fmt.Printf("Line %d:\n+ %s\n", i+1, transformedLines[i])
		}
	}
}
