// security_module_consolidator.go
//
// A tool to automate the consolidation of UmbraCore security modules.
// This tool helps merge SecurityInterfacesProtocols and SecurityInterfacesBase
// into SecurityProtocolsCore to reduce module fragmentation.

package main

import (
	"bufio"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

const (
	// Base project directory
	projectDir = "/Users/mpy/CascadeProjects/UmbraCore"

	// Source modules to consolidate
	sourceModuleProtocols = "Sources/SecurityInterfacesProtocols"
	sourceModuleBase     = "Sources/SecurityInterfacesBase"

	// Target module
	targetModule = "Sources/SecurityProtocolsCore/Sources"

	// Directory for backing up original files
	backupDir = "/Users/mpy/CascadeProjects/UmbraCore/security_consolidation_backup"

	// Log file
	logFile = "/Users/mpy/CascadeProjects/UmbraCore/security_consolidation.log"
)

// Represents a module in the project
type Module struct {
	Name       string
	Path       string
	SwiftFiles []string
	BuildFile  string
}

// Represents an import statement change
type ImportChange struct {
	OldImport string
	NewImport string
}

var (
	// Import changes needed after consolidation
	importChanges = []ImportChange{
		{OldImport: "import SecurityInterfacesProtocols", NewImport: "import SecurityProtocolsCore"},
		{OldImport: "import SecurityInterfacesBase", NewImport: "import SecurityProtocolsCore"},
	}

	// Regular expressions
	importRegex        = regexp.MustCompile(`import\s+(SecurityInterfacesProtocols|SecurityInterfacesBase)`)
	depRegex           = regexp.MustCompile(`"//Sources/(SecurityInterfacesProtocols|SecurityInterfacesBase)"`)
	sourceModulePaths  = []string{sourceModuleProtocols, sourceModuleBase}
	
	// Logging
	logger *os.File
)

// Initialize the logger
func initLogger() error {
	var err error
	logger, err = os.Create(logFile)
	if err != nil {
		return fmt.Errorf("failed to create log file: %v", err)
	}
	return nil
}

// Log a message to both console and log file
func logMessage(message string) {
	fmt.Println(message)
	if logger != nil {
		logger.WriteString(message + "\n")
	}
}

// Create backup directory
func createBackupDir() error {
	if err := os.MkdirAll(backupDir, 0755); err != nil {
		return fmt.Errorf("failed to create backup directory: %v", err)
	}
	return nil
}

// Backup a file before modifying it
func backupFile(filePath string) error {
	// Create relative path for backup directory structure
	relPath, err := filepath.Rel(projectDir, filePath)
	if err != nil {
		return fmt.Errorf("failed to get relative path: %v", err)
	}

	// Create backup path
	backupPath := filepath.Join(backupDir, relPath)
	backupDir := filepath.Dir(backupPath)

	// Create directories
	if err := os.MkdirAll(backupDir, 0755); err != nil {
		return fmt.Errorf("failed to create backup directory: %v", err)
	}

	// Copy file
	input, err := os.ReadFile(filePath)
	if err != nil {
		return fmt.Errorf("failed to read source file: %v", err)
	}

	if err := os.WriteFile(backupPath, input, 0644); err != nil {
		return fmt.Errorf("failed to write backup file: %v", err)
	}

	logMessage(fmt.Sprintf("Backed up %s to %s", filePath, backupPath))
	return nil
}

// Find all Swift files in a directory
func findSwiftFiles(modulePath string) ([]string, error) {
	var files []string
	err := filepath.WalkDir(modulePath, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() && strings.HasSuffix(path, ".swift") {
			files = append(files, path)
		}
		return nil
	})
	return files, err
}

// Move Swift files from source modules to target module
func moveSwiftFiles() error {
	for _, sourceModulePath := range sourceModulePaths {
		fullSourcePath := filepath.Join(projectDir, sourceModulePath)
		files, err := findSwiftFiles(fullSourcePath)
		if err != nil {
			return fmt.Errorf("failed to find Swift files in %s: %v", fullSourcePath, err)
		}

		targetDir := filepath.Join(projectDir, targetModule, "Protocols")

		// Create target directory if it doesn't exist
		if err := os.MkdirAll(targetDir, 0755); err != nil {
			return fmt.Errorf("failed to create target directory: %v", err)
		}

		for _, file := range files {
			// Backup the file
			if err := backupFile(file); err != nil {
				return err
			}

			// Read file content
			content, err := os.ReadFile(file)
			if err != nil {
				return fmt.Errorf("failed to read file %s: %v", file, err)
			}

			// Create target file path
			fileName := filepath.Base(file)
			targetPath := filepath.Join(targetDir, fileName)

			// Check if target file already exists
			if _, err := os.Stat(targetPath); err == nil {
				// File exists, handle conflict
				logMessage(fmt.Sprintf("CONFLICT: Target file %s already exists", targetPath))
				targetPath = filepath.Join(targetDir, "Consolidated_"+fileName)
			}

			// Write content to target file
			if err := os.WriteFile(targetPath, content, 0644); err != nil {
				return fmt.Errorf("failed to write file %s: %v", targetPath, err)
			}

			logMessage(fmt.Sprintf("Moved %s to %s", file, targetPath))
		}
	}
	return nil
}

// Update import statements in Swift files
func updateImports() error {
	// Find all Swift files in the project
	var allSwiftFiles []string
	err := filepath.WalkDir(projectDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() && strings.HasSuffix(path, ".swift") {
			allSwiftFiles = append(allSwiftFiles, path)
		}
		return nil
	})
	if err != nil {
		return fmt.Errorf("failed to find Swift files: %v", err)
	}

	// Update imports in each file
	for _, file := range allSwiftFiles {
		// Skip files in the backup directory
		if strings.Contains(file, backupDir) {
			continue
		}

		// Read the file
		content, err := os.ReadFile(file)
		if err != nil {
			return fmt.Errorf("failed to read file %s: %v", file, err)
		}

		contentStr := string(content)
		modified := false

		// Check for import statements to update
		for _, change := range importChanges {
			if strings.Contains(contentStr, change.OldImport) {
				// Backup the file before modifying
				if err := backupFile(file); err != nil {
					return err
				}

				// Replace import
				contentStr = strings.ReplaceAll(contentStr, change.OldImport, change.NewImport)
				modified = true
			}
		}

		// Write updated content back if modified
		if modified {
			if err := os.WriteFile(file, []byte(contentStr), 0644); err != nil {
				return fmt.Errorf("failed to write file %s: %v", file, err)
			}
			logMessage(fmt.Sprintf("Updated imports in %s", file))
		}
	}
	return nil
}

// Update BUILD.bazel files to reflect consolidation
func updateBuildFiles() error {
	// Find all BUILD.bazel files
	var buildFiles []string
	err := filepath.WalkDir(projectDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() && (d.Name() == "BUILD.bazel" || d.Name() == "BUILD") {
			buildFiles = append(buildFiles, path)
		}
		return nil
	})
	if err != nil {
		return fmt.Errorf("failed to find BUILD files: %v", err)
	}

	// Update each BUILD file
	for _, file := range buildFiles {
		// Skip files in the backup directory
		if strings.Contains(file, backupDir) {
			continue
		}

		// Read the file
		content, err := os.ReadFile(file)
		if err != nil {
			return fmt.Errorf("failed to read file %s: %v", file, err)
		}

		contentStr := string(content)
		modified := false

		// Check for dependencies to update
		matches := depRegex.FindAllString(contentStr, -1)
		if len(matches) > 0 {
			// Backup the file before modifying
			if err := backupFile(file); err != nil {
				return err
			}

			// Replace dependencies
			for _, match := range matches {
				replacement := "\"//Sources/SecurityProtocolsCore\""
				contentStr = strings.ReplaceAll(contentStr, match, replacement)
			}
			
			modified = true
		}

		// Write updated content back if modified
		if modified {
			if err := os.WriteFile(file, []byte(contentStr), 0644); err != nil {
				return fmt.Errorf("failed to write file %s: %v", file, err)
			}
			logMessage(fmt.Sprintf("Updated dependencies in %s", file))
		}
	}
	return nil
}

// Update the target module's BUILD.bazel to include new files
func updateTargetBuildFile() error {
	buildFilePath := filepath.Join(projectDir, "Sources/SecurityProtocolsCore/BUILD.bazel")
	
	// Backup the file
	if err := backupFile(buildFilePath); err != nil {
		return err
	}

	// Read current BUILD file
	content, err := os.ReadFile(buildFilePath)
	if err != nil {
		return fmt.Errorf("failed to read target BUILD file: %v", err)
	}

	contentStr := string(content)

	// Add a comment indicating the consolidation
	consolidationComment := "\n# This module has been consolidated to include content from SecurityInterfacesProtocols and SecurityInterfacesBase\n"
	if !strings.Contains(contentStr, consolidationComment) {
		insertPoint := strings.Index(contentStr, "swift_library")
		if insertPoint == -1 {
			return fmt.Errorf("could not find swift_library in target BUILD file")
		}
		
		contentStr = contentStr[:insertPoint] + consolidationComment + contentStr[insertPoint:]
	}

	// Ensure glob pattern includes all Swift files
	if strings.Contains(contentStr, "srcs = glob([") {
		// The glob is already there, just make sure it's inclusive enough
		if !strings.Contains(contentStr, "\"Sources/**/*.swift\"") {
			contentStr = strings.ReplaceAll(contentStr, "srcs = glob([", "srcs = glob([\n        \"Sources/**/*.swift\",")
		}
	}

	// Write the updated content back
	if err := os.WriteFile(buildFilePath, []byte(contentStr), 0644); err != nil {
		return fmt.Errorf("failed to write target BUILD file: %v", err)
	}
	
	logMessage(fmt.Sprintf("Updated target BUILD file: %s", buildFilePath))
	return nil
}

// Check if we need to add SecureBytes dependency to the target module
func ensureSecureBytesDepInTarget() error {
	buildFilePath := filepath.Join(projectDir, "Sources/SecurityProtocolsCore/BUILD.bazel")
	
	// Read current BUILD file
	content, err := os.ReadFile(buildFilePath)
	if err != nil {
		return fmt.Errorf("failed to read target BUILD file: %v", err)
	}

	contentStr := string(content)

	// Check if SecureBytes dependency is already there
	if !strings.Contains(contentStr, "\"//Sources/SecureBytes\"") {
		// Backup the file if not already done
		if err := backupFile(buildFilePath); err != nil {
			return err
		}
		
		// Add SecureBytes dependency
		depsSection := "deps = ["
		replacementSection := "deps = [\n        \"//Sources/SecureBytes\","
		
		if strings.Contains(contentStr, depsSection) {
			contentStr = strings.Replace(contentStr, depsSection, replacementSection, 1)
		}
		
		// Write the updated content back
		if err := os.WriteFile(buildFilePath, []byte(contentStr), 0644); err != nil {
			return fmt.Errorf("failed to write target BUILD file: %v", err)
		}
		
		logMessage("Added SecureBytes dependency to target BUILD file")
	}
	
	return nil
}

// Create a report of changes made
func createReport() error {
	reportPath := filepath.Join(projectDir, "security_consolidation_report.md")
	
	report := `# Security Module Consolidation Report

## Summary
This report summarizes the changes made to consolidate security modules in the UmbraCore project.

## Modules Consolidated
- SecurityInterfacesProtocols → SecurityProtocolsCore
- SecurityInterfacesBase → SecurityProtocolsCore

## Changes Made
`
	
	// Add log content to report
	logContent, err := os.ReadFile(logFile)
	if err != nil {
		return fmt.Errorf("failed to read log file: %v", err)
	}
	
	report += "```\n" + string(logContent) + "```\n"
	
	report += `
## Next Steps
1. Review the consolidated files for any conflicts or issues
2. Run tests to ensure functionality is preserved
3. Remove the now-redundant source modules after confirming everything works
4. Update documentation to reflect the new module structure

## Backup
All modified files were backed up to:
` + backupDir + `
`

	if err := os.WriteFile(reportPath, []byte(report), 0644); err != nil {
		return fmt.Errorf("failed to write report: %v", err)
	}
	
	logMessage(fmt.Sprintf("Created consolidation report: %s", reportPath))
	return nil
}

func main() {
	// Initialize logger
	if err := initLogger(); err != nil {
		fmt.Printf("Error initializing logger: %v\n", err)
		os.Exit(1)
	}
	defer logger.Close()

	logMessage("Starting security module consolidation process...")

	// Create backup directory
	if err := createBackupDir(); err != nil {
		logMessage(fmt.Sprintf("Error creating backup directory: %v", err))
		os.Exit(1)
	}

	// Confirm with user before proceeding
	fmt.Println("This tool will consolidate SecurityInterfacesProtocols and SecurityInterfacesBase into SecurityProtocolsCore.")
	fmt.Println("All files will be backed up to: " + backupDir)
	fmt.Print("Do you want to proceed? (y/n): ")
	
	reader := bufio.NewReader(os.Stdin)
	response, _ := reader.ReadString('\n')
	response = strings.TrimSpace(response)
	
	if strings.ToLower(response) != "y" && strings.ToLower(response) != "yes" {
		logMessage("Operation cancelled by user")
		os.Exit(0)
	}

	// Execute consolidation steps
	steps := []struct {
		name string
		fn   func() error
	}{
		{"Moving Swift files", moveSwiftFiles},
		{"Updating import statements", updateImports},
		{"Updating BUILD files", updateBuildFiles},
		{"Updating target BUILD file", updateTargetBuildFile},
		{"Ensuring dependencies in target", ensureSecureBytesDepInTarget},
		{"Creating report", createReport},
	}

	for _, step := range steps {
		logMessage(fmt.Sprintf("Step: %s", step.name))
		if err := step.fn(); err != nil {
			logMessage(fmt.Sprintf("Error in %s: %v", step.name, err))
			os.Exit(1)
		}
	}

	logMessage("Security module consolidation completed successfully!")
	logMessage(fmt.Sprintf("See the report at: %s/security_consolidation_report.md", projectDir))
	logMessage("Next steps:")
	logMessage("1. Review the changes and run tests to ensure everything works")
	logMessage("2. Remove the now-redundant source modules after confirming functionality")
}
