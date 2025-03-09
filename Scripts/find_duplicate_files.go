// Find Duplicate Files
// This utility scans the UmbraCore project for duplicate files based on their content.
// It calculates SHA-256 hashes for all files and identifies duplicates.

package main

import (
	"crypto/sha256"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
)

// Config holds programme configuration settings
type Config struct {
	RootDir        string
	MinSize        int64
	IgnoreDirs     []string
	IgnorePatterns []string
	Verbose        bool
	Concurrency    int
}

// FileInfo represents information about a specific file
type FileInfo struct {
	Path string
	Size int64
	Hash string
}

// We use a map to store files by their hash
var (
	filesByHash = make(map[string][]FileInfo)
	fileMutex   sync.Mutex
	semaphore   chan struct{}
	wg          sync.WaitGroup
)

// Calculates SHA-256 hash for a file
func calculateHash(path string) (string, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer file.Close()

	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		return "", err
	}

	return fmt.Sprintf("%x", hash.Sum(nil)), nil
}

// Checks if a directory should be ignored
func shouldIgnoreDir(path string, config Config) bool {
	for _, dir := range config.IgnoreDirs {
		if strings.Contains(path, dir) {
			return true
		}
	}
	return false
}

// Checks if a file should be ignored based on patterns
func shouldIgnoreFile(path string, config Config) bool {
	for _, pattern := range config.IgnorePatterns {
		matched, err := filepath.Match(pattern, filepath.Base(path))
		if err == nil && matched {
			return true
		}
	}
	return false
}

// Process a single file
func processFile(path string, info os.FileInfo, config Config) {
	defer wg.Done()
	defer func() { <-semaphore }()

	// Skip directories and files smaller than the minimum size
	if info.IsDir() || info.Size() < config.MinSize {
		return
	}

	// Skip files that match ignore patterns
	if shouldIgnoreFile(path, config) {
		if config.Verbose {
			fmt.Printf("Ignoring file: %s\n", path)
		}
		return
	}

	// Calculate file hash
	hash, err := calculateHash(path)
	if err != nil {
		fmt.Printf("Error hashing file %s: %v\n", path, err)
		return
	}

	if config.Verbose {
		fmt.Printf("Processed: %s (size: %d, hash: %s)\n", path, info.Size(), hash)
	}

	// Store file info by hash
	fileMutex.Lock()
	defer fileMutex.Unlock()
	
	filesByHash[hash] = append(filesByHash[hash], FileInfo{
		Path: path,
		Size: info.Size(),
		Hash: hash,
	})
}

// Walk through the directory tree and process files
func walkDirectory(config Config) error {
	return filepath.Walk(config.RootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Printf("Error accessing path %s: %v\n", path, err)
			return nil
		}

		// Skip ignored directories
		if info.IsDir() && shouldIgnoreDir(path, config) {
			if config.Verbose {
				fmt.Printf("Ignoring directory: %s\n", path)
			}
			return filepath.SkipDir
		}

		// Process file in a goroutine if it's a regular file
		if !info.IsDir() {
			semaphore <- struct{}{} // Acquire a token
			wg.Add(1)
			go processFile(path, info, config)
		}

		return nil
	})
}

// Print duplicate files
func printDuplicates() {
	// Sort hashes to ensure consistent output
	var hashes []string
	for hash, files := range filesByHash {
		if len(files) > 1 { // Only consider files with duplicates
			hashes = append(hashes, hash)
		}
	}
	sort.Strings(hashes)

	duplicateCount := 0
	wastedSpace := int64(0)
	
	for _, hash := range hashes {
		files := filesByHash[hash]
		if len(files) > 1 {
			duplicateCount++
			
			// Sort files by path for consistent output
			sort.Slice(files, func(i, j int) bool {
				return files[i].Path < files[j].Path
			})
			
			fmt.Printf("\nDuplicate set #%d (hash: %s, size: %d bytes):\n", 
				duplicateCount, hash[:16]+"...", files[0].Size)
			
			for _, file := range files {
				fmt.Printf("  %s\n", file.Path)
				// Calculate wasted space (size of all duplicates except one copy)
				if duplicateCount > 0 {
					wastedSpace += file.Size
				}
			}
			
			// Adjust wasted space calculation to exclude one copy
			wastedSpace -= files[0].Size
		}
	}
	
	fmt.Printf("\nSummary:\n")
	fmt.Printf("  Total duplicate sets: %d\n", duplicateCount)
	fmt.Printf("  Wasted space: %d bytes (%.2f MB)\n", 
		wastedSpace, float64(wastedSpace)/(1024*1024))
}

func main() {
	// Parse command-line arguments
	rootDir := flag.String("dir", ".", "Root directory to scan")
	minSize := flag.Int64("minsize", 1, "Minimum file size in bytes")
	ignoreFlag := flag.String("ignore", ".git,.build,bazel-,node_modules,vendor", "Comma-separated list of directories to ignore")
	ignorePatterns := flag.String("patterns", "*.swp,*.swo,*.tmp", "Comma-separated list of file patterns to ignore")
	verbose := flag.Bool("verbose", false, "Enable verbose output")
	concurrency := flag.Int("concurrency", 10, "Maximum number of concurrent file processing goroutines")
	
	flag.Parse()

	// Setup configuration
	config := Config{
		RootDir:        *rootDir,
		MinSize:        *minSize,
		IgnoreDirs:     strings.Split(*ignoreFlag, ","),
		IgnorePatterns: strings.Split(*ignorePatterns, ","),
		Verbose:        *verbose,
		Concurrency:    *concurrency,
	}

	// Initialize semaphore for concurrency control
	semaphore = make(chan struct{}, config.Concurrency)

	fmt.Printf("Scanning directory: %s\n", config.RootDir)
	fmt.Printf("Ignoring directories: %v\n", config.IgnoreDirs)
	fmt.Printf("Ignoring file patterns: %v\n", config.IgnorePatterns)

	// Process files
	err := walkDirectory(config)
	if err != nil {
		fmt.Printf("Error walking directory: %v\n", err)
		os.Exit(1)
	}

	// Wait for all goroutines to finish
	wg.Wait()

	// Print results
	printDuplicates()
}
