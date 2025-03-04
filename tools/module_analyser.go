// UmbraCore Module Analyser
// This tool analyses module dependencies in the UmbraCore project
// and helps identify and remove redundant security modules.
package main

import (
	"bufio"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// Module represents a Swift module in the UmbraCore project
type Module struct {
	Name         string
	Path         string
	Dependencies []string
	Dependents   []string
	Usage        int
	IsRedundant  bool
}

// RedundantModuleSet defines modules identified as redundant in the refactoring plan
var RedundantModuleSet = map[string]bool{
	"SecurityInterfacesFoundationBase":     true,
	"SecurityInterfacesFoundationBridge":   true,
	"SecurityInterfacesFoundationCore":     true,
	"SecurityInterfacesFoundationMinimal":  true,
	"SecurityInterfacesFoundationNoFoundation": true,
	"SecurityProviderBridge":               true,
	"UmbraSecurityNoFoundation":            true,
	"UmbraSecurityServicesNoFoundation":    true,
	"UmbraSecurityFoundation":              true,
}

// ReplacementModules maps redundant modules to their replacements
var ReplacementModules = map[string]string{
	"SecurityInterfacesFoundationBase":     "SecurityProtocolsCore",
	"SecurityInterfacesFoundationBridge":   "SecurityBridge",
	"SecurityInterfacesFoundationCore":     "SecurityProtocolsCore",
	"SecurityInterfacesFoundationMinimal":  "SecurityProtocolsCore",
	"SecurityInterfacesFoundationNoFoundation": "SecurityProtocolsCore",
	"SecurityProviderBridge":               "SecurityBridge",
	"UmbraSecurityNoFoundation":            "UmbraSecurityCore",
	"UmbraSecurityServicesNoFoundation":    "UmbraSecurityCore",
	"UmbraSecurityFoundation":              "UmbraSecurityBridge",
}

// AnalysisResult contains the results of the module analysis
type AnalysisResult struct {
	Modules            map[string]*Module
	RedundantModules   []*Module
	MigrationRequired  map[string][]string // Map of files that need migration for each module
	TotalImports       int
	RedundantImports   int
	SafeToRemove       map[string]bool
}

func main() {
	fmt.Println("UmbraCore Module Analyser")
	fmt.Println("========================")
	
	// Get the project root directory
	projectRoot := os.Getenv("PROJECT_ROOT")
	if projectRoot == "" {
		cwd, err := os.Getwd()
		if err != nil {
			fmt.Println("Error getting current directory:", err)
			os.Exit(1)
		}
		// Try to find the UmbraCore root directory
		for {
			if _, err := os.Stat(filepath.Join(cwd, "UmbraCore_Refactoring_Plan.md")); err == nil {
				projectRoot = cwd
				break
			}
			parent := filepath.Dir(cwd)
			if parent == cwd {
				fmt.Println("Could not find UmbraCore project root")
				os.Exit(1)
			}
			cwd = parent
		}
	}
	
	fmt.Println("Project root:", projectRoot)
	
	// Run analysis
	result := analyseModules(projectRoot)
	
	// Print analysis results
	printAnalysisResults(result)
	
	// Ask for confirmation before modifying any files
	fmt.Print("\nDo you want to proceed with removing redundant modules? (y/n): ")
	reader := bufio.NewReader(os.Stdin)
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(response)
	
	if response == "y" || response == "Y" {
		removeRedundantModules(result, projectRoot)
	} else {
		fmt.Println("Operation cancelled. No files were modified.")
	}
}

// analyseModules scans the project for Swift modules and analyses their dependencies
func analyseModules(projectRoot string) *AnalysisResult {
	result := &AnalysisResult{
		Modules:           make(map[string]*Module),
		MigrationRequired: make(map[string][]string),
		SafeToRemove:      make(map[string]bool),
	}
	
	// Find all Swift modules in the Sources directory
	sourcesDir := filepath.Join(projectRoot, "Sources")
	entries, err := os.ReadDir(sourcesDir)
	if err != nil {
		fmt.Println("Error reading Sources directory:", err)
		os.Exit(1)
	}
	
	// Create Module objects for each module directory
	for _, entry := range entries {
		if entry.IsDir() {
			module := &Module{
				Name: entry.Name(),
				Path: filepath.Join(sourcesDir, entry.Name()),
				Dependencies: []string{},
				Dependents:   []string{},
				Usage:        0,
				IsRedundant:  RedundantModuleSet[entry.Name()],
			}
			result.Modules[entry.Name()] = module
		}
	}
	
	// Scan all Swift files to find import statements
	for _, module := range result.Modules {
		findDependencies(module, result)
	}
	
	// Build up the dependents list based on dependencies
	for name, module := range result.Modules {
		for _, dep := range module.Dependencies {
			if depModule, ok := result.Modules[dep]; ok {
				depModule.Dependents = append(depModule.Dependents, name)
			}
		}
	}
	
	// Collect redundant modules
	for _, module := range result.Modules {
		if module.IsRedundant {
			result.RedundantModules = append(result.RedundantModules, module)
		}
	}
	
	// Find all Swift files that import redundant modules
	findRedundantImports(projectRoot, result)
	
	// Determine which modules are safe to remove
	for _, module := range result.RedundantModules {
		// A module is safe to remove if there are no imports of it or all imports can be migrated
		if len(result.MigrationRequired[module.Name]) == 0 || module.Usage == len(result.MigrationRequired[module.Name]) {
			result.SafeToRemove[module.Name] = true
		} else {
			result.SafeToRemove[module.Name] = false
		}
	}
	
	return result
}

// findDependencies scans a module for import statements to build dependency list
func findDependencies(module *Module, result *AnalysisResult) {
	err := filepath.WalkDir(module.Path, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		
		if !d.IsDir() && strings.HasSuffix(path, ".swift") {
			// Read the file and look for import statements
			file, err := os.Open(path)
			if err != nil {
				return err
			}
			defer file.Close()
			
			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				line := scanner.Text()
				if strings.HasPrefix(line, "import ") {
					importedModule := strings.TrimSpace(strings.TrimPrefix(line, "import "))
					
					// Check if this is a module in our project
					if _, ok := result.Modules[importedModule]; ok {
						// Add to dependencies if not already there
						if !contains(module.Dependencies, importedModule) {
							module.Dependencies = append(module.Dependencies, importedModule)
						}
						
						// Track total imports
						result.TotalImports++
						
						// Track redundant imports
						if RedundantModuleSet[importedModule] {
							result.RedundantImports++
						}
					}
				}
			}
		}
		return nil
	})
	
	if err != nil {
		fmt.Printf("Error scanning module %s: %v\n", module.Name, err)
	}
}

// findRedundantImports scans the entire project for imports of redundant modules
func findRedundantImports(projectRoot string, result *AnalysisResult) {
	err := filepath.WalkDir(projectRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		
		if !d.IsDir() && strings.HasSuffix(path, ".swift") {
			// Read the file and look for import statements of redundant modules
			file, err := os.Open(path)
			if err != nil {
				return err
			}
			defer file.Close()
			
			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				line := scanner.Text()
				if strings.HasPrefix(line, "import ") {
					importedModule := strings.TrimSpace(strings.TrimPrefix(line, "import "))
					
					if RedundantModuleSet[importedModule] {
						// Add to MigrationRequired map
						result.MigrationRequired[importedModule] = append(result.MigrationRequired[importedModule], path)
						// Increment usage count for the module
						if module, ok := result.Modules[importedModule]; ok {
							module.Usage++
						}
					}
				}
			}
		}
		return nil
	})
	
	if err != nil {
		fmt.Printf("Error scanning for redundant imports: %v\n", err)
	}
}

// removeRedundantModules removes modules that are safe to remove and updates import statements
func removeRedundantModules(result *AnalysisResult, projectRoot string) {
	for _, module := range result.RedundantModules {
		if result.SafeToRemove[module.Name] {
			fmt.Printf("Removing module: %s\n", module.Name)
			
			// Create backup of the module
			backupDir := filepath.Join(projectRoot, "backup", time.Now().Format("20060102_150405"), module.Name)
			err := os.MkdirAll(backupDir, 0755)
			if err != nil {
				fmt.Printf("Error creating backup directory for %s: %v\n", module.Name, err)
				continue
			}
			
			err = filepath.WalkDir(module.Path, func(path string, d fs.DirEntry, err error) error {
				if err != nil {
					return err
				}
				
				// Skip the root directory
				if path == module.Path {
					return nil
				}
				
				relPath, err := filepath.Rel(module.Path, path)
				if err != nil {
					return err
				}
				
				destPath := filepath.Join(backupDir, relPath)
				
				if d.IsDir() {
					return os.MkdirAll(destPath, 0755)
				}
				
				// Copy file
				data, err := os.ReadFile(path)
				if err != nil {
					return err
				}
				
				return os.WriteFile(destPath, data, 0644)
			})
			
			if err != nil {
				fmt.Printf("Error backing up module %s: %v\n", module.Name, err)
				continue
			}
			
			// Update import statements in all files that import this module
			for _, filePath := range result.MigrationRequired[module.Name] {
				updateImports(filePath, module.Name, ReplacementModules[module.Name])
			}
			
			// Remove the module directory
			err = os.RemoveAll(module.Path)
			if err != nil {
				fmt.Printf("Error removing module directory %s: %v\n", module.Path, err)
			}
		} else {
			fmt.Printf("Module %s cannot be safely removed yet. Manual migration required.\n", module.Name)
		}
	}
}

// updateImports replaces import statements in a file
func updateImports(filePath string, oldModule string, newModule string) {
	// Read the file
	data, err := os.ReadFile(filePath)
	if err != nil {
		fmt.Printf("Error reading file %s: %v\n", filePath, err)
		return
	}
	
	// Convert to string for easier manipulation
	content := string(data)
	
	// Replace import statements
	oldImport := fmt.Sprintf("import %s", oldModule)
	newImport := fmt.Sprintf("import %s", newModule)
	
	// Check if the new module is already imported
	if strings.Contains(content, newImport) {
		// New module is already imported, just remove the old import
		content = strings.ReplaceAll(content, oldImport, "")
		// Clean up any blank lines created
		content = strings.ReplaceAll(content, "\n\n\n", "\n\n")
	} else {
		// Replace the old import with the new one
		content = strings.ReplaceAll(content, oldImport, newImport)
	}
	
	// Write back to the file
	err = os.WriteFile(filePath, []byte(content), 0644)
	if err != nil {
		fmt.Printf("Error writing to file %s: %v\n", filePath, err)
		return
	}
	
	fmt.Printf("Updated imports in %s\n", filePath)
}

// printAnalysisResults displays the analysis results
func printAnalysisResults(result *AnalysisResult) {
	fmt.Println("\nAnalysis Results:")
	fmt.Println("=================")
	fmt.Printf("Total modules: %d\n", len(result.Modules))
	fmt.Printf("Redundant modules: %d\n", len(result.RedundantModules))
	fmt.Printf("Total imports: %d\n", result.TotalImports)
	fmt.Printf("Redundant imports: %d (%.1f%%)\n", result.RedundantImports, 
		float64(result.RedundantImports)/float64(result.TotalImports)*100)
	
	fmt.Println("\nRedundant Modules:")
	fmt.Println("=================")
	for _, module := range result.RedundantModules {
		safeStatus := "SAFE TO REMOVE"
		if !result.SafeToRemove[module.Name] {
			safeStatus = "MANUAL MIGRATION REQUIRED"
		}
		
		fmt.Printf("- %s (%d imports, %d files) - %s\n", 
			module.Name, module.Usage, len(result.MigrationRequired[module.Name]), safeStatus)
		fmt.Printf("  Replacement: %s\n", ReplacementModules[module.Name])
	}
	
	fmt.Println("\nDetailed Migration Requirements:")
	fmt.Println("===============================")
	for _, module := range result.RedundantModules {
		fmt.Printf("Module: %s\n", module.Name)
		if len(result.MigrationRequired[module.Name]) == 0 {
			fmt.Println("  No files importing this module")
		} else {
			fmt.Printf("  Files requiring migration (%d):\n", len(result.MigrationRequired[module.Name]))
			for i, file := range result.MigrationRequired[module.Name] {
				if i < 10 {
					relPath, _ := filepath.Rel(filepath.Dir(file), file)
					fmt.Printf("  - %s\n", relPath)
				} else if i == 10 {
					fmt.Printf("  - ... and %d more files\n", len(result.MigrationRequired[module.Name])-10)
					break
				}
			}
		}
		fmt.Println()
	}
}

// contains checks if a string slice contains a specific string
func contains(slice []string, str string) bool {
	for _, item := range slice {
		if item == str {
			return true
		}
	}
	return false
}
