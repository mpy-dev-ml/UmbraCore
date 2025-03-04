package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// Config holds the configuration for the migration
type Config struct {
	RootDir       string
	DryRun        bool
	VerboseOutput bool
	BackupFiles   bool
}

// FileInfo stores information about a file that needs modification
type FileInfo struct {
	Path            string
	ContainsImport  bool
	ModifiedContent string
	Changes         int
}

func main() {
	config := parseFlags()

	// Find all Swift files in the project
	files, err := findSwiftFiles(config.RootDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error finding Swift files: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Found %d Swift files to scan\n", len(files))

	// Process each file
	filesToModify := make([]FileInfo, 0)
	for _, file := range files {
		fileInfo, err := processFile(file, config.VerboseOutput)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error processing %s: %v\n", file, err)
			continue
		}

		if fileInfo.ContainsImport {
			filesToModify = append(filesToModify, fileInfo)
		}
	}

	fmt.Printf("Found %d files requiring modification\n", len(filesToModify))

	// Apply changes
	if !config.DryRun {
		for _, fileInfo := range filesToModify {
			if err := applyChanges(fileInfo, config.BackupFiles); err != nil {
				fmt.Fprintf(os.Stderr, "Error updating %s: %v\n", fileInfo.Path, err)
			} else if config.VerboseOutput {
				fmt.Printf("Updated %s with %d changes\n", fileInfo.Path, fileInfo.Changes)
			}
		}
		fmt.Printf("Successfully updated %d files\n", len(filesToModify))
	} else {
		fmt.Println("Dry run completed. No files were modified.")
		for _, fileInfo := range filesToModify {
			fmt.Printf("Would modify: %s (%d changes)\n", fileInfo.Path, fileInfo.Changes)
		}
	}
}

// parseFlags parses command line flags
func parseFlags() Config {
	rootDir := flag.String("dir", "/Users/mpy/CascadeProjects/UmbraCore", "Root directory to scan")
	dryRun := flag.Bool("dry-run", false, "Perform a dry run without modifying files")
	verbose := flag.Bool("verbose", false, "Enable verbose output")
	backup := flag.Bool("backup", true, "Create backup files before modifying")

	flag.Parse()

	return Config{
		RootDir:       *rootDir,
		DryRun:        *dryRun,
		VerboseOutput: *verbose,
		BackupFiles:   *backup,
	}
}

// findSwiftFiles finds all Swift files in the given directory
func findSwiftFiles(rootDir string) ([]string, error) {
	var files []string

	err := filepath.Walk(rootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Skip .git directory
		if info.IsDir() && info.Name() == ".git" {
			return filepath.SkipDir
		}

		// Skip build directories
		if info.IsDir() && (info.Name() == "build" || info.Name() == "bazel-*") {
			return filepath.SkipDir
		}

		if !info.IsDir() && strings.HasSuffix(info.Name(), ".swift") {
			files = append(files, path)
		}
		return nil
	})

	return files, err
}

// processFile processes a single file
func processFile(filePath string, verbose bool) (FileInfo, error) {
	fileInfo := FileInfo{
		Path:           filePath,
		ContainsImport: false,
		Changes:        0,
	}

	content, err := ioutil.ReadFile(filePath)
	if err != nil {
		return fileInfo, err
	}

	originalContent := string(content)
	modifiedContent := originalContent

	// Replace import statements
	importRegex := regexp.MustCompile(`(?m)^import\s+SecureBytes\s*$`)
	if importRegex.MatchString(modifiedContent) {
		fileInfo.ContainsImport = true
		
		// First check if UmbraCoreTypes is already imported
		alreadyImportsUmbraCoreTypes := regexp.MustCompile(`(?m)^import\s+UmbraCoreTypes\s*$`).MatchString(modifiedContent)
		
		if alreadyImportsUmbraCoreTypes {
			// If already imports UmbraCoreTypes, just remove the SecureBytes import
			modifiedContent = importRegex.ReplaceAllString(modifiedContent, "")
			fileInfo.Changes++
			if verbose {
				fmt.Printf("Removed SecureBytes import from %s (already imports UmbraCoreTypes)\n", filePath)
			}
		} else {
			// Replace the import
			modifiedContent = importRegex.ReplaceAllString(modifiedContent, "import UmbraCoreTypes")
			fileInfo.Changes++
			if verbose {
				fmt.Printf("Replaced SecureBytes import with UmbraCoreTypes in %s\n", filePath)
			}
		}
	}

	fileInfo.ModifiedContent = modifiedContent
	return fileInfo, nil
}

// applyChanges applies the changes to the file
func applyChanges(fileInfo FileInfo, createBackup bool) error {
	if createBackup {
		backupPath := fileInfo.Path + ".bak"
		if err := ioutil.WriteFile(backupPath, []byte(fileInfo.ModifiedContent), 0644); err != nil {
			return fmt.Errorf("failed to create backup: %v", err)
		}
	}

	return ioutil.WriteFile(fileInfo.Path, []byte(fileInfo.ModifiedContent), 0644)
}
