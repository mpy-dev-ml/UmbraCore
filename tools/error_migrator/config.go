package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
)

// LoadMigrationConfig loads migration configuration from a JSON file
func LoadMigrationConfig(configPath string) (*MigrationConfig, error) {
	data, err := ioutil.ReadFile(configPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %v", err)
	}
	
	var config MigrationConfig
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("failed to parse config file: %v", err)
	}
	
	// Validate config
	if config.TargetModule == "" {
		return nil, fmt.Errorf("target module is required")
	}
	
	if len(config.ErrorsToMigrate) == 0 {
		return nil, fmt.Errorf("at least one error to migrate is required")
	}
	
	return &config, nil
}

// CreateDefaultConfigFile creates a default migration configuration file
func CreateDefaultConfigFile(outputPath string, duplicatedErrors map[string][]string, errorDefs map[string]map[string]*ErrorDefinition) error {
	// Create a default config
	config := MigrationConfig{
		TargetModule:    "SharedErrors",
		ErrorsToMigrate: map[string][]string{},
		DryRun:          true,
		OutputDir:       "./generated_code",
	}

	// Add duplicated errors to config
	for errorName, modules := range duplicatedErrors {
		// Check for namespace conflicts
		hasConflict := false
		// Check if any module has a namespace conflict
		
		for _, module := range modules {
			// Check if module has an enum with the same name
			if errorDefs[module] != nil {
				for defName := range errorDefs[module] {
					if defName == module {
						hasConflict = true
						break
					}
				}
			}
			if hasConflict {
				break
			}
		}
		
		// Add to config
		config.ErrorsToMigrate[errorName] = modules
	}
	
	// Convert to JSON
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal config: %v", err)
	}
	
	// Write to file
	if err := ioutil.WriteFile(outputPath, data, 0644); err != nil {
		return fmt.Errorf("failed to write config file: %v", err)
	}
	
	return nil
}
