// Protocol Analyzer Tool
//
// This tool analyzes Swift protocols and implementations to detect conformance issues
// including missing methods, signature mismatches, and duplicate implementations.
// It can be run with a dry-run option to see what changes would be made without
// applying them, or with a fix option to automatically apply the suggested fixes.
package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"

	// Import the local analyzer package
	"github.com/umbracore/protocolanalyzer/analyzer"
)

func main() {
	// Define command line arguments
	sourcePath := flag.String("path", "", "Path to the Swift source files (required)")
	outputPath := flag.String("output", "protocol_issues.csv", "Path to the output CSV file")
	generateFixes := flag.Bool("fix", false, "Generate fixes for identified issues")
	dryRun := flag.Bool("dry-run", true, "Show proposed changes without applying them (default: true)")
	
	// Add usage information
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "UmbraCore Protocol Analyzer\n\n")
		fmt.Fprintf(os.Stderr, "Usage: %s [options]\n\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExample:\n")
		fmt.Fprintf(os.Stderr, "  %s -path=/Users/mpy/CascadeProjects/UmbraCore/Sources/SecurityBridge -dry-run\n", os.Args[0])
	}
	
	flag.Parse()

	// Validate required arguments
	if *sourcePath == "" {
		fmt.Println("Error: Path to Swift source files is required")
		flag.Usage()
		os.Exit(1)
	}
	
	// Resolve absolute path
	absPath, err := filepath.Abs(*sourcePath)
	if err != nil {
		log.Fatalf("Failed to resolve absolute path: %v", err)
	}
	
	// Check if the path exists
	_, err = os.Stat(absPath)
	if os.IsNotExist(err) {
		log.Fatalf("Path does not exist: %s", absPath)
	}
	
	// Run the analyzer
	fmt.Printf("Analyzing Swift files in: %s\n", absPath)
	fmt.Printf("Results will be written to: %s\n", *outputPath)
	fmt.Printf("Dry run mode: %v\n", *dryRun)
	fmt.Printf("Apply fixes: %v\n\n", *generateFixes)
	
	// Call the protocol analyzer package's Run function
	err = analyzer.Run(absPath, *outputPath, *generateFixes, *dryRun)
	if err != nil {
		log.Fatalf("Error running analyzer: %v", err)
	}
	
	fmt.Println("Analysis complete!")
}
