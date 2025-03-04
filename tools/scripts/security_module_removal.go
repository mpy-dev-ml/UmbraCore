// security_module_removal.go
//
// A tool to safely remove redundant security modules from UmbraCore
// after their functionality has been successfully migrated.
// This performs verification before removal and creates backups.

package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

// Module to be removed
type RedundantModule struct {
	Name               string
	Path               string
	ReplacementModule  string
	RequiresVerification bool
}

// Color codes for terminal output
const (
	ColorReset   = "\033[0m"
	ColorRed     = "\033[31m"
	ColorGreen   = "\033[32m"
	ColorYellow  = "\033[33m"
	ColorBlue    = "\033[34m"
	ColorMagenta = "\033[35m"
	ColorCyan    = "\033[36m"
)

// Global variables
var (
	projectRoot  string
	backupDir    string
	logFile      string
	redundantModules []RedundantModule
	dryRun       bool
	force        bool
	verifyOnly   bool
	runSwiftLint bool
	verbose      bool
)

func main() {
	// Parse command line flags
	flag.StringVar(&projectRoot, "project-root", "/Users/mpy/CascadeProjects/UmbraCore", "Path to UmbraCore project root")
	flag.StringVar(&backupDir, "backup-dir", "", "Directory for backups (defaults to timestamp-based dir in project root)")
	flag.StringVar(&logFile, "log-file", "", "Log file path (defaults to timestamp-based file in project root)")
	flag.BoolVar(&dryRun, "dry-run", true, "Perform a dry run without making actual changes")
	flag.BoolVar(&force, "force", false, "Force removal even if verification fails")
	flag.BoolVar(&verifyOnly, "verify-only", false, "Only verify that modules can be safely removed, don't remove them")
	flag.BoolVar(&runSwiftLint, "run-swiftlint", true, "Run swiftlint --fix after cleanup")
	flag.BoolVar(&verbose, "verbose", false, "Verbose output")
	flag.Parse()

	// Initialize timestamps for logs and backups
	timestamp := time.Now().Format("20060102-150405")
	
	// Set defaults for backup and log directories if not provided
	if backupDir == "" {
		backupDir = filepath.Join(projectRoot, fmt.Sprintf("security_module_removal_backup_%s", timestamp))
	}
	
	if logFile == "" {
		logFile = filepath.Join(projectRoot, fmt.Sprintf("security_module_removal_%s.log", timestamp))
	}

	// Define redundant modules to be removed
	redundantModules = []RedundantModule{
		{
			Name:               "SecurityInterfacesFoundationBase",
			Path:               filepath.Join(projectRoot, "Sources/SecurityInterfacesFoundationBase"),
			ReplacementModule:  "SecurityProtocolsCore",
			RequiresVerification: true,
		},
		{
			Name:               "SecurityInterfacesFoundationBridge",
			Path:               filepath.Join(projectRoot, "Sources/SecurityInterfacesFoundationBridge"),
			ReplacementModule:  "SecurityBridge",
			RequiresVerification: true,
		},
		{
			Name:               "SecurityInterfacesFoundationCore",
			Path:               filepath.Join(projectRoot, "Sources/SecurityInterfacesFoundationCore"),
			ReplacementModule:  "SecurityProtocolsCore",
			RequiresVerification: true,
		},
		{
			Name:               "SecurityInterfacesFoundationMinimal",
			Path:               filepath.Join(projectRoot, "Sources/SecurityInterfacesFoundationMinimal"),
			ReplacementModule:  "SecurityProtocolsCore",
			RequiresVerification: true,
		},
		{
			Name:               "SecurityInterfacesFoundationNoFoundation",
			Path:               filepath.Join(projectRoot, "Sources/SecurityInterfacesFoundationNoFoundation"),
			ReplacementModule:  "SecurityProtocolsCore",
			RequiresVerification: true,
		},
		{
			Name:               "SecurityProviderBridge",
			Path:               filepath.Join(projectRoot, "Sources/SecurityProviderBridge"),
			ReplacementModule:  "SecurityBridge",
			RequiresVerification: true,
		},
	}

	// Print banner
	fmt.Printf("%s╔══════════════════════════════════════════════════════╗%s\n", ColorCyan, ColorReset)
	fmt.Printf("%s║      UmbraCore Security Module Removal Utility       ║%s\n", ColorCyan, ColorReset)
	fmt.Printf("%s╚══════════════════════════════════════════════════════╝%s\n", ColorCyan, ColorReset)
	fmt.Println()

	// Create log file
	err := initLogger()
	if err != nil {
		fmt.Printf("%sError initializing logger: %v%s\n", ColorRed, err, ColorReset)
		os.Exit(1)
	}
	
	// Log configuration
	logMessage(fmt.Sprintf("UmbraCore Security Module Removal Utility started at %s", timestamp))
	logMessage(fmt.Sprintf("Project root: %s", projectRoot))
	logMessage(fmt.Sprintf("Backup directory: %s", backupDir))
	logMessage(fmt.Sprintf("Log file: %s", logFile))
	logMessage(fmt.Sprintf("Dry run: %t", dryRun))
	logMessage(fmt.Sprintf("Force removal: %t", force))
	logMessage(fmt.Sprintf("Verify only: %t", verifyOnly))
	logMessage(fmt.Sprintf("Run SwiftLint: %t", runSwiftLint))
	
	if dryRun {
		fmt.Printf("%s⚠️  DRY RUN MODE: No actual changes will be made%s\n\n", ColorYellow, ColorReset)
	}

	// Create backup directory
	if !dryRun {
		err = os.MkdirAll(backupDir, 0755)
		if err != nil {
			logMessage(fmt.Sprintf("Error creating backup directory: %v", err))
			os.Exit(1)
		}
		logMessage(fmt.Sprintf("Created backup directory: %s", backupDir))
	}

	// Verify modules can be safely removed
	fmt.Printf("%s➡️  Verifying modules can be safely removed...%s\n", ColorBlue, ColorReset)
	safe, issues := verifyModulesCanBeRemoved()
	
	if !safe {
		logMessage("⚠️ Verification failed, modules cannot be safely removed:")
		for _, issue := range issues {
			logMessage(fmt.Sprintf("  - %s", issue))
		}
		
		if !force && !verifyOnly {
			fmt.Printf("%s❌ Verification failed. Use --force to remove modules anyway.%s\n", ColorRed, ColorReset)
			os.Exit(1)
		} else if force && !verifyOnly {
			fmt.Printf("%s⚠️  Forcing removal despite verification failure.%s\n", ColorYellow, ColorReset)
		}
	} else {
		fmt.Printf("%s✅ All modules can be safely removed!%s\n", ColorGreen, ColorReset)
	}
	
	// Exit if verify-only mode
	if verifyOnly {
		fmt.Printf("%s✓ Verification complete. No modules were removed (--verify-only).%s\n", ColorGreen, ColorReset)
		os.Exit(0)
	}
	
	// Remove modules
	if !dryRun {
		fmt.Printf("%s➡️  Removing redundant modules...%s\n", ColorBlue, ColorReset)
		removeRedundantModules()
	} else {
		fmt.Printf("%s➡️  Would remove the following modules:%s\n", ColorBlue, ColorReset)
		for _, module := range redundantModules {
			fmt.Printf("   - %s%s%s\n", ColorYellow, module.Name, ColorReset)
		}
	}
	
	// Clean up BUILD.bazel files
	fmt.Printf("%s➡️  Cleaning up BUILD.bazel files...%s\n", ColorBlue, ColorReset)
	cleanupBuildFiles()
	
	// Run SwiftLint if requested
	if runSwiftLint && !dryRun {
		fmt.Printf("%s➡️  Running SwiftLint to clean up code...%s\n", ColorBlue, ColorReset)
		err = runSwiftLintFix()
		if err != nil {
			logMessage(fmt.Sprintf("Error running SwiftLint: %v", err))
		}
	}
	
	// Print summary
	fmt.Println()
	fmt.Printf("%s╔══════════════════════════════════════════════════════╗%s\n", ColorGreen, ColorReset)
	fmt.Printf("%s║                  Operation Complete                  ║%s\n", ColorGreen, ColorReset)
	fmt.Printf("%s╚══════════════════════════════════════════════════════╝%s\n", ColorGreen, ColorReset)
	fmt.Println()
	
	if dryRun {
		fmt.Printf("%s✓ Dry run completed. No changes were made.%s\n", ColorGreen, ColorReset)
		fmt.Printf("%s  To execute the actual removal, run with --dry-run=false%s\n", ColorGreen, ColorReset)
	} else {
		fmt.Printf("%s✓ Redundant modules have been removed.%s\n", ColorGreen, ColorReset)
		fmt.Printf("%s✓ Backups created at: %s%s\n", ColorGreen, backupDir, ColorReset)
	}
	
	fmt.Printf("%s✓ Log file: %s%s\n", ColorGreen, logFile, ColorReset)
	fmt.Println()
}

// Initialize logger
func initLogger() error {
	logFileHandle, err := os.Create(logFile)
	if err != nil {
		return err
	}
	defer logFileHandle.Close()
	
	_, err = logFileHandle.WriteString(fmt.Sprintf("UmbraCore Security Module Removal Log - %s\n\n", time.Now().Format(time.RFC3339)))
	return err
}

// Log a message to both console and log file
func logMessage(message string) {
	// Print to console
	if verbose {
		fmt.Println(message)
	}
	
	// Write to log file
	logFileHandle, err := os.OpenFile(logFile, os.O_APPEND|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Printf("Error opening log file: %v\n", err)
		return
	}
	defer logFileHandle.Close()
	
	_, err = logFileHandle.WriteString(fmt.Sprintf("[%s] %s\n", time.Now().Format("15:04:05"), message))
	if err != nil {
		fmt.Printf("Error writing to log file: %v\n", err)
	}
}

// Verify that modules can be safely removed
func verifyModulesCanBeRemoved() (bool, []string) {
	var issues []string
	allSafe := true
	
	// Check for import statements in Swift files
	for _, module := range redundantModules {
		if !module.RequiresVerification {
			continue
		}
		
		fmt.Printf("   - Checking for imports of %s%s%s...\n", ColorYellow, module.Name, ColorReset)
		
		// Find all Swift files importing this module
		importPattern := fmt.Sprintf("import %s", module.Name)
		cmd := exec.Command("grep", "-r", importPattern, "--include=*.swift", filepath.Join(projectRoot, "Sources"))
		output, _ := cmd.CombinedOutput()
		
		if len(output) > 0 {
			lines := strings.Split(string(output), "\n")
			validRefs := 0
			
			for _, line := range lines {
				if line == "" {
					continue
				}
				
				// Check if it's a commented line
				if strings.Contains(line, "//") && strings.Index(line, "//") < strings.Index(line, importPattern) {
					continue
				}
				
				validRefs++
				logMessage(fmt.Sprintf("Found reference to %s: %s", module.Name, line))
			}
			
			if validRefs > 0 {
				issue := fmt.Sprintf("%s is still imported in %d Swift files", module.Name, validRefs)
				issues = append(issues, issue)
				allSafe = false
				fmt.Printf("     %s⚠️  %s%s\n", ColorYellow, issue, ColorReset)
			}
		}
		
		// Check for dependencies in BUILD.bazel files
		bazelPattern := fmt.Sprintf("\"%s\"", module.Name)
		cmd = exec.Command("grep", "-r", bazelPattern, "--include=BUILD.bazel", filepath.Join(projectRoot, "Sources"))
		output, _ = cmd.CombinedOutput()
		
		if len(output) > 0 {
			lines := strings.Split(string(output), "\n")
			validRefs := 0
			
			for _, line := range lines {
				if line == "" || strings.Contains(line, "# Legacy dependency") {
					continue
				}
				
				validRefs++
				logMessage(fmt.Sprintf("Found Bazel dependency on %s: %s", module.Name, line))
			}
			
			if validRefs > 0 {
				issue := fmt.Sprintf("%s is still referenced in %d BUILD.bazel files", module.Name, validRefs)
				issues = append(issues, issue)
				allSafe = false
				fmt.Printf("     %s⚠️  %s%s\n", ColorYellow, issue, ColorReset)
			}
		}
	}
	
	return allSafe, issues
}

// Remove redundant modules
func removeRedundantModules() {
	var wg sync.WaitGroup
	results := make(chan string, len(redundantModules))
	
	for _, module := range redundantModules {
		wg.Add(1)
		go func(m RedundantModule) {
			defer wg.Done()
			
			// Create backup of module
			backupPath := filepath.Join(backupDir, m.Name)
			err := os.MkdirAll(backupPath, 0755)
			if err != nil {
				results <- fmt.Sprintf("Error creating backup directory for %s: %v", m.Name, err)
				return
			}
			
			// Copy module to backup
			cmd := exec.Command("cp", "-R", m.Path+"/.", backupPath)
			err = cmd.Run()
			if err != nil {
				results <- fmt.Sprintf("Error backing up %s: %v", m.Name, err)
				return
			}
			
			// Remove module
			err = os.RemoveAll(m.Path)
			if err != nil {
				results <- fmt.Sprintf("Error removing %s: %v", m.Name, err)
				return
			}
			
			results <- fmt.Sprintf("%s✓ Removed %s (backed up to %s)%s", ColorGreen, m.Name, backupPath, ColorReset)
		}(module)
	}
	
	// Wait for all removals to complete
	go func() {
		wg.Wait()
		close(results)
	}()
	
	// Collect and print results
	for result := range results {
		if strings.HasPrefix(result, ColorGreen) {
			fmt.Println(result)
		} else {
			fmt.Printf("%s⚠️  %s%s\n", ColorYellow, result, ColorReset)
		}
		logMessage(strings.Replace(strings.Replace(result, ColorGreen, "", -1), ColorReset, "", -1))
	}
}

// Clean up BUILD.bazel files
func cleanupBuildFiles() {
	// Find all BUILD.bazel files
	var buildFiles []string
	err := filepath.Walk(filepath.Join(projectRoot, "Sources"), func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && filepath.Base(path) == "BUILD.bazel" {
			buildFiles = append(buildFiles, path)
		}
		return nil
	})
	
	if err != nil {
		logMessage(fmt.Sprintf("Error finding BUILD.bazel files: %v", err))
		return
	}
	
	// Process each BUILD.bazel file
	for _, buildFile := range buildFiles {
		processed := false
		
		// Read the file
		content, err := ioutil.ReadFile(buildFile)
		if err != nil {
			logMessage(fmt.Sprintf("Error reading %s: %v", buildFile, err))
			continue
		}
		
		fileContent := string(content)
		originalContent := fileContent
		
		// Check each module
		for _, module := range redundantModules {
			// Replace with comment
			pattern := fmt.Sprintf("\"%s\"", module.Name)
			replacement := fmt.Sprintf("# \"%s\" - Removed in security module cleanup", module.Name)
			
			if strings.Contains(fileContent, pattern) {
				fileContent = strings.ReplaceAll(fileContent, pattern, replacement)
				processed = true
			}
		}
		
		// Write changes if needed
		if processed && fileContent != originalContent {
			relPath, _ := filepath.Rel(projectRoot, buildFile)
			
			if dryRun {
				fmt.Printf("%s  Would update: %s%s\n", ColorBlue, relPath, ColorReset)
				logMessage(fmt.Sprintf("Would update BUILD file: %s", relPath))
			} else {
				// Backup original file
				backupPath := filepath.Join(backupDir, "BUILD_files", relPath)
				os.MkdirAll(filepath.Dir(backupPath), 0755)
				err = ioutil.WriteFile(backupPath, content, 0644)
				if err != nil {
					logMessage(fmt.Sprintf("Error backing up %s: %v", buildFile, err))
				}
				
				// Write updated content
				err = ioutil.WriteFile(buildFile, []byte(fileContent), 0644)
				if err != nil {
					logMessage(fmt.Sprintf("Error updating %s: %v", buildFile, err))
				} else {
					fmt.Printf("%s  Updated: %s%s\n", ColorGreen, relPath, ColorReset)
					logMessage(fmt.Sprintf("Updated BUILD file: %s", relPath))
				}
			}
		}
	}
}

// Run SwiftLint to fix formatting issues
func runSwiftLintFix() error {
	fmt.Printf("%s  Running SwiftLint on the project...%s\n", ColorBlue, ColorReset)
	logMessage("Running SwiftLint --fix")
	
	cmd := exec.Command("swiftlint", "--fix", "--path", filepath.Join(projectRoot, "Sources"))
	output, err := cmd.CombinedOutput()
	
	logMessage(fmt.Sprintf("SwiftLint output: %s", string(output)))
	
	if err != nil {
		fmt.Printf("%s⚠️  SwiftLint encountered issues: %v%s\n", ColorYellow, err, ColorReset)
		return err
	}
	
	fmt.Printf("%s✓ SwiftLint completed successfully%s\n", ColorGreen, ColorReset)
	return nil
}
