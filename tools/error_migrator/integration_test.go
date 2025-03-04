package main

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

func TestEndToEndWorkflow(t *testing.T) {
	// Create a temporary directory for the test
	tempDir, err := os.MkdirTemp("", "error_migrator_test")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	// Create test error analysis report
	reportPath := filepath.Join(tempDir, "error_analysis_report.md")
	createTestErrorReport(t, reportPath)

	// Create test Swift files
	swiftFilesDir := filepath.Join(tempDir, "Sources")
	createTestSwiftFiles(t, swiftFilesDir)

	// Create output directory
	outputDir := filepath.Join(tempDir, "generated")
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		t.Fatalf("Failed to create output directory: %v", err)
	}

	// Step 1: Parse the error analysis report
	errorDefs, duplicatedErrors, err := ParseErrorAnalysisReport(reportPath)
	if err != nil {
		t.Fatalf("Failed to parse error analysis report: %v", err)
	}

	if len(errorDefs) == 0 {
		t.Errorf("No error definitions found in report")
	}

	if len(duplicatedErrors) == 0 {
		t.Errorf("No duplicated errors found in report")
	}

	// Step 2: Create default migration config
	configPath := filepath.Join(tempDir, "migration_config.json")
	
	// Create a mock errorDefs
	mockErrorDefs := make(map[string]map[string]*ErrorDefinition)
	for module, _ := range duplicatedErrors {
		mockErrorDefs[module] = make(map[string]*ErrorDefinition)
	}
	
	if err := CreateDefaultConfigFile(configPath, duplicatedErrors, mockErrorDefs); err != nil {
		t.Fatalf("Failed to create default config file: %v", err)
	}

	// Check if config file exists
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		t.Errorf("Config file was not created")
	}

	// Step 3: Load migration config
	configData, err := ioutil.ReadFile(configPath)
	if err != nil {
		t.Fatalf("Failed to read config file: %v", err)
	}

	var config MigrationConfig
	if err := json.Unmarshal(configData, &config); err != nil {
		t.Fatalf("Failed to parse config file: %v", err)
	}

	// Step 4: Plan migration
	migration, err := PlanMigration(config, errorDefs, duplicatedErrors)
	if err != nil {
		t.Fatalf("Failed to plan migration: %v", err)
	}

	// Step 5: Validate migration
	if err := ValidateMigration(migration, errorDefs); err != nil {
		t.Fatalf("Migration validation failed: %v", err)
	}

	// Step 6: Generate code
	generatedCode, err := GenerateCode(migration, errorDefs)
	if err != nil {
		t.Fatalf("Failed to generate code: %v", err)
	}

	// Check generated code
	if len(generatedCode.TargetModuleCode) == 0 {
		t.Errorf("No code generated for target module")
	}

	if len(generatedCode.AliasModuleCode) == 0 {
		t.Errorf("No code generated for aliases")
	}

	// Step 7: Write generated code
	if err := WriteGeneratedCode(generatedCode, outputDir, false); err != nil {
		t.Fatalf("Failed to write generated code: %v", err)
	}

	// Check if files were created
	coreErrorsDir := filepath.Join(outputDir, "CoreErrors")
	if _, err := os.Stat(coreErrorsDir); os.IsNotExist(err) {
		t.Errorf("CoreErrors directory was not created")
	}

	// Check if error file exists
	for errorName := range config.ErrorsToMigrate {
		errorFilePath := filepath.Join(coreErrorsDir, errorName+".swift")
		if _, err := os.Stat(errorFilePath); os.IsNotExist(err) {
			t.Errorf("Error file %s was not created", errorName+".swift")
		}
	}

	// Check if alias files exist
	for module := range config.ErrorsToMigrate {
		for _, sourceModule := range config.ErrorsToMigrate[module] {
			aliasFilePath := filepath.Join(outputDir, sourceModule, sourceModule+"_Aliases.swift")
			if _, err := os.Stat(aliasFilePath); os.IsNotExist(err) {
				t.Errorf("Alias file %s was not created", sourceModule+"_Aliases.swift")
			}
		}
	}
}

// Helper function to create a test error analysis report
func createTestErrorReport(t *testing.T, reportPath string) {
	reportContent := `# Error Analysis Report

## Error Definitions

### SecurityError (SecurityProtocolsCore)
- **File**: Sources/SecurityProtocolsCore/SecurityError.swift:10
- **Public**: true
- **Cases**:
  - unauthorized
  - invalidCredentials
  - accessDenied
- **Imported By**: [SecurityBridge UmbraSecurity SecurityInterfaces]
- **Referenced By**: 2 files
  - Sources/SecurityBridge/SecurityProvider.swift
  - Sources/UmbraSecurity/SecurityManager.swift

### SecurityError (XPCProtocolsCore)
- **File**: Sources/XPCProtocolsCore/SecurityError.swift:15
- **Public**: true
- **Cases**:
  - unauthorized
  - invalidCredentials
  - accessDenied
  - sessionExpired
- **Imported By**: [XPCBridge XPCService SecurityXPCService]
- **Referenced By**: 1 files
  - Sources/XPCService/XPCServiceHandler.swift

## Duplicated Error Types

- **SecurityError** defined in 2 modules:
  - SecurityProtocolsCore
  - XPCProtocolsCore

## CoreErrors Migration Plan

...`

	if err := ioutil.WriteFile(reportPath, []byte(reportContent), 0644); err != nil {
		t.Fatalf("Failed to write test error report: %v", err)
	}
}

// Helper function to create test Swift files
func createTestSwiftFiles(t *testing.T, baseDir string) {
	// Create SecurityBridge/SecurityProvider.swift
	securityBridgeDir := filepath.Join(baseDir, "SecurityBridge")
	if err := os.MkdirAll(securityBridgeDir, 0755); err != nil {
		t.Fatalf("Failed to create directory: %v", err)
	}

	securityProviderContent := `import Foundation
import SecurityProtocolsCore

public class SecurityProvider {
    func authenticate() throws {
        throw SecurityError.unauthorized
    }
}`

	if err := ioutil.WriteFile(filepath.Join(securityBridgeDir, "SecurityProvider.swift"), []byte(securityProviderContent), 0644); err != nil {
		t.Fatalf("Failed to write SecurityProvider.swift: %v", err)
	}

	// Create UmbraSecurity/SecurityManager.swift
	umbraSecurityDir := filepath.Join(baseDir, "UmbraSecurity")
	if err := os.MkdirAll(umbraSecurityDir, 0755); err != nil {
		t.Fatalf("Failed to create directory: %v", err)
	}

	securityManagerContent := `import Foundation
import SecurityProtocolsCore

public class SecurityManager {
    func validateCredentials() throws {
        throw SecurityError.invalidCredentials
    }
}`

	if err := ioutil.WriteFile(filepath.Join(umbraSecurityDir, "SecurityManager.swift"), []byte(securityManagerContent), 0644); err != nil {
		t.Fatalf("Failed to write SecurityManager.swift: %v", err)
	}

	// Create XPCService/XPCServiceHandler.swift
	xpcServiceDir := filepath.Join(baseDir, "XPCService")
	if err := os.MkdirAll(xpcServiceDir, 0755); err != nil {
		t.Fatalf("Failed to create directory: %v", err)
	}

	xpcServiceHandlerContent := `import Foundation
import XPCProtocolsCore

public class XPCServiceHandler {
    func handleRequest() throws {
        throw SecurityError.sessionExpired
    }
}`

	if err := ioutil.WriteFile(filepath.Join(xpcServiceDir, "XPCServiceHandler.swift"), []byte(xpcServiceHandlerContent), 0644); err != nil {
		t.Fatalf("Failed to write XPCServiceHandler.swift: %v", err)
	}
}
