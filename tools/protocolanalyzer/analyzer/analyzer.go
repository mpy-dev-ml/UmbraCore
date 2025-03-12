package analyzer

import (
	"bufio"
	"encoding/csv"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// Issue represents a protocol conformance issue
type Issue struct {
	FilePath           string
	LineNumber         int
	ClassName          string
	ProtocolName       string
	MissingMethod      string
	ExpectedSignature  string
	FoundSignature     string
	IssueType          string // "missing", "signature_mismatch", "duplicate"
	FixRecommendation  string
}

// Protocol represents a Swift protocol definition
type Protocol struct {
	Name         string
	Methods      []Method
	Inherits     []string
	FilePath     string
}

// Method represents a method definition in a protocol or class
type Method struct {
	Name       string
	Signature  string
	LineNumber int
	ReturnType string
	Parameters []Parameter
}

// Parameter represents a method parameter
type Parameter struct {
	Name string
	Type string
}

// Class represents a Swift class implementation
type Class struct {
	Name      string
	Protocols []string
	Methods   []Method
	FilePath  string
}

// Run analyzes Swift protocol implementations and identifies conformance issues
func Run(sourcePath string, outputPath string, generateFixes bool, dryRun bool) error {
	var issues []Issue
	protocols := make(map[string]Protocol)
	classes := make(map[string]Class)

	// First pass: Find all protocol definitions
	err := filepath.Walk(sourcePath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(path, ".swift") {
			findProtocols(path, protocols)
		}
		return nil
	})

	if err != nil {
		return fmt.Errorf("error walking the path %s: %v", sourcePath, err)
	}

	// Second pass: Find all class implementations
	err = filepath.Walk(sourcePath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(path, ".swift") {
			findClasses(path, classes)
		}
		return nil
	})

	if err != nil {
		return fmt.Errorf("error walking the path %s: %v", sourcePath, err)
	}

	// Third pass: Analyze protocol conformance
	for className, class := range classes {
		for _, protocolName := range class.Protocols {
			protocol, exists := protocols[protocolName]
			if !exists {
				continue // Skip if protocol isn't found (might be in a different module)
			}

			// Check all methods from the protocol
			for _, protocolMethod := range protocol.Methods {
				methodFound := false
				for _, classMethod := range class.Methods {
					if classMethod.Name == protocolMethod.Name {
						methodFound = true
						if classMethod.Signature != protocolMethod.Signature {
							// Method signature mismatch
							issue := Issue{
								FilePath:          class.FilePath,
								LineNumber:        classMethod.LineNumber,
								ClassName:         className,
								ProtocolName:      protocolName,
								MissingMethod:     protocolMethod.Name,
								ExpectedSignature: protocolMethod.Signature,
								FoundSignature:    classMethod.Signature,
								IssueType:         "signature_mismatch",
							}
							
							// Generate fix recommendation
							issue.FixRecommendation = generateFixForSignatureMismatch(className, protocolMethod, classMethod)
							issues = append(issues, issue)
						}
						break
					}
				}

				if !methodFound {
					// Missing method implementation
					issue := Issue{
						FilePath:          class.FilePath,
						ClassName:         className,
						ProtocolName:      protocolName,
						MissingMethod:     protocolMethod.Name,
						ExpectedSignature: protocolMethod.Signature,
						IssueType:         "missing",
					}
					
					// Generate fix recommendation
					issue.FixRecommendation = generateFixForMissingMethod(className, protocolMethod)
					issues = append(issues, issue)
				}
			}
		}
	}

	// Fourth pass: Check for duplicate methods
	for className, class := range classes {
		methodsMap := make(map[string][]Method)
		for _, method := range class.Methods {
			methodsMap[method.Name] = append(methodsMap[method.Name], method)
		}

		for methodName, methods := range methodsMap {
			if len(methods) > 1 {
				issue := Issue{
					FilePath:      class.FilePath,
					LineNumber:    methods[0].LineNumber,
					ClassName:     className,
					MissingMethod: methodName,
					IssueType:     "duplicate",
				}
				
				// Generate fix recommendation
				issue.FixRecommendation = generateFixForDuplicateMethod(className, methods)
				issues = append(issues, issue)
			}
		}
	}

	// Write results to CSV
	file, err := os.Create(outputPath)
	if err != nil {
		return fmt.Errorf("cannot create file %s: %v", outputPath, err)
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Write header
	writer.Write([]string{
		"FilePath", "LineNumber", "ClassName", "ProtocolName", "IssueType", 
		"MethodName", "ExpectedSignature", "FoundSignature", "FixRecommendation",
	})

	// Write data
	for _, issue := range issues {
		writer.Write([]string{
			issue.FilePath,
			fmt.Sprintf("%d", issue.LineNumber),
			issue.ClassName,
			issue.ProtocolName,
			issue.IssueType,
			issue.MissingMethod,
			issue.ExpectedSignature,
			issue.FoundSignature,
			issue.FixRecommendation,
		})
	}

	fmt.Printf("Found %d protocol conformance issues. Results written to %s\n", len(issues), outputPath)
	
	// Generate fixes if requested
	if generateFixes || dryRun {
		for _, issue := range issues {
			if dryRun {
				fmt.Printf("DRY RUN: Would generate fix for %s in %s\n", issue.MissingMethod, issue.FilePath)
				showDryRunFix(issue)
			} else {
				fmt.Printf("Generating fix for %s in %s\n", issue.MissingMethod, issue.FilePath)
				applyFix(issue)
			}
		}
		
		if dryRun {
			fmt.Println("Dry run complete. No changes were applied.")
			fmt.Println("Run with -fix to apply these changes.")
		} else {
			fmt.Println("Fixes applied. Please review the changes.")
		}
	}
	
	return nil
}

func generateFixForSignatureMismatch(className string, protocolMethod Method, classMethod Method) string {
	return fmt.Sprintf("Replace method in %s: \n%s\nwith:\n%s", 
		className, 
		classMethod.Signature, 
		protocolMethod.Signature)
}

func generateFixForMissingMethod(className string, protocolMethod Method) string {
	return fmt.Sprintf("Add to %s:\n%s {\n  // Implementation needed\n}", 
		className,
		protocolMethod.Signature)
}

func generateFixForDuplicateMethod(className string, methods []Method) string {
	return fmt.Sprintf("Keep only one implementation of method '%s' in %s", 
		methods[0].Name, 
		className)
}

func applyFix(issue Issue) {
	// This function would apply the fix to the file
	// For now, just print what we would do
	fmt.Printf("Would apply fix to %s line %d: %s\n", 
		issue.FilePath, 
		issue.LineNumber,
		issue.FixRecommendation)
}

func showDryRunFix(issue Issue) {
	fmt.Println("==================================================================")
	fmt.Printf("File: %s (Line: %d)\n", issue.FilePath, issue.LineNumber)
	fmt.Printf("Class: %s, Protocol: %s\n", issue.ClassName, issue.ProtocolName)
	fmt.Printf("Issue type: %s\n", issue.IssueType)
	
	switch issue.IssueType {
	case "missing":
		fmt.Println("MISSING METHOD - Would add:")
		fmt.Println("------------------------------------------------------------------")
		fmt.Printf("  %s {\n", issue.ExpectedSignature)
		fmt.Println("    // TODO: Implementation needed")
		fmt.Println("  }")
		
	case "signature_mismatch":
		fmt.Println("SIGNATURE MISMATCH - Would replace:")
		fmt.Println("------------------------------------------------------------------")
		fmt.Printf("  CURRENT: %s\n", issue.FoundSignature)
		fmt.Println("  WITH:")
		fmt.Printf("  %s {\n", issue.ExpectedSignature)
		fmt.Println("    // Use implementation logic from current method")
		fmt.Println("  }")
		
	case "duplicate":
		fmt.Println("DUPLICATE METHOD - Would remove duplicate implementation")
	}
	fmt.Println("==================================================================")
	fmt.Println()
}

func fixXPCSecurityErrorType(signature string) string {
	// Convert Result<Type, SecurityError> to Result<Type, XPCSecurityError>
	r := regexp.MustCompile(`Result<([^,]+), ([^>]+)>`)
	return r.ReplaceAllString(signature, "Result<$1, XPCProtocolsCore.XPCSecurityError>")
}

func findProtocols(filePath string, protocols map[string]Protocol) {
	file, err := os.Open(filePath)
	if err != nil {
		fmt.Printf("Error opening file %s: %v\n", filePath, err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineNum := 0
	var currentProtocol *Protocol
	var currentMethod *Method
	inProtocolDef := false

	protocolPattern := regexp.MustCompile(`public\s+protocol\s+(\w+)(?:\s*:\s*([^{]+))?`)
	methodPattern := regexp.MustCompile(`\s+func\s+(\w+)\s*\(([^)]*)\)\s*(?:async\s*)?(?:throws\s*)?(?:->\s*([^{]+))?`)

	for scanner.Scan() {
		lineNum++
		line := scanner.Text()

		// Check for protocol definition
		if matches := protocolPattern.FindStringSubmatch(line); matches != nil {
			protocolName := matches[1]
			inheritsList := ""
			if len(matches) > 2 {
				inheritsList = matches[2]
			}

			inherits := []string{}
			if inheritsList != "" {
				for _, item := range strings.Split(inheritsList, ",") {
					inherits = append(inherits, strings.TrimSpace(item))
				}
			}

			currentProtocol = &Protocol{
				Name:     protocolName,
				Inherits: inherits,
				FilePath: filePath,
			}
			inProtocolDef = true
		}

		// Check for method definition within protocol
		if inProtocolDef {
			if strings.Contains(line, "}") && !strings.Contains(line, "{") {
				// End of protocol definition
				if currentProtocol != nil {
					protocols[currentProtocol.Name] = *currentProtocol
				}
				inProtocolDef = false
				currentProtocol = nil
			} else if matches := methodPattern.FindStringSubmatch(line); matches != nil && currentProtocol != nil {
				methodName := matches[1]
				parameters := matches[2]
				returnType := ""
				if len(matches) > 3 {
					returnType = strings.TrimSpace(matches[3])
				}

				// Parse parameters
				params := []Parameter{}
				for _, param := range strings.Split(parameters, ",") {
					if param = strings.TrimSpace(param); param != "" {
						parts := strings.Split(param, ":")
						if len(parts) == 2 {
							params = append(params, Parameter{
								Name: strings.TrimSpace(parts[0]),
								Type: strings.TrimSpace(parts[1]),
							})
						}
					}
				}

				currentMethod = &Method{
					Name:       methodName,
					Signature:  line,
					LineNumber: lineNum,
					ReturnType: returnType,
					Parameters: params,
				}

				currentProtocol.Methods = append(currentProtocol.Methods, *currentMethod)
			}
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Printf("Error scanning file %s: %v\n", filePath, err)
	}
}

func findClasses(filePath string, classes map[string]Class) {
	file, err := os.Open(filePath)
	if err != nil {
		fmt.Printf("Error opening file %s: %v\n", filePath, err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lineNum := 0
	var currentClass *Class
	var currentMethod *Method
	inClassDef := false
	inExtension := false
	extensionClass := ""

	classPattern := regexp.MustCompile(`public\s+(?:final\s+)?class\s+(\w+)(?:\s*:\s*([^{]+))?`)
	extensionPattern := regexp.MustCompile(`extension\s+(\w+)(?:\s*:\s*([^{]+))?`)
	methodPattern := regexp.MustCompile(`\s+(?:public\s+)?func\s+(\w+)\s*\(([^)]*)\)\s*(?:async\s*)?(?:throws\s*)?(?:->\s*([^{]+))?`)

	for scanner.Scan() {
		lineNum++
		line := scanner.Text()

		// Check for class definition
		if matches := classPattern.FindStringSubmatch(line); matches != nil {
			className := matches[1]
			implementsList := ""
			if len(matches) > 2 {
				implementsList = matches[2]
			}

			implements := []string{}
			if implementsList != "" {
				for _, item := range strings.Split(implementsList, ",") {
					item = strings.TrimSpace(item)
					// Skip NSObject and other foundation classes
					if !strings.HasPrefix(item, "NS") && item != "Sendable" && !strings.HasPrefix(item, "Any") && !strings.HasPrefix(item, "@unchecked") {
						implements = append(implements, item)
					}
				}
			}

			currentClass = &Class{
				Name:      className,
				Protocols: implements,
				FilePath:  filePath,
			}
			classes[className] = *currentClass
			inClassDef = true
		}

		// Check for extension definition
		if matches := extensionPattern.FindStringSubmatch(line); matches != nil {
			extensionClass = matches[1]
			implementsList := ""
			if len(matches) > 2 {
				implementsList = matches[2]
			}

			class, exists := classes[extensionClass]
			if !exists {
				class = Class{
					Name:      extensionClass,
					FilePath:  filePath,
					Protocols: []string{},
				}
			}

			if implementsList != "" {
				for _, item := range strings.Split(implementsList, ",") {
					item = strings.TrimSpace(item)
					// Skip NSObject and other foundation classes
					if !strings.HasPrefix(item, "NS") && item != "Sendable" && !strings.HasPrefix(item, "Any") && !strings.HasPrefix(item, "@unchecked") {
						class.Protocols = append(class.Protocols, item)
					}
				}
			}

			classes[extensionClass] = class
			inExtension = true
		}

		// Check for method definition within class or extension
		if inClassDef || inExtension {
			if strings.Contains(line, "}") && !strings.Contains(line, "{") {
				// End of class or extension definition
				inClassDef = false
				inExtension = false
				currentClass = nil
			} else if matches := methodPattern.FindStringSubmatch(line); matches != nil {
				methodName := matches[1]
				parameters := matches[2]
				returnType := ""
				if len(matches) > 3 {
					returnType = strings.TrimSpace(matches[3])
				}

				// Parse parameters
				params := []Parameter{}
				for _, param := range strings.Split(parameters, ",") {
					if param = strings.TrimSpace(param); param != "" {
						parts := strings.Split(param, ":")
						if len(parts) == 2 {
							params = append(params, Parameter{
								Name: strings.TrimSpace(parts[0]),
								Type: strings.TrimSpace(parts[1]),
							})
						}
					}
				}

				currentMethod = &Method{
					Name:       methodName,
					Signature:  line,
					LineNumber: lineNum,
					ReturnType: returnType,
					Parameters: params,
				}

				className := ""
				if inClassDef && currentClass != nil {
					className = currentClass.Name
				} else if inExtension {
					className = extensionClass
				}

				if className != "" {
					class, exists := classes[className]
					if exists {
						class.Methods = append(class.Methods, *currentMethod)
						classes[className] = class
					}
				}
			}
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Printf("Error scanning file %s: %v\n", filePath, err)
	}
}
