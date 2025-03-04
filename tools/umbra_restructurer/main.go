package main

import (
	"bytes"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"
)

// Configuration for the restructuring
type Config struct {
	ProjectRoot   string
	DryRun        bool
	Verbose       bool
	SkipBazelConf bool
	SkipScripts   bool
}

// Operation represents a single file or directory operation
type Operation struct {
	Type        string // "create_dir", "move_file", "create_file", "update_file", "move_dir"
	Source      string
	Destination string
	Content     string
}

// Templates for various files
var buildFileTemplate = `load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("//:bazel/macros/swift.bzl", "umbra_swift_library")

umbra_swift_library(
    name = "{{.Name}}",
    srcs = glob(["**/*.swift"]),
    {{if .TestOnly}}testonly = True,{{end}}
    deps = [{{range .Dependencies}}
        "{{.}}",{{end}}
    ],
)
`

var testBuildFileTemplate = `load("@build_bazel_rules_swift//swift:swift.bzl", "swift_test")
load("//:bazel/macros/swift.bzl", "umbra_swift_test")

umbra_swift_test(
    name = "{{.Name}}",
    srcs = glob(["**/*.swift"]),
    deps = [{{range .Dependencies}}
        "{{.}}",{{end}}
    ],
)
`

var bazelrcContent = `
# Production build - no tests
build:prod --build_tag_filters=-test
build:prod --compilation_mode=opt

# Development build with tests
build:dev --compilation_mode=dbg

# Test-only build
build:test --build_tag_filters=test
`

var buildProdScript = `#!/bin/bash
# Build only production code
bazel build --config=prod //Sources/...
`

var buildTestScript = `#!/bin/bash
# Build and run all tests
bazel test --config=dev //...
`

var buildAffectedScript = `#!/bin/bash
# Build only targets affected by changes since the last commit
# This is a simplified version - you may want to enhance it

CHANGED_FILES=$(git diff --name-only HEAD~1)
TARGETS=()

for file in $CHANGED_FILES; do
    dir=$(dirname "$file")
    while [[ "$dir" != "." && "$dir" != "/" ]]; do
        if [[ -f "$dir/BUILD.bazel" ]]; then
            target="//$(echo $dir | sed 's/^\.\///')"
            TARGETS+=("$target")
            break
        fi
        dir=$(dirname "$dir")
    done
done

# Remove duplicates
UNIQUE_TARGETS=($(echo "${TARGETS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

if [[ ${#UNIQUE_TARGETS[@]} -eq 0 ]]; then
    echo "No targets affected by recent changes"
    exit 0
fi

echo "Building affected targets: ${UNIQUE_TARGETS[@]}"
bazel build "${UNIQUE_TARGETS[@]}"
`

// BuildFileData holds data for BUILD file templates
type BuildFileData struct {
	Name         string
	TestOnly     bool
	Visibility   []string
	Dependencies []string
}

func main() {
	// Parse command line flags
	config := parseFlags()

	// Validate project root
	if _, err := os.Stat(config.ProjectRoot); os.IsNotExist(err) {
		log.Fatalf("Project root directory does not exist: %s", config.ProjectRoot)
	}

	// Plan operations
	operations := planOperations(config)

	// Execute or dry run
	if config.DryRun {
		printOperations(operations)
	} else {
		executeOperations(operations)
	}
}

func parseFlags() Config {
	config := Config{}

	flag.StringVar(&config.ProjectRoot, "root", ".", "Root directory of the UmbraCore project")
	flag.BoolVar(&config.DryRun, "dry-run", false, "Perform a dry run without making changes")
	flag.BoolVar(&config.Verbose, "verbose", false, "Enable verbose output")
	flag.BoolVar(&config.SkipBazelConf, "skip-bazel", false, "Skip Bazel configuration updates")
	flag.BoolVar(&config.SkipScripts, "skip-scripts", false, "Skip build script creation")

	flag.Parse()

	// Convert to absolute path
	absPath, err := filepath.Abs(config.ProjectRoot)
	if err != nil {
		log.Fatalf("Failed to get absolute path: %v", err)
	}
	config.ProjectRoot = absPath

	return config
}

func planOperations(config Config) []Operation {
	operations := []Operation{}

	// 1. Create directory structure
	dirs := []string{
		"TestSupport/Security",
		"TestSupport/Core",
		"TestSupport/Common",
		"Sources/CoreServicesTypes",
		"TestSupport/Security/SecurityInterfacesForTesting",
	}

	for _, dir := range dirs {
		fullPath := filepath.Join(config.ProjectRoot, dir)
		operations = append(operations, Operation{
			Type:        "create_dir",
			Destination: fullPath,
		})
	}

	// 2. Move SecurityInterfacesForTesting
	securityInterfacesDir := filepath.Join(config.ProjectRoot, "Sources/SecurityInterfaces")
	testSupportDir := filepath.Join(config.ProjectRoot, "TestSupport/Security/SecurityInterfacesForTesting")

	// Find Swift files in SecurityInterfaces that are for testing
	files, err := filepath.Glob(filepath.Join(securityInterfacesDir, "*.swift"))
	if err != nil {
		log.Fatalf("Failed to glob files: %v", err)
	}

	for _, file := range files {
		// Check if file is test-related (simplified heuristic)
		content, err := ioutil.ReadFile(file)
		if err != nil {
			log.Printf("Warning: Failed to read file %s: %v", file, err)
			continue
		}

		if bytes.Contains(content, []byte("ForTesting")) || bytes.Contains(content, []byte("Mock")) {
			destFile := filepath.Join(testSupportDir, filepath.Base(file))
			operations = append(operations, Operation{
				Type:        "move_file",
				Source:      file,
				Destination: destFile,
			})
		}
	}

	// 3. Move UmbraTestKit to TestSupport
	umbraTestKitPath := filepath.Join(config.ProjectRoot, "Sources/UmbraTestKit")
	if _, err := os.Stat(umbraTestKitPath); err == nil {
		destPath := filepath.Join(config.ProjectRoot, "TestSupport/UmbraTestKit")
		operations = append(operations, Operation{
			Type:        "move_dir",
			Source:      umbraTestKitPath,
			Destination: destPath,
		})
	}

	// 4. Create BUILD files for TestSupport
	buildFiles := map[string]BuildFileData{
		"TestSupport/Security": {
			Name:     "SecurityTestSupport",
			TestOnly: true,
			Visibility: []string{},
			Dependencies: []string{
				"//Sources/SecurityInterfaces",
				"//Sources/SecurityTypes",
			},
		},
		"TestSupport/Core": {
			Name:     "CoreTestSupport",
			TestOnly: true,
			Visibility: []string{},
			Dependencies: []string{
				"//Sources/Core",
				"//Sources/CoreTypes",
			},
		},
		"TestSupport/Common": {
			Name:     "CommonTestSupport",
			TestOnly: true,
			Visibility: []string{},
			Dependencies: []string{
				"//Sources/CoreTypes",
			},
		},
		"Sources/CoreServicesTypes": {
			Name:     "CoreServicesTypes",
			TestOnly: false,
			Visibility: []string{},
			Dependencies: []string{},
		},
		"TestSupport/Security/SecurityInterfacesForTesting": {
			Name:     "SecurityInterfacesForTesting",
			TestOnly: true,
			Visibility: []string{},
			Dependencies: []string{
				"//Sources/SecurityInterfaces:SecurityInterfacesCore",
				"//Sources/SecurityInterfaces:SecurityInterfacesFoundation",
			},
		},
	}

	for dir, data := range buildFiles {
		var buf bytes.Buffer
		tmpl, err := template.New("build").Parse(buildFileTemplate)
		if err != nil {
			log.Fatalf("Failed to parse template: %v", err)
		}

		err = tmpl.Execute(&buf, data)
		if err != nil {
			log.Fatalf("Failed to execute template: %v", err)
		}

		buildFilePath := filepath.Join(config.ProjectRoot, dir, "BUILD.bazel")
		operations = append(operations, Operation{
			Type:        "create_file",
			Destination: buildFilePath,
			Content:     buf.String(),
		})
	}

	// 5. Update imports in test files that reference moved mocks
	testFiles := []string{
		"Tests/CoreTests/URLSecurityTests.swift",
		"Tests/CoreTests/CoreServiceTests.swift",
	}

	for _, testFile := range testFiles {
		fullPath := filepath.Join(config.ProjectRoot, testFile)
		if _, err := os.Stat(fullPath); err == nil {
			content, err := ioutil.ReadFile(fullPath)
			if err != nil {
				log.Printf("Warning: Failed to read test file %s: %v", fullPath, err)
				continue
			}

			// Update import statements
			updatedContent := string(content)
			updatedContent = strings.ReplaceAll(updatedContent, "import UmbraTestKit", "import UmbraTestKit\nimport SecurityTestSupport")
			
			if updatedContent != string(content) {
				operations = append(operations, Operation{
					Type:        "update_file",
					Destination: fullPath,
					Content:     updatedContent,
				})
			}
		}
	}

	// 6. Move ServiceState.swift to CoreServicesTypes
	serviceStatePath := filepath.Join(config.ProjectRoot, "Sources/Core/Services/Types/ServiceState.swift")
	if _, err := os.Stat(serviceStatePath); err == nil {
		destPath := filepath.Join(config.ProjectRoot, "Sources/CoreServicesTypes/ServiceState.swift")
		operations = append(operations, Operation{
			Type:        "move_file",
			Source:      serviceStatePath,
			Destination: destPath,
		})
	}

	// 7. Update CryptoTestCase.swift
	cryptoTestCasePath := filepath.Join(config.ProjectRoot, "Tests/UmbraTestKit/Sources/UmbraTestKit/Categories/Crypto/CryptoTestCase.swift")
	if _, err := os.Stat(cryptoTestCasePath); err == nil {
		content, err := ioutil.ReadFile(cryptoTestCasePath)
		if err != nil {
			log.Printf("Warning: Failed to read CryptoTestCase.swift: %v", err)
		} else {
			// Update method signatures
			updatedContent := updateMethodSignatures(string(content))
			operations = append(operations, Operation{
				Type:        "update_file",
				Destination: cryptoTestCasePath,
				Content:     updatedContent,
			})
		}
	}

	// 8. Update .bazelrc
	if !config.SkipBazelConf {
		bazelrcPath := filepath.Join(config.ProjectRoot, ".bazelrc")
		operations = append(operations, Operation{
			Type:        "update_file",
			Destination: bazelrcPath,
			Content:     bazelrcContent,
		})
	}

	// 9. Create build scripts
	if !config.SkipScripts {
		scripts := map[string]string{
			"build_prod.sh":     buildProdScript,
			"build_test.sh":     buildTestScript,
			"build_affected.sh": buildAffectedScript,
		}

		for name, content := range scripts {
			scriptPath := filepath.Join(config.ProjectRoot, name)
			operations = append(operations, Operation{
				Type:        "create_file",
				Destination: scriptPath,
				Content:     content,
			})
		}
	}

	return operations
}

func updateMethodSignatures(content string) string {
	// Replace setUp(isolated:) with setUp()
	setUpPattern := regexp.MustCompile(`func setUp\(isolated:.*?\)`)
	content = setUpPattern.ReplaceAllString(content, "func setUp()")

	// Replace tearDown(isolated:) with tearDown()
	tearDownPattern := regexp.MustCompile(`func tearDown\(isolated:.*?\)`)
	content = tearDownPattern.ReplaceAllString(content, "func tearDown()")

	return content
}

func printOperations(operations []Operation) {
	fmt.Println("=== DRY RUN MODE - No changes will be made ===")
	fmt.Printf("Planned operations: %d\n\n", len(operations))

	for i, op := range operations {
		fmt.Printf("Operation %d: %s\n", i+1, op.Type)

		switch op.Type {
		case "create_dir":
			fmt.Printf("  Create directory: %s\n", op.Destination)
		case "move_file":
			fmt.Printf("  Move file from: %s\n", op.Source)
			fmt.Printf("  To: %s\n", op.Destination)
		case "create_file":
			fmt.Printf("  Create file: %s\n", op.Destination)
			fmt.Printf("  Content length: %d bytes\n", len(op.Content))
			if len(op.Content) < 200 {
				fmt.Printf("  Content preview: %s\n", op.Content)
			} else {
				fmt.Printf("  Content preview: %s...\n", op.Content[:200])
			}
		case "update_file":
			fmt.Printf("  Update file: %s\n", op.Destination)
			fmt.Printf("  New content length: %d bytes\n", len(op.Content))
		case "move_dir":
			fmt.Printf("  Move directory from: %s\n", op.Source)
			fmt.Printf("  To: %s\n", op.Destination)
		}
		fmt.Println()
	}

	fmt.Println("=== End of dry run - Run without --dry-run to apply changes ===")
}

func executeOperations(operations []Operation) {
	fmt.Printf("Executing %d operations...\n", len(operations))

	for i, op := range operations {
		fmt.Printf("[%d/%d] %s: ", i+1, len(operations), op.Type)

		var err error
		switch op.Type {
		case "create_dir":
			err = os.MkdirAll(op.Destination, 0755)
			fmt.Printf("Creating directory %s\n", op.Destination)

		case "move_file":
			// Ensure destination directory exists
			destDir := filepath.Dir(op.Destination)
			err = os.MkdirAll(destDir, 0755)
			if err != nil {
				fmt.Printf("Failed to create destination directory: %v\n", err)
				continue
			}

			// Read source file
			content, err := ioutil.ReadFile(op.Source)
			if err != nil {
				fmt.Printf("Failed to read source file: %v\n", err)
				continue
			}

			// Write to destination
			err = ioutil.WriteFile(op.Destination, content, 0644)
			if err != nil {
				fmt.Printf("Failed to write destination file: %v\n", err)
				continue
			}

			// Remove source file
			err = os.Remove(op.Source)
			fmt.Printf("Moving %s to %s\n", op.Source, op.Destination)

		case "create_file":
			// Ensure destination directory exists
			destDir := filepath.Dir(op.Destination)
			err = os.MkdirAll(destDir, 0755)
			if err != nil {
				fmt.Printf("Failed to create destination directory: %v\n", err)
				continue
			}

			// Create file
			err = ioutil.WriteFile(op.Destination, []byte(op.Content), 0644)
			fmt.Printf("Creating file %s\n", op.Destination)

			// Make scripts executable
			if strings.HasSuffix(op.Destination, ".sh") {
				err = os.Chmod(op.Destination, 0755)
				if err != nil {
					fmt.Printf("Failed to make script executable: %v\n", err)
				}
			}

		case "update_file":
			// Check if file exists
			_, err = os.Stat(op.Destination)
			if os.IsNotExist(err) {
				// Create file if it doesn't exist
				destDir := filepath.Dir(op.Destination)
				err = os.MkdirAll(destDir, 0755)
				if err != nil {
					fmt.Printf("Failed to create destination directory: %v\n", err)
					continue
				}
			}

			// Update file
			err = ioutil.WriteFile(op.Destination, []byte(op.Content), 0644)
			fmt.Printf("Updating file %s\n", op.Destination)

		case "move_dir":
			// Ensure destination directory exists
			destDir := filepath.Dir(op.Destination)
			err = os.MkdirAll(destDir, 0755)
			if err != nil {
				fmt.Printf("Failed to create destination directory: %v\n", err)
				continue
			}

			// Move directory
			err = os.Rename(op.Source, op.Destination)
			fmt.Printf("Moving directory %s to %s\n", op.Source, op.Destination)
		}

		if err != nil {
			fmt.Printf("Failed: %v\n", err)
		}
	}

	fmt.Println("Restructuring complete!")
}
