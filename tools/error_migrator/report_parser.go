package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

var (
	errorDefinitionHeaderRegex = regexp.MustCompile(`(.+?) \((.+?)\)$`)
	filePathRegex              = regexp.MustCompile(`^- \*\*File\*\*: (.+):(\d+)`)
	publicRegex                = regexp.MustCompile(`^- \*\*Public\*\*: (\w+)`)
	caseStartRegex             = regexp.MustCompile(`^- \*\*Cases\*\*:`)
	caseEntryRegex             = regexp.MustCompile(`^\s+- (.+)`)
	importedByRegex            = regexp.MustCompile(`^- \*\*Imported By\*\*: \[(.+)\]`)
	referencedByRegex          = regexp.MustCompile(`^- \*\*Referenced By\*\*: (\d+) files`)
	fileReferenceRegex         = regexp.MustCompile(`^\s+- (.+)`)
	duplicatedErrorRegex       = regexp.MustCompile(`^- \*\*(.+)\*\* defined in (\d+) modules:`)
	duplicatedErrorEntryRegex  = regexp.MustCompile(`^\s+- (.+)`)
)

// ParseErrorAnalysisReport parses an error analysis report file and extracts error definitions and duplicated errors
func ParseErrorAnalysisReport(reportPath string) (map[string]map[string]*ErrorDefinition, map[string][]string, error) {
	// Read the report file
	reportBytes, err := os.ReadFile(reportPath)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to read report file: %w", err)
	}

	// Convert to string
	report := string(reportBytes)
	fmt.Printf("Report length: %d bytes\n", len(report))

	// Initialize maps
	errorDefs := make(map[string]map[string]*ErrorDefinition)
	duplicatedErrors := make(map[string][]string)

	// Direct pattern matching for error definitions (test data has a specific format)
	lines := strings.Split(report, "\n")
	var currentErrorName, currentModuleName string
	inErrorDefs := false
	inDuplicatedErrors := false
	duplicatedErrorName := ""
	
	for i, line := range lines {
		// Detect section headers
		if strings.HasPrefix(line, "## Error Definitions") {
			inErrorDefs = true
			inDuplicatedErrors = false
			continue
		} else if strings.HasPrefix(line, "## Duplicated Error Types") {
			inErrorDefs = false
			inDuplicatedErrors = true
			continue
		} else if strings.HasPrefix(line, "## ") {
			// Any other section header
			inErrorDefs = false
			inDuplicatedErrors = false
			continue
		}
		
		// Parse error definitions
		if inErrorDefs {
			// Error definition header - format: "### ErrorName (ModuleName)"
			if strings.HasPrefix(line, "### ") {
				errorLine := strings.TrimPrefix(line, "### ")
				parts := strings.Split(errorLine, " (")
				if len(parts) == 2 && strings.HasSuffix(parts[1], ")") {
					currentErrorName = strings.TrimSpace(parts[0])
					currentModuleName = strings.TrimSuffix(parts[1], ")")
					
					// Create new error definition
					errorDef := &ErrorDefinition{
						ErrorName:       currentErrorName,
						ModuleName:      currentModuleName,
						CaseNames:       []string{},
						CaseDetails:     []string{},
						ImportedBy:      []string{},
						ReferencedFiles: []string{},
						IsEnum:          true,
					}
					
					// Add to map
					if _, exists := errorDefs[currentModuleName]; !exists {
						errorDefs[currentModuleName] = make(map[string]*ErrorDefinition)
					}
					errorDefs[currentModuleName][currentErrorName] = errorDef
					
					fmt.Printf("Found error: %s in module: %s\n", currentErrorName, currentModuleName)
				}
				continue
			}
			
			// If we have an error definition, parse its properties
			if currentErrorName != "" && currentModuleName != "" && errorDefs[currentModuleName][currentErrorName] != nil {
				errorDef := errorDefs[currentModuleName][currentErrorName]
				
				// File path - format: "- **File**: Path:LineNumber"
				if strings.HasPrefix(line, "- **File**:") {
					parts := strings.SplitN(line, ":", 3)
					if len(parts) >= 3 {
						errorDef.FilePath = strings.TrimPrefix(parts[1], " ")
						lineNum, _ := strconv.Atoi(parts[2])
						errorDef.LineNumber = lineNum
					}
				}
				
				// Public flag - format: "- **Public**: true/false"
				if strings.HasPrefix(line, "- **Public**:") {
					publicValue := strings.TrimPrefix(line, "- **Public**: ")
					errorDef.IsPublic = strings.TrimSpace(publicValue) == "true"
				}
				
				// Case names - format: "  - caseName"
				if strings.HasPrefix(line, "  - ") && i > 0 {
					// Check if we're in the cases section
					inCasesSection := false
					for j := i-1; j >= 0 && j >= i-5; j-- {
						if strings.Contains(lines[j], "**Cases**:") {
							inCasesSection = true
							break
						}
					}
					
					if inCasesSection {
						caseName := strings.TrimPrefix(line, "  - ")
						errorDef.CaseNames = append(errorDef.CaseNames, strings.TrimSpace(caseName))
						fmt.Printf("  Case: %s\n", strings.TrimSpace(caseName))
					}
				}
				
				// Imported by - format: "- **Imported By**: [Module1 Module2]"
				if strings.HasPrefix(line, "- **Imported By**:") {
					importedBy := strings.TrimPrefix(line, "- **Imported By**: ")
					if strings.HasPrefix(importedBy, "[") && strings.HasSuffix(importedBy, "]") {
						importedBy = importedBy[1 : len(importedBy)-1]
						errorDef.ImportedBy = strings.Split(importedBy, " ")
					}
				}
			}
		}
		
		// Parse duplicated errors
		if inDuplicatedErrors {
			// Error type header - format: "- **ErrorName** defined in N modules:"
			if strings.HasPrefix(line, "- **") && strings.Contains(line, "** defined in") {
				parts := strings.Split(line, "**")
				if len(parts) >= 2 {
					duplicatedErrorName = strings.TrimSpace(parts[1])
					duplicatedErrors[duplicatedErrorName] = []string{}
					fmt.Printf("Found duplicated error: %s\n", duplicatedErrorName)
				}
				continue
			}
			
			// Module name - format: "  - ModuleName"
			if strings.HasPrefix(line, "  - ") && duplicatedErrorName != "" {
				moduleName := strings.TrimPrefix(line, "  - ")
				moduleName = strings.TrimSpace(moduleName)
				duplicatedErrors[duplicatedErrorName] = append(duplicatedErrors[duplicatedErrorName], moduleName)
				fmt.Printf("  Module: %s\n", moduleName)
			}
		}
	}

	return errorDefs, duplicatedErrors, nil
}

// ExtractFileReferences processes error definitions to extract all files that reference an error type
func ExtractFileReferences(errorDefs map[string]map[string]*ErrorDefinition) map[string][]string {
	// Map of error type to list of files that reference it
	references := make(map[string][]string)
	
	for moduleName, defs := range errorDefs {
		for errorName, def := range defs {
			key := errorName + ":" + moduleName
			
			// Add files directly referencing this error
			for _, filePath := range def.ReferencedFiles {
				references[key] = append(references[key], filePath)
			}
		}
	}
	
	return references
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
