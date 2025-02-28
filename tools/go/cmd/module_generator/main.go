package main

import (
	"bytes"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"text/template"
)

// Templates for various files
const (
	buildFileTemplate = `load("//tools/build_defs:umbracore_module.bzl", "umbracore_foundation_free_module")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_test")

umbracore_foundation_free_module(
    name = "{{.ModuleName}}",
    visibility = ["//visibility:public"],
)

swift_test(
    name = "{{.ModuleName}}Tests",
    srcs = glob(["Tests/*.swift"]),
    deps = [":{{.ModuleName}}"],
    tags = ["manual"],
)
`

	swiftFileTemplate = `// {{.ModuleName}}.swift - Foundation-free implementation
// Part of UmbraCore project
// Created {{.CreationDate}}

@frozen
public struct {{.ModuleName}} {
    // MARK: - Properties
    
    // MARK: - Initialisation
    
    /// Creates a new instance of {{.ModuleName}}.
    public init() {
        // Implementation
    }
    
    // MARK: - Methods
    
    /// Example method demonstrating Foundation-free implementation
    public func exampleMethod() -> Bool {
        return true
    }
}
`

	testFileTemplate = `// {{.ModuleName}}Tests.swift - Tests for Foundation-free implementation
// Part of UmbraCore project
// Created {{.CreationDate}}

import XCTest
@testable import {{.ModuleName}}

final class {{.ModuleName}}Tests: XCTestCase {
    // MARK: - Properties
    
    private var sut: {{.ModuleName}}!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        sut = {{.ModuleName}}()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialisation() {
        XCTAssertNotNil(sut)
    }
    
    func testExampleMethod() {
        XCTAssertTrue(sut.exampleMethod())
    }
}
`
)

// TemplateData holds the data for our templates
type TemplateData struct {
	ModuleName   string
	CreationDate string
}

func main() {
	// Define command-line flags
	moduleName := flag.String("name", "", "Name of the module to create (required)")
	outputDir := flag.String("output", "", "Base directory to create the module in (required)")
	
	// Parse flags
	flag.Parse()
	
	// Validate inputs
	if *moduleName == "" || *outputDir == "" {
		fmt.Println("Error: Module name and output directory are required")
		fmt.Println("Usage: module_generator -name ModuleName -output /path/to/directory")
		os.Exit(1)
	}
	
	// Set template data
	data := TemplateData{
		ModuleName:   *moduleName,
		CreationDate: "2025-02-28", // In a real implementation, use time.Now().Format()
	}
	
	// Create module directory structure
	moduleDir := filepath.Join(*outputDir, "Sources", *moduleName)
	sourceDir := filepath.Join(moduleDir, "Sources")
	testDir := filepath.Join(moduleDir, "Tests")
	
	// Create directories
	directories := []string{moduleDir, sourceDir, testDir}
	for _, dir := range directories {
		if err := os.MkdirAll(dir, 0755); err != nil {
			fmt.Printf("Error creating directory %s: %v\n", dir, err)
			os.Exit(1)
		}
	}
	
	// Define files to generate
	filesToGenerate := map[string]string{
		filepath.Join(moduleDir, "BUILD.bazel"):               buildFileTemplate,
		filepath.Join(sourceDir, fmt.Sprintf("%s.swift", *moduleName)): swiftFileTemplate,
		filepath.Join(testDir, fmt.Sprintf("%sTests.swift", *moduleName)): testFileTemplate,
	}
	
	// Generate files from templates
	for filePath, templateContent := range filesToGenerate {
		// Parse template
		tmpl, err := template.New(filepath.Base(filePath)).Parse(templateContent)
		if err != nil {
			fmt.Printf("Error parsing template for %s: %v\n", filePath, err)
			os.Exit(1)
		}
		
		// Execute template
		var buf bytes.Buffer
		if err := tmpl.Execute(&buf, data); err != nil {
			fmt.Printf("Error executing template for %s: %v\n", filePath, err)
			os.Exit(1)
		}
		
		// Write file
		if err := os.WriteFile(filePath, buf.Bytes(), 0644); err != nil {
			fmt.Printf("Error writing file %s: %v\n", filePath, err)
			os.Exit(1)
		}
		
		fmt.Printf("Created %s\n", filePath)
	}
	
	fmt.Printf("\nSuccessfully created module '%s' in %s\n", *moduleName, moduleDir)
	fmt.Printf("To build: bazel build //Sources/%s:%s\n", *moduleName, *moduleName)
	fmt.Printf("To test with Bazel: bazel test //Sources/%s:%sTests\n", *moduleName, *moduleName)
	fmt.Printf("To run tests directly: xcrun xctest -XCTest All /Users/mpy/.bazel/execroot/_main/bazel-out/darwin_arm64-opt/bin/Sources/%s/%sTests.xctest\n", *moduleName, *moduleName)
}
