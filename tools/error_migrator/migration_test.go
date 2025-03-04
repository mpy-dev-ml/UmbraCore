package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

// TestParseErrorAnalysisReport tests the parsing of error analysis reports
func TestParseErrorAnalysisReport(t *testing.T) {
	// Create a temporary file with test data
	tempFile, err := os.CreateTemp("", "error_analysis_*.md")
	if err != nil {
		t.Fatalf("failed to create temp file: %v", err)
	}
	defer os.Remove(tempFile.Name())

	// Write test data to the file
	testData := `# Error Analysis Report

## Error Definitions

### SecurityError (SecurityProtocolsCore)
- **File**: Sources/SecurityProtocolsCore/SecurityError.swift:10
- **Public**: true
- **Cases**:
  - unauthorized
  - invalidCredentials
  - accessDenied
- **Imported By**: [SecurityBridge UmbraSecurity SecurityInterfaces]
- **Referenced By**: 35 files

### SecurityError (XPCProtocolsCore)
- **File**: Sources/XPCProtocolsCore/SecurityError.swift:15
- **Public**: true
- **Cases**:
  - unauthorized
  - invalidCredentials
  - accessDenied
  - sessionExpired
- **Imported By**: [XPCBridge XPCService SecurityXPCService]
- **Referenced By**: 28 files

## Duplicated Error Types

- **SecurityError** defined in 2 modules:
  - SecurityProtocolsCore
  - XPCProtocolsCore

- **ResourceError** defined in 4 modules:
  - ResourceManagementCore
  - StorageCore
  - BackupCore
  - NetworkingCore

## CoreErrors Migration Plan

...`

	if _, err := tempFile.Write([]byte(testData)); err != nil {
		t.Fatalf("failed to write to temp file: %v", err)
	}
	tempFile.Close()

	// Call the function with the test file
	errorDefs, duplicatedErrors, err := ParseErrorAnalysisReport(tempFile.Name())
	if err != nil {
		t.Fatalf("ParseErrorAnalysisReport failed: %v", err)
	}

	// Verify the results
	if len(errorDefs) != 2 {
		t.Errorf("expected 2 error definitions, got %d", len(errorDefs))
	}

	if len(duplicatedErrors) != 2 {
		t.Errorf("expected 2 duplicated error types, got %d", len(duplicatedErrors))
	}

	// Check SecurityError in SecurityProtocolsCore
	found := false
	if errorDefs["SecurityProtocolsCore"] != nil {
		if def, exists := errorDefs["SecurityProtocolsCore"]["SecurityError"]; exists && def != nil {
			found = true
			if !def.IsPublic {
				t.Errorf("expected SecurityError to be public")
			}
			if len(def.CaseNames) != 3 {
				t.Errorf("expected 3 cases for SecurityError, got %d", len(def.CaseNames))
			}
		}
	}
	if !found {
		t.Errorf("SecurityError in SecurityProtocolsCore not found")
	}

	// Check SecurityError in duplicated errors
	modules, ok := duplicatedErrors["SecurityError"]
	if !ok {
		t.Errorf("SecurityError not found in duplicated errors")
	} else if len(modules) != 2 {
		t.Errorf("expected 2 modules for SecurityError, got %d", len(modules))
	}
}

// TestPlanMigration tests the migration planning
func TestPlanMigration(t *testing.T) {
	// Create test data in the new format (map[string]map[string]*ErrorDefinition)
	errorDefs := map[string]map[string]*ErrorDefinition{
		"SecurityProtocolsCore": {
			"SecurityError": &ErrorDefinition{
				ErrorName:   "SecurityError",
				ModuleName:  "SecurityProtocolsCore",
				FilePath:    "Sources/SecurityProtocolsCore/SecurityError.swift",
				LineNumber:  10,
				IsPublic:    true,
				IsEnum:      true,
				CaseNames:   []string{"unauthorized", "invalidCredentials", "accessDenied"},
				ImportedBy:  []string{"SecurityBridge", "UmbraSecurity", "SecurityInterfaces"},
			},
		},
		"XPCProtocolsCore": {
			"SecurityError": &ErrorDefinition{
				ErrorName:   "SecurityError",
				ModuleName:  "XPCProtocolsCore",
				FilePath:    "Sources/XPCProtocolsCore/SecurityError.swift",
				LineNumber:  15,
				IsPublic:    true,
				IsEnum:      true,
				CaseNames:   []string{"unauthorized", "invalidCredentials", "accessDenied", "sessionExpired"},
				ImportedBy:  []string{"XPCBridge", "XPCService", "SecurityXPCService"},
			},
		},
	}

	duplicatedErrors := map[string][]string{
		"SecurityError": {"SecurityProtocolsCore", "XPCProtocolsCore"},
	}

	config := MigrationConfig{
		TargetModule: "CoreErrors",
		ErrorsToMigrate: map[string][]string{
			"SecurityError": {"SecurityProtocolsCore", "XPCProtocolsCore"},
		},
		DryRun:    true,
		OutputDir: "./generated",
	}

	// Call the function with the test data
	migration, err := PlanMigration(config, errorDefs, duplicatedErrors)
	if err != nil {
		t.Fatalf("PlanMigration failed: %v", err)
	}

	// Verify the results
	if migration.TargetModule != "CoreErrors" {
		t.Errorf("expected target module CoreErrors, got %s", migration.TargetModule)
	}

	if len(migration.ErrorsToMigrate) != 2 {
		t.Errorf("expected 2 errors to migrate, got %d", len(migration.ErrorsToMigrate))
	}

	// Check that both SecurityError instances are included
	foundSPC := false
	foundXPC := false
	for _, errToMigrate := range migration.ErrorsToMigrate {
		if errToMigrate.ErrorName == "SecurityError" && errToMigrate.SourceModule == "SecurityProtocolsCore" {
			foundSPC = true
		}
		if errToMigrate.ErrorName == "SecurityError" && errToMigrate.SourceModule == "XPCProtocolsCore" {
			foundXPC = true
		}
	}
	if !foundSPC {
		t.Errorf("SecurityError in SecurityProtocolsCore not found in migration plan")
	}
	if !foundXPC {
		t.Errorf("SecurityError in XPCProtocolsCore not found in migration plan")
	}
}

// TestGenerateCode tests code generation
func TestGenerateCode(t *testing.T) {
	// Create test data
	migration := &Migration{
		TargetModule: "CoreErrors",
		ErrorsToMigrate: []ErrorToMigrate{
			{
				ErrorName:       "SecurityError",
				SourceModule:    "SecurityProtocolsCore",
				TargetModule:    "CoreErrors",
				CreateAlias:     true,
				AliasModuleName: "SecurityProtocolsCore",
			},
			{
				ErrorName:       "SecurityError",
				SourceModule:    "XPCProtocolsCore",
				TargetModule:    "CoreErrors",
				CreateAlias:     true,
				AliasModuleName: "XPCProtocolsCore",
			},
		},
	}

	errorDefs := map[string]map[string]*ErrorDefinition{
		"SecurityProtocolsCore": {
			"SecurityError": &ErrorDefinition{
				ErrorName:   "SecurityError",
				ModuleName:  "SecurityProtocolsCore",
				FilePath:    "Sources/SecurityProtocolsCore/SecurityError.swift",
				LineNumber:  10,
				IsPublic:    true,
				IsEnum:      true,
				CaseNames:   []string{"unauthorized", "invalidCredentials", "accessDenied"},
				ImportedBy:  []string{"SecurityBridge", "UmbraSecurity", "SecurityInterfaces"},
			},
		},
		"XPCProtocolsCore": {
			"SecurityError": &ErrorDefinition{
				ErrorName:   "SecurityError",
				ModuleName:  "XPCProtocolsCore",
				FilePath:    "Sources/XPCProtocolsCore/SecurityError.swift",
				LineNumber:  15,
				IsPublic:    true,
				IsEnum:      true,
				CaseNames:   []string{"unauthorized", "invalidCredentials", "accessDenied", "sessionExpired"},
				ImportedBy:  []string{"XPCBridge", "XPCService", "SecurityXPCService"},
			},
		},
	}

	// Call the function with the test data
	code, err := GenerateCode(migration, errorDefs)
	if err != nil {
		t.Fatalf("GenerateCode failed: %v", err)
	}

	// Verify the results
	expectedErrorNames := []string{"SecurityError"}
	for _, name := range expectedErrorNames {
		if _, ok := code.TargetModuleCode[name]; !ok {
			t.Errorf("Error %s not found in target module code", name)
		}
	}

	if _, ok := code.AliasModuleCode["SecurityProtocolsCore"]; !ok {
		t.Errorf("SecurityProtocolsCore not found in alias module code")
	}

	if _, ok := code.AliasModuleCode["XPCProtocolsCore"]; !ok {
		t.Errorf("XPCProtocolsCore not found in alias module code")
	}
}

// TestLoadMigrationConfig tests loading migration configuration
func TestLoadMigrationConfig(t *testing.T) {
	// Create a temporary file with test data
	tempFile, err := os.CreateTemp("", "migration_config_*.json")
	if err != nil {
		t.Fatalf("failed to create temp file: %v", err)
	}
	defer os.Remove(tempFile.Name())

	// Create test configuration
	testConfig := MigrationConfig{
		TargetModule: "CoreErrors",
		ErrorsToMigrate: map[string][]string{
			"SecurityError": {"SecurityProtocolsCore", "XPCProtocolsCore"},
			"ResourceError": {"ResourceManagementCore", "StorageCore"},
		},
		DryRun:    true,
		OutputDir: "./generated",
	}

	// Convert to JSON and write to file
	data, err := json.MarshalIndent(testConfig, "", "  ")
	if err != nil {
		t.Fatalf("failed to marshal test config: %v", err)
	}

	if err := os.WriteFile(tempFile.Name(), data, 0644); err != nil {
		t.Fatalf("failed to write to temp file: %v", err)
	}

	// Call the function with the test file
	loadedConfig, err := LoadMigrationConfig(tempFile.Name())
	if err != nil {
		t.Fatalf("LoadMigrationConfig failed: %v", err)
	}

	// Verify the results
	if loadedConfig.TargetModule != testConfig.TargetModule {
		t.Errorf("expected target module %s, got %s", testConfig.TargetModule, loadedConfig.TargetModule)
	}

	if !reflect.DeepEqual(loadedConfig.ErrorsToMigrate, testConfig.ErrorsToMigrate) {
		t.Errorf("errors to migrate do not match expected")
	}

	if loadedConfig.DryRun != testConfig.DryRun {
		t.Errorf("expected dry run %v, got %v", testConfig.DryRun, loadedConfig.DryRun)
	}

	if loadedConfig.OutputDir != testConfig.OutputDir {
		t.Errorf("expected output dir %s, got %s", testConfig.OutputDir, loadedConfig.OutputDir)
	}
}

// TestWriteGeneratedCode tests writing generated code
func TestWriteGeneratedCode(t *testing.T) {
	// Create test data
	generatedCode := &GeneratedCode{
		TargetModuleCode: map[string]string{
			"SecurityError": "// SecurityError.swift\npublic enum SecurityError: Error {\n    case unauthorized\n    case invalidCredentials\n}",
		},
		AliasModuleCode: map[string]string{
			"SecurityProtocolsCore": "// SecurityProtocolsCore_Aliases.swift\npublic typealias SecurityError = CoreErrors.SecurityError",
		},
	}

	// Create a temporary directory for output
	tempDir, err := os.MkdirTemp("", "generated_code_")
	if err != nil {
		t.Fatalf("failed to create temp directory: %v", err)
	}
	defer os.RemoveAll(tempDir)

	// Call the function with the test data
	err = WriteGeneratedCode(generatedCode, tempDir, false)
	if err != nil {
		t.Fatalf("WriteGeneratedCode failed: %v", err)
	}

	// Check if target module directory was created
	coreErrorsDir := filepath.Join(tempDir, "CoreErrors")
	if _, err := os.Stat(coreErrorsDir); os.IsNotExist(err) {
		t.Errorf("CoreErrors directory not created")
	}

	// Check if error file was created
	securityErrorFile := filepath.Join(coreErrorsDir, "SecurityError.swift")
	if _, err := os.Stat(securityErrorFile); os.IsNotExist(err) {
		t.Errorf("SecurityError.swift not created")
	}

	// Check if alias directory and file were created
	securityProtocolsDir := filepath.Join(tempDir, "SecurityProtocolsCore")
	if _, err := os.Stat(securityProtocolsDir); os.IsNotExist(err) {
		t.Errorf("SecurityProtocolsCore directory not created")
	}

	aliasFile := filepath.Join(securityProtocolsDir, "SecurityProtocolsCore_Aliases.swift")
	if _, err := os.Stat(aliasFile); os.IsNotExist(err) {
		t.Errorf("SecurityProtocolsCore_Aliases.swift not created")
	}
}

// TestUpdateImports tests the import statement updating functionality
func TestUpdateImports(t *testing.T) {
	// Create a temporary directory for test files
	tmpDir, err := os.MkdirTemp("", "import_test")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	// Create a test file with imports
	testFile := filepath.Join(tmpDir, "test_file.swift")
	testContent := `import Foundation
import SecurityProtocolsCore
import UIKit

func handleError(error: SecurityError) {
    // Handle the error
}
`
	err = os.WriteFile(testFile, []byte(testContent), 0644)
	if err != nil {
		t.Fatalf("failed to write test file: %v", err)
	}

	// Create migration data
	migration := &Migration{
		TargetModule: "CoreErrors",
		ErrorsToMigrate: []ErrorToMigrate{
			{
				ErrorName:       "SecurityError",
				SourceModule:    "SecurityProtocolsCore",
				TargetModule:    "CoreErrors",
				CreateAlias:     true,
				AliasModuleName: "SecurityProtocolsCore",
			},
		},
	}

	// File references for the error
	fileRefs := []string{testFile}

	// Update imports
	updatedFiles, err := UpdateImports(migration, fileRefs)
	if err != nil {
		t.Fatalf("UpdateImports failed: %v", err)
	}

	// Verify results
	if len(updatedFiles) != 1 {
		t.Errorf("expected 1 updated file, got %d", len(updatedFiles))
	}

	// Read the updated content
	updatedContent := updatedFiles[testFile]
	
	// Check if CoreErrors import was added
	if !strings.Contains(updatedContent, "import CoreErrors") {
		t.Errorf("CoreErrors import not added to the file")
	}

	// Check if original import is still there (should be for backward compatibility)
	if !strings.Contains(updatedContent, "import SecurityProtocolsCore") {
		t.Errorf("SecurityProtocolsCore import was removed, but should be kept for backward compatibility")
	}

	// Check if other imports were preserved
	if !strings.Contains(updatedContent, "import Foundation") || !strings.Contains(updatedContent, "import UIKit") {
		t.Errorf("existing imports were not preserved")
	}
}
