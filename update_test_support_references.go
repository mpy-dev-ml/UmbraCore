// Program to update BUILD file references from TestSupport to Tests/UmbraTestKit
// Created: 2025-03-09

package main

import (
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)

const (
	rootDir       = "/Users/mpy/CascadeProjects/UmbraCore"
	oldPath       = "//TestSupport"
	newPath       = "//Tests/UmbraTestKit"
	oldPathAbs    = "/Users/mpy/CascadeProjects/UmbraCore/TestSupport"
	backupSuffix  = ".bak"
	logFilePath   = "/Users/mpy/CascadeProjects/UmbraCore/test_support_reference_updates.log"
	dryRun        = false // Set to true to test without making changes
)

type FileUpdate struct {
	Path            string
	UpdatedContents string
	MatchCount      int
}

func main() {
	// Create log file
	logFile, err := os.Create(logFilePath)
	if err != nil {
		fmt.Printf("Error creating log file: %v\n", err)
		return
	}
	defer logFile.Close()

	log(logFile, "TestSupport reference update - %s\n", time.Now().Format("2006-01-02 15:04:05"))
	log(logFile, "Updating references from %s to %s\n", oldPath, newPath)

	// Find BUILD and BUILD.bazel files
	var buildFiles []string
	err = filepath.WalkDir(rootDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		
		// Skip .git and bazel-* directories
		if d.IsDir() && (strings.HasPrefix(d.Name(), "bazel-") || d.Name() == ".git") {
			return filepath.SkipDir
		}
		
		if !d.IsDir() && (d.Name() == "BUILD" || d.Name() == "BUILD.bazel") {
			buildFiles = append(buildFiles, path)
		}
		return nil
	})

	if err != nil {
		log(logFile, "Error walking directory tree: %v\n", err)
		return
	}

	log(logFile, "Found %d BUILD files to check\n", len(buildFiles))

	// Process each BUILD file
	updatedFiles := []FileUpdate{}
	for _, buildFile := range buildFiles {
		updated, content, matchCount, err := processFile(buildFile, logFile)
		if err != nil {
			log(logFile, "Error processing file %s: %v\n", buildFile, err)
			continue
		}

		if updated {
			updatedFiles = append(updatedFiles, FileUpdate{
				Path:            buildFile,
				UpdatedContents: content,
				MatchCount:      matchCount,
			})
			log(logFile, "Found %d references to update in %s\n", matchCount, buildFile)
		}
	}

	// Apply updates
	for _, update := range updatedFiles {
		if dryRun {
			log(logFile, "[DRY RUN] Would update %s with %d changes\n", update.Path, update.MatchCount)
			continue
		}

		// Backup the original file
		backupPath := update.Path + backupSuffix
		err := copyFile(update.Path, backupPath)
		if err != nil {
			log(logFile, "Error creating backup for %s: %v\n", update.Path, err)
			continue
		}

		// Write updated content
		err = os.WriteFile(update.Path, []byte(update.UpdatedContents), 0644)
		if err != nil {
			log(logFile, "Error writing updated content to %s: %v\n", update.Path, err)
			continue
		}

		log(logFile, "Updated %s (backup at %s)\n", update.Path, backupPath)
		fmt.Printf("Updated %s with %d changes\n", update.Path, update.MatchCount)
	}

	log(logFile, "Updated %d files\n", len(updatedFiles))

	// Remove original TestSupport directory if not in dry run
	if !dryRun {
		if _, err := os.Stat(oldPathAbs); os.IsNotExist(err) {
			log(logFile, "TestSupport directory already removed\n")
		} else {
			err := os.RemoveAll(oldPathAbs)
			if err != nil {
				log(logFile, "Error removing TestSupport directory: %v\n", err)
			} else {
				log(logFile, "Successfully removed TestSupport directory\n")
				fmt.Println("Successfully removed TestSupport directory")
			}
		}
	} else {
		log(logFile, "[DRY RUN] Would remove TestSupport directory\n")
	}

	log(logFile, "Operation completed at %s\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Printf("Operation completed. Log file at: %s\n", logFilePath)
}

func processFile(filePath string, logFile *os.File) (bool, string, int, error) {
	content, err := os.ReadFile(filePath)
	if err != nil {
		return false, "", 0, err
	}

	contentStr := string(content)

	// Check if file has any references to TestSupport
	if !strings.Contains(contentStr, "TestSupport") {
		return false, "", 0, nil
	}

	// Replace direct path references 
	r1 := regexp.MustCompile(`["']//TestSupport([^"']*)["']`)
	updatedContent := r1.ReplaceAllString(contentStr, `"//Tests/UmbraTestKit$1"`)
	
	// Replace target references
	r2 := regexp.MustCompile(`[@"]//TestSupport(:[^"@]*)["@]`)
	updatedContent = r2.ReplaceAllString(updatedContent, `"//Tests/UmbraTestKit$1"`)
	
	// Replace visibility declarations
	r3 := regexp.MustCompile(`"visibility"\s*:\s*\[\s*"//TestSupport([^"\]]*)"\s*\]`)
	updatedContent = r3.ReplaceAllString(updatedContent, `"visibility": ["//Tests/UmbraTestKit$1"]`)
	
	// Replace deps declarations
	r4 := regexp.MustCompile(`"deps"\s*:\s*\[\s*"//TestSupport([^"\]]*)"\s*\]`)
	updatedContent = r4.ReplaceAllString(updatedContent, `"deps": ["//Tests/UmbraTestKit$1"]`)
	
	// Count how many replacements were made
	matchCount := strings.Count(updatedContent, "//Tests/UmbraTestKit") - strings.Count(contentStr, "//Tests/UmbraTestKit")
	
	// Check if anything was actually replaced
	if contentStr == updatedContent {
		return false, "", 0, nil
	}

	return true, updatedContent, matchCount, nil
}

func copyFile(src, dst string) error {
	sourceFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer sourceFile.Close()

	destFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer destFile.Close()

	_, err = io.Copy(destFile, sourceFile)
	if err != nil {
		return err
	}

	return nil
}

func log(w io.Writer, format string, args ...interface{}) {
	fmt.Fprintf(w, format, args...)
	if !strings.HasSuffix(format, "\n") {
		fmt.Fprintln(w)
	}
}
