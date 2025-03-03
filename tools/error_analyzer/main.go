package main

import (
	"bufio"
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// ErrorDefinition represents a parsed error definition
type ErrorDefinition struct {
	ModuleName  string
	ErrorName   string
	FilePath    string
	LineNumber  int
	IsEnum      bool
	CaseNames   []string
	IsPublic    bool
	ImportedBy  []string
	ReferencedBy []string
}

// ErrorReference captures where an error type is referenced
type ErrorReference struct {
	ModuleName     string
	FilePath       string
	LineNumber     int
	ErrorName      string
	UsageContext   string
	IsImport       bool
	IsTypedef      bool
	IsDeclaration  bool
	IsUsage        bool
}

// Module represents a Swift module
type Module struct {
	Name            string
	Path            string
	ErrorDefinitions []ErrorDefinition
	ErrorReferences  []ErrorReference
	Imports          []string
}

var (
	enumRegex       = regexp.MustCompile(`(?m)^\s*(public\s+)?enum\s+(\w+)(?:\s*:\s*Error)?`)
	importRegex     = regexp.MustCompile(`^\s*import\s+(\w+)`)
	caseRegex       = regexp.MustCompile(`^\s*case\s+([^(:]+)`)
	typealiasRegex  = regexp.MustCompile(`^\s*(public\s+)?typealias\s+(\w+)\s*=\s*(\w+)\.(\w+)`)
	errorUsageRegex = regexp.MustCompile(`\b(\w+)Error\b`)
)

func main() {
	rootDir := flag.String("dir", ".", "Root directory to scan")
	outputFile := flag.String("output", "error_analysis_report.md", "Output report file")
	flag.Parse()

	modules, err := scanModules(*rootDir)
	if err != nil {
		fmt.Printf("Error scanning modules: %v\n", err)
		os.Exit(1)
	}

	errorDefinitions, errorReferences := analyzeErrors(modules)
	
	err = generateReport(*outputFile, modules, errorDefinitions, errorReferences)
	if err != nil {
		fmt.Printf("Error generating report: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Scanned %d modules, found %d error definitions and %d references\n", 
		len(modules), len(errorDefinitions), len(errorReferences))
	fmt.Printf("Report generated at %s\n", *outputFile)
}

// scanModules scans the directory for Swift modules
func scanModules(rootDir string) ([]Module, error) {
	var modules []Module

	// Look for BUILD.bazel files which indicate modules
	err := filepath.Walk(rootDir, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() && (strings.HasPrefix(info.Name(), ".") || strings.HasPrefix(info.Name(), "_")) {
			return filepath.SkipDir
		}

		if info.Name() == "BUILD.bazel" {
			dir := filepath.Dir(path)
			moduleName := filepath.Base(dir)
			
			if isSwiftModule(path) {
				modules = append(modules, Module{
					Name: moduleName,
					Path: dir,
				})
			}
		}

		return nil
	})

	if err != nil {
		return nil, fmt.Errorf("error walking directory: %v", err)
	}

	return modules, nil
}

// isSwiftModule checks if a BUILD.bazel file defines a Swift module
func isSwiftModule(buildFile string) bool {
	content, err := os.ReadFile(buildFile)
	if err != nil {
		return false
	}

	return strings.Contains(string(content), "swift_library")
}

// analyzeErrors scans all files in the modules to find error definitions and references
func analyzeErrors(modules []Module) ([]ErrorDefinition, []ErrorReference) {
	var allErrorDefinitions []ErrorDefinition
	var allErrorReferences []ErrorReference

	for i, module := range modules {
		errorDefs, errorRefs := scanModuleForErrors(module)
		allErrorDefinitions = append(allErrorDefinitions, errorDefs...)
		allErrorReferences = append(allErrorReferences, errorRefs...)
		
		modules[i].ErrorDefinitions = errorDefs
		modules[i].ErrorReferences = errorRefs
	}

	// Process references to link them to definitions
	linkReferencesToDefinitions(allErrorDefinitions, allErrorReferences)

	return allErrorDefinitions, allErrorReferences
}

// scanModuleForErrors scans a module for error definitions and references
func scanModuleForErrors(module Module) ([]ErrorDefinition, []ErrorReference) {
	var errorDefinitions []ErrorDefinition
	var errorReferences []ErrorReference

	filepath.Walk(module.Path, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		if filepath.Ext(path) != ".swift" {
			return nil
		}

		defs, refs := scanFileForErrors(path, module.Name)
		errorDefinitions = append(errorDefinitions, defs...)
		errorReferences = append(errorReferences, refs...)

		return nil
	})

	return errorDefinitions, errorReferences
}

// scanFileForErrors scans a Swift file for error definitions and references
func scanFileForErrors(filePath string, moduleName string) ([]ErrorDefinition, []ErrorReference) {
	var errorDefinitions []ErrorDefinition
	var errorReferences []ErrorReference

	content, err := os.ReadFile(filePath)
	if err != nil {
		return nil, nil
	}

	lines := strings.Split(string(content), "\n")
	var currentEnum *ErrorDefinition
	var inEnum bool

	for i, line := range lines {
		lineNum := i + 1
		
		// Check for imports
		if matches := importRegex.FindStringSubmatch(line); matches != nil {
			importedModule := matches[1]
			errorReferences = append(errorReferences, ErrorReference{
				ModuleName:   moduleName,
				FilePath:     filePath,
				LineNumber:   lineNum,
				ErrorName:    importedModule,
				UsageContext: line,
				IsImport:     true,
			})
		}

		// Check for error enum definitions
		if matches := enumRegex.FindStringSubmatch(line); matches != nil {
			enumName := matches[2]
			if strings.HasSuffix(enumName, "Error") || strings.Contains(line, "Error") {
				isPublic := matches[1] != ""
				currentEnum = &ErrorDefinition{
					ModuleName: moduleName,
					ErrorName:  enumName,
					FilePath:   filePath,
					LineNumber: lineNum,
					IsEnum:     true,
					IsPublic:   isPublic,
				}
				inEnum = true
			}
		}

		// Check for cases in current enum
		if inEnum && currentEnum != nil {
			if matches := caseRegex.FindStringSubmatch(line); matches != nil {
				caseName := strings.TrimSpace(matches[1])
				currentEnum.CaseNames = append(currentEnum.CaseNames, caseName)
			}
			
			// Check for end of enum (simplified: we assume a closing brace at the start of a line ends the enum)
			if strings.TrimSpace(line) == "}" {
				errorDefinitions = append(errorDefinitions, *currentEnum)
				inEnum = false
				currentEnum = nil
			}
		}

		// Check for typealias declarations
		if matches := typealiasRegex.FindStringSubmatch(line); matches != nil {
			aliasName := matches[2]
			// We're not using sourceModule directly, but it's useful information for future extension
			// sourceModule := matches[3] // Commented out to avoid unused variable issue
			sourceName := matches[4]
			
			if strings.HasSuffix(aliasName, "Error") || strings.HasSuffix(sourceName, "Error") {
				errorReferences = append(errorReferences, ErrorReference{
					ModuleName:    moduleName,
					FilePath:      filePath,
					LineNumber:    lineNum,
					ErrorName:     sourceName,
					UsageContext:  line,
					IsTypedef:     true,
				})
			}
		}

		// Check for error usages
		for _, match := range errorUsageRegex.FindAllStringSubmatch(line, -1) {
			errorName := match[1]
			// Avoid counting the error definition itself as a usage
			if !inEnum || currentEnum == nil || currentEnum.ErrorName != errorName+"Error" {
				errorReferences = append(errorReferences, ErrorReference{
					ModuleName:    moduleName,
					FilePath:      filePath,
					LineNumber:    lineNum,
					ErrorName:     errorName + "Error",
					UsageContext:  line,
					IsUsage:       true,
				})
			}
		}
	}

	return errorDefinitions, errorReferences
}

// linkReferencesToDefinitions creates relationships between references and definitions
func linkReferencesToDefinitions(definitions []ErrorDefinition, references []ErrorReference) {
	// Create a map for quick lookup of definitions
	definitionMap := make(map[string]int) // key: ErrorName, value: index in definitions slice
	for i, def := range definitions {
		definitionMap[def.ErrorName] = i
	}

	// Link references to definitions
	for _, ref := range references {
		if idx, ok := definitionMap[ref.ErrorName]; ok {
			// Found a definition for this reference
			definitions[idx].ReferencedBy = append(definitions[idx].ReferencedBy, 
				fmt.Sprintf("%s:%s:%d", ref.ModuleName, ref.FilePath, ref.LineNumber))
			
			if ref.IsImport {
				definitions[idx].ImportedBy = append(definitions[idx].ImportedBy, ref.ModuleName)
			}
		}
	}
}

// generateReport creates a detailed Markdown report of the error analysis
func generateReport(outputFile string, modules []Module, definitions []ErrorDefinition, references []ErrorReference) error {
	file, err := os.Create(outputFile)
	if err != nil {
		return err
	}
	defer file.Close()

	w := bufio.NewWriter(file)
	defer w.Flush()

	// Report header
	fmt.Fprintf(w, "# UmbraCore Error Analysis Report\n\n")
	fmt.Fprintf(w, "Generated on: %s\n\n", os.Getenv("LANG"))
	fmt.Fprintf(w, "## Summary\n\n")
	fmt.Fprintf(w, "- **Total Modules Analyzed**: %d\n", len(modules))
	fmt.Fprintf(w, "- **Total Error Definitions**: %d\n", len(definitions))
	fmt.Fprintf(w, "- **Total Error References**: %d\n\n", len(references))

	// Module list
	fmt.Fprintf(w, "## Modules\n\n")
	for _, module := range modules {
		fmt.Fprintf(w, "- **%s** (%s)\n", module.Name, module.Path)
		fmt.Fprintf(w, "  - Error Definitions: %d\n", len(module.ErrorDefinitions))
		fmt.Fprintf(w, "  - Error References: %d\n", len(module.ErrorReferences))
	}
	fmt.Fprintf(w, "\n")

	// Error Definitions
	fmt.Fprintf(w, "## Error Definitions\n\n")
	for _, def := range definitions {
		fmt.Fprintf(w, "### %s (%s)\n\n", def.ErrorName, def.ModuleName)
		fmt.Fprintf(w, "- **File**: %s:%d\n", def.FilePath, def.LineNumber)
		fmt.Fprintf(w, "- **Public**: %v\n", def.IsPublic)
		fmt.Fprintf(w, "- **Cases**:\n")
		for _, caseName := range def.CaseNames {
			fmt.Fprintf(w, "  - %s\n", caseName)
		}
		fmt.Fprintf(w, "- **Imported By**: %v\n", def.ImportedBy)
		fmt.Fprintf(w, "- **Referenced By**: %d files\n\n", len(def.ReferencedBy))
	}

	// Duplicated Errors Analysis
	duplicatedErrors := findDuplicatedErrors(definitions)
	fmt.Fprintf(w, "## Duplicated Error Types\n\n")
	if len(duplicatedErrors) > 0 {
		for errorName, modules := range duplicatedErrors {
			fmt.Fprintf(w, "- **%s** defined in %d modules:\n", errorName, len(modules))
			for _, module := range modules {
				fmt.Fprintf(w, "  - %s\n", module)
			}
			fmt.Fprintf(w, "\n")
		}
	} else {
		fmt.Fprintf(w, "No duplicated error types found.\n\n")
	}

	// Migration Plan
	fmt.Fprintf(w, "## CoreErrors Migration Plan\n\n")
	fmt.Fprintf(w, "### 1. Proposed CoreErrors Module Structure\n\n")
	fmt.Fprintf(w, "```swift\n")
	fmt.Fprintf(w, "// CoreErrors/Sources/SecurityError.swift\n")
	fmt.Fprintf(w, "public enum SecurityError: Error, Sendable, Equatable {\n")
	fmt.Fprintf(w, "    // Consolidated cases from all existing SecurityError enums\n")
	fmt.Fprintf(w, "}\n\n")
	fmt.Fprintf(w, "// CoreErrors/Sources/NetworkError.swift\n")
	fmt.Fprintf(w, "public enum NetworkError: Error, Sendable, Equatable {\n")
	fmt.Fprintf(w, "    // Consolidated cases from all existing network-related error enums\n")
	fmt.Fprintf(w, "}\n")
	fmt.Fprintf(w, "```\n\n")

	fmt.Fprintf(w, "### 2. Migration Strategy\n\n")
	fmt.Fprintf(w, "1. Create the CoreErrors module with consolidated error definitions\n")
	fmt.Fprintf(w, "2. Add typealias in original modules for backward compatibility\n")
	fmt.Fprintf(w, "3. Update all modules to use CoreErrors\n")
	fmt.Fprintf(w, "4. Remove duplicate error definitions once migration is complete\n\n")

	fmt.Fprintf(w, "### 3. Migration Steps\n\n")
	fmt.Fprintf(w, "1. Create CoreErrors module\n")
	fmt.Fprintf(w, "2. For each duplicated error type:\n")
	fmt.Fprintf(w, "   - Consolidate all cases into CoreErrors\n")
	fmt.Fprintf(w, "   - Update original modules to import and use CoreErrors\n")
	fmt.Fprintf(w, "3. For each file referencing error types:\n")
	fmt.Fprintf(w, "   - Update import statements\n")
	fmt.Fprintf(w, "   - Fix any type ambiguity issues\n")
	fmt.Fprintf(w, "4. Run tests to validate changes\n")

	return nil
}

// findDuplicatedErrors identifies error types defined in multiple modules
func findDuplicatedErrors(definitions []ErrorDefinition) map[string][]string {
	errorModulesMap := make(map[string][]string)
	
	for _, def := range definitions {
		errorModulesMap[def.ErrorName] = append(errorModulesMap[def.ErrorName], def.ModuleName)
	}
	
	// Keep only duplicated errors
	duplicatedErrors := make(map[string][]string)
	for errorName, modules := range errorModulesMap {
		if len(modules) > 1 {
			duplicatedErrors[errorName] = modules
		}
	}
	
	return duplicatedErrors
}
