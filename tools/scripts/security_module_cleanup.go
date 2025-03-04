package main

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

// Defines a module migration
type ModuleMigration struct {
	OldModule   string
	NewModule   string
	Description string
}

// Color codes for terminal output
const (
	ColorReset  = "\033[0m"
	ColorRed    = "\033[31m"
	ColorGreen  = "\033[32m"
	ColorYellow = "\033[33m"
	ColorBlue   = "\033[34m"
)

func main() {
	// Define command-line flags for each module
	securityUtils := flag.Bool("security-utils", false, "Migrate SecurityUtils to SecurityBridge")
	securityInterfacesProtocols := flag.Bool("security-interfaces-protocols", false, "Migrate SecurityInterfacesProtocols to SecurityProtocolsCore")
	securityInterfacesFoundationBridge := flag.Bool("security-interfaces-foundation-bridge", false, "Migrate SecurityInterfacesFoundationBridge to SecurityBridge")
	securityProviderBridge := flag.Bool("security-provider-bridge", false, "Migrate SecurityProviderBridge to SecurityBridge")
	dryRun := flag.Bool("dry-run", true, "Perform a dry run without making actual changes")
	
	sourceDir := flag.String("source-dir", "../Sources", "Directory containing the source files")
	
	flag.Parse()

	fmt.Printf("%sUmbraCore Security Module Migration Tool%s\n", ColorGreen, ColorReset)
	fmt.Println("This tool will help migrate dependencies from old modules to the new architecture")
	fmt.Println()
	
	if *dryRun {
		fmt.Printf("%sRunning in DRY RUN mode. No files will be modified.%s\n", ColorYellow, ColorReset)
	}

	// Define the migrations
	migrations := []ModuleMigration{}

	if *securityUtils {
		migrations = append(migrations, ModuleMigration{
			OldModule:   "SecurityUtils",
			NewModule:   "SecurityBridge",
			Description: "Migrating SecurityUtils to SecurityBridge",
		})
	}

	if *securityInterfacesProtocols {
		migrations = append(migrations, ModuleMigration{
			OldModule:   "SecurityInterfacesProtocols",
			NewModule:   "SecurityProtocolsCore",
			Description: "Migrating SecurityInterfacesProtocols to SecurityProtocolsCore",
		})
	}

	if *securityInterfacesFoundationBridge {
		migrations = append(migrations, ModuleMigration{
			OldModule:   "SecurityInterfacesFoundationBridge",
			NewModule:   "SecurityBridge",
			Description: "Migrating SecurityInterfacesFoundationBridge to SecurityBridge",
		})
	}

	if *securityProviderBridge {
		migrations = append(migrations, ModuleMigration{
			OldModule:   "SecurityProviderBridge",
			NewModule:   "SecurityBridge",
			Description: "Migrating SecurityProviderBridge to SecurityBridge",
		})
	}

	if len(migrations) == 0 {
		fmt.Printf("%sNo migrations selected. Use flags to specify which modules to migrate.%s\n", ColorYellow, ColorReset)
		fmt.Println("Example: ./security_module_cleanup -security-utils")
		flag.PrintDefaults()
		return
	}

	// Process each migration
	for _, migration := range migrations {
		fmt.Printf("%s%s%s\n", ColorGreen, migration.Description, ColorReset)
		
		// Process Swift imports
		swiftFiles, err := findSwiftFilesWithImport(*sourceDir, migration.OldModule)
		if err != nil {
			fmt.Printf("%sError finding Swift files: %v%s\n", ColorRed, err, ColorReset)
			continue
		}
		
		fmt.Printf("Found %d Swift files with import %s\n", len(swiftFiles), migration.OldModule)
		
		// Use concurrency for processing files
		var wg sync.WaitGroup
		fileCh := make(chan string, len(swiftFiles))
		
		// Create worker pool
		for i := 0; i < 5; i++ { // 5 concurrent workers
			wg.Add(1)
			go func() {
				defer wg.Done()
				for file := range fileCh {
					updateImport(file, migration.OldModule, migration.NewModule, *dryRun)
				}
			}()
		}
		
		// Send files to workers
		for _, file := range swiftFiles {
			fileCh <- file
		}
		close(fileCh)
		
		wg.Wait()
		
		// Process Bazel files
		bazelFiles, err := findBazelFilesWithDependency(*sourceDir, migration.OldModule)
		if err != nil {
			fmt.Printf("%sError finding Bazel files: %v%s\n", ColorRed, err, ColorReset)
			continue
		}
		
		fmt.Printf("Found %d Bazel files with dependency on %s\n", len(bazelFiles), migration.OldModule)
		
		// Process Bazel files concurrently
		bazelCh := make(chan string, len(bazelFiles))
		
		// Create worker pool
		for i := 0; i < 5; i++ {
			wg.Add(1)
			go func() {
				defer wg.Done()
				for file := range bazelCh {
					updateBazelDependency(file, migration.OldModule, migration.NewModule, *dryRun)
				}
			}()
		}
		
		// Send files to workers
		for _, file := range bazelFiles {
			bazelCh <- file
		}
		close(bazelCh)
		
		wg.Wait()
		
		fmt.Printf("%s%s migration complete. Verify that all functionality has been migrated.%s\n\n", 
			ColorYellow, migration.OldModule, ColorReset)
	}

	fmt.Printf("%sMigration process complete.%s\n", ColorGreen, ColorReset)
	if *dryRun {
		fmt.Printf("%sThis was a DRY RUN. No files were modified. Run with -dry-run=false to make actual changes.%s\n", 
			ColorYellow, ColorReset)
	} else {
		fmt.Println("After verification, you should:")
		fmt.Println("1. Build the project to check for compilation errors")
		fmt.Println("2. Run tests to ensure functionality is preserved")
		fmt.Println("3. Manually remove the old module directories once everything works")
	}
}

// Find all Swift files with a specific import
func findSwiftFilesWithImport(rootDir, importName string) ([]string, error) {
	var matches []string
	
	err := filepath.Walk(rootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		
		// Only process .swift files
		if !info.IsDir() && strings.HasSuffix(path, ".swift") {
			// Check if file contains the import
			content, err := ioutil.ReadFile(path)
			if err != nil {
				return err
			}
			
			if bytes.Contains(content, []byte(fmt.Sprintf("import %s", importName))) {
				matches = append(matches, path)
			}
		}
		
		return nil
	})
	
	return matches, err
}

// Find all BUILD.bazel files with a specific dependency
func findBazelFilesWithDependency(rootDir, dependencyName string) ([]string, error) {
	var matches []string
	
	err := filepath.Walk(rootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		
		// Only process BUILD.bazel files
		if !info.IsDir() && info.Name() == "BUILD.bazel" {
			// Check if file contains the dependency
			content, err := ioutil.ReadFile(path)
			if err != nil {
				return err
			}
			
			if bytes.Contains(content, []byte(fmt.Sprintf("//Sources/%s", dependencyName))) {
				matches = append(matches, path)
			}
		}
		
		return nil
	})
	
	return matches, err
}

// Update import statements in a Swift file
func updateImport(filePath, oldImport, newImport string, dryRun bool) {
	fmt.Printf("Processing file: %s\n", filePath)
	
	// Read the file
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		fmt.Printf("%sError reading file %s: %v%s\n", ColorRed, filePath, err, ColorReset)
		return
	}
	
	// Replace the import statement
	oldImportStmt := fmt.Sprintf("import %s", oldImport)
	newImportStmt := fmt.Sprintf("import %s", newImport)
	
	newContent := bytes.ReplaceAll(content, []byte(oldImportStmt), []byte(newImportStmt))
	
	// Check if any changes were made
	if bytes.Equal(content, newContent) {
		fmt.Printf("No changes needed in %s\n", filePath)
		return
	}
	
	if !dryRun {
		// Write the changes back to the file
		err = ioutil.WriteFile(filePath, newContent, 0644)
		if err != nil {
			fmt.Printf("%sError writing file %s: %v%s\n", ColorRed, filePath, err, ColorReset)
			return
		}
		fmt.Printf("%sUpdated import in %s%s\n", ColorGreen, filePath, ColorReset)
	} else {
		fmt.Printf("%s[DRY RUN] Would update import in %s%s\n", ColorBlue, filePath, ColorReset)
	}
}

// Update dependencies in a BUILD.bazel file
func updateBazelDependency(filePath, oldDep, newDep string, dryRun bool) {
	fmt.Printf("Processing Bazel file: %s\n", filePath)
	
	// Read the file
	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		fmt.Printf("%sError reading file %s: %v%s\n", ColorRed, filePath, err, ColorReset)
		return
	}
	
	// Replace the dependency
	oldDepStr := fmt.Sprintf("//Sources/%s", oldDep)
	newDepStr := fmt.Sprintf("//Sources/%s", newDep)
	
	newContent := bytes.ReplaceAll(content, []byte(oldDepStr), []byte(newDepStr))
	
	// Check if any changes were made
	if bytes.Equal(content, newContent) {
		fmt.Printf("No changes needed in %s\n", filePath)
		return
	}
	
	if !dryRun {
		// Write the changes back to the file
		err = ioutil.WriteFile(filePath, newContent, 0644)
		if err != nil {
			fmt.Printf("%sError writing file %s: %v%s\n", ColorRed, filePath, err, ColorReset)
			return
		}
		fmt.Printf("%sUpdated dependency in %s%s\n", ColorGreen, filePath, ColorReset)
	} else {
		fmt.Printf("%s[DRY RUN] Would update dependency in %s%s\n", ColorBlue, filePath, ColorReset)
	}
}
