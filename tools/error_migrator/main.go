package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	// Define command line flags
	initPtr := flag.Bool("init", false, "Initialize migration with default configuration")
	initConfigPtr := flag.Bool("initConfig", false, "Initialize migration with default configuration")
	reportPathPtr := flag.String("report", "", "Path to error analysis report")
	configFilePtr := flag.String("config", "", "Path to migration configuration file")
	outputDirPtr := flag.String("output", "", "Output directory for generated files")
	dryRunPtr := flag.Bool("dry-run", true, "Perform a dry run without modifying files")
	applyPtr := flag.Bool("apply", false, "Apply the migration to the codebase")
	verbosePtr := flag.Bool("verbose", false, "Enable verbose output")
	
	flag.Parse()
	
	// Check if at least one option is specified
	if !*initPtr && !*initConfigPtr && !*applyPtr && !*dryRunPtr {
		fmt.Println("Error: You must specify an action to perform (--init, --initConfig, --dry-run, or --apply)")
		flag.Usage()
		os.Exit(1)
	}
	
	// Validate required parameters
	if *reportPathPtr == "" {
		fmt.Println("Error: Report path is required")
		flag.Usage()
		os.Exit(1)
	}
	
	// Initialize migration if requested
	if *initPtr || *initConfigPtr {
		if *configFilePtr == "" {
			fmt.Println("Error: Config file path is required for initialization")
			flag.Usage()
			os.Exit(1)
		}
		
		// Parse the error analysis report
		errorDefs, duplicatedErrors, err := ParseErrorAnalysisReport(*reportPathPtr)
		if err != nil {
			fmt.Printf("Error: %v\n", err)
			os.Exit(1)
		}
		
		// Create default configuration file
		if err := CreateDefaultConfigFile(*configFilePtr, duplicatedErrors, errorDefs); err != nil {
			fmt.Printf("Error: %v\n", err)
			os.Exit(1)
		}
		
		fmt.Printf("Migration configuration created at %s\n", *configFilePtr)
		fmt.Println("Please review and edit the configuration file before running the migration.")
		return
	}
	
	// For dry-run or apply, we need a config file
	if (*dryRunPtr || *applyPtr) && *configFilePtr == "" {
		fmt.Println("Error: Config file path is required for dry-run or apply")
		flag.Usage()
		os.Exit(1)
	}
	
	// For apply, we need an output directory
	if *applyPtr && *outputDirPtr == "" {
		fmt.Println("Error: Output directory is required for apply")
		flag.Usage()
		os.Exit(1)
	}
	
	// Parse the error analysis report
	fmt.Println("Parsing error analysis report...")
	errorDefs, duplicatedErrors, err := ParseErrorAnalysisReport(*reportPathPtr)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
	
	// Load migration configuration
	fmt.Println("Loading migration configuration...")
	config, err := LoadMigrationConfig(*configFilePtr)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
	
	// Set dry run flag
	config.DryRun = *dryRunPtr
	
	// Set output directory if provided
	if *outputDirPtr != "" {
		config.OutputDir = *outputDirPtr
	}
	
	// Plan the migration
	fmt.Println("Planning migration...")
	migration, err := PlanMigration(*config, errorDefs, duplicatedErrors)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
	
	// Validate the migration
	fmt.Println("Validating migration plan...")
	if err := ValidateMigration(migration, errorDefs); err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
	
	// Print migration summary
	PrintMigrationSummary(migration, *verbosePtr)
	
	// Generate code
	fmt.Println("Generating code...")
	generatedCode, err := GenerateCode(migration, errorDefs)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
	
	// Apply or show the generated code
	if *applyPtr {
		fmt.Println("Applying migration...")
		// Ensure dryRun is false when applying changes
		if err := WriteGeneratedCode(generatedCode, config.OutputDir, false); err != nil {
			fmt.Printf("Error: %v\n", err)
			os.Exit(1)
		}
		
		fmt.Println("Migration applied successfully!")
		fmt.Printf("Generated files have been written to %s\n", config.OutputDir)
		
		// Print summary of namespace conflicts if any
		if len(migration.NamespaceConflicts) > 0 {
			fmt.Println("\nNote: Namespace conflicts were detected and handled during migration.")
			fmt.Println("Please review the generated code carefully and adjust your imports as needed.")
			fmt.Println("See detailed guidance in the generated alias files.")
		}
	} else if *dryRunPtr {
		fmt.Println("Dry run completed successfully!")
		if *verbosePtr {
			PrintGeneratedCode(generatedCode)
		} else {
			fmt.Println("Use --verbose to see the generated code")
		}
	}
}

// PrintMigrationSummary prints a summary of the planned migration
func PrintMigrationSummary(migration *Migration, verbose bool) {
	fmt.Println("\n=== Migration Summary ===")
	fmt.Printf("Target Module: %s\n", migration.TargetModule)
	fmt.Printf("Errors to Migrate: %d\n", len(migration.ErrorsToMigrate))
	
	// Group by source module for cleaner output
	errorsByModule := make(map[string][]string)
	for _, err := range migration.ErrorsToMigrate {
		errorsByModule[err.SourceModule] = append(errorsByModule[err.SourceModule], err.ErrorName)
	}
	
	fmt.Println("\nSource Modules:")
	for module, errors := range errorsByModule {
		fmt.Printf("  - %s: %v\n", module, errors)
	}
	
	// Print namespace conflicts if any
	if len(migration.NamespaceConflicts) > 0 {
		fmt.Println("\nNamespace Conflicts Detected:")
		for module, errors := range migration.NamespaceConflicts {
			fmt.Printf("  - %s: %v\n", module, errors)
		}
		
		if verbose {
			fmt.Println("\nDetailed Conflict Information:")
			for _, err := range migration.ErrorsToMigrate {
				if err.HasNamespaceConflict {
					fmt.Printf("  - %s in %s:\n", err.ErrorName, err.SourceModule)
					fmt.Printf("    %s\n", err.ConflictSolution)
				}
			}
		}
	}
	
	fmt.Println()
}

// PrintGeneratedCode prints the generated code to stdout
func PrintGeneratedCode(generatedCode *GeneratedCode) {
	fmt.Println("=== Generated Error Definitions ===")
	for errorName, code := range generatedCode.TargetModuleCode {
		fmt.Printf("=== %s ===\n", errorName)
		fmt.Println(code)
		fmt.Println()
	}
	
	fmt.Println("=== Generated Type Aliases ===")
	for module, code := range generatedCode.AliasModuleCode {
		fmt.Printf("=== %s ===\n", module)
		fmt.Println(code)
		fmt.Println()
	}
	
	if len(generatedCode.UpdatedImports) > 0 {
		fmt.Println("=== Files With Updated Imports ===")
		for filePath := range generatedCode.UpdatedImports {
			fmt.Println(filePath)
		}
	}
}
