package main

import (
	"fmt"
	"sort"
)

// PlanMigration creates a migration plan based on the provided configuration
func PlanMigration(config MigrationConfig, errorDefs map[string]map[string]*ErrorDefinition, duplicatedErrors map[string][]string) (*Migration, error) {
	migration := &Migration{
		TargetModule:       config.TargetModule,
		ErrorsToMigrate:    []ErrorToMigrate{},
		ErrorDefinitions:   make(map[string]*ErrorDefinition),
		NamespaceConflicts: make(map[string][]string),
	}

	// Process each error type to migrate
	for errorName, sourceModules := range config.ErrorsToMigrate {
		// Check if this error name exists in the duplicated errors
		if _, exists := duplicatedErrors[errorName]; !exists {
			return nil, fmt.Errorf("error '%s' is not in the list of duplicated errors", errorName)
		}

		// Validate source modules
		for _, sourceModule := range sourceModules {
			if _, exists := errorDefs[sourceModule][errorName]; !exists {
				return nil, fmt.Errorf("error '%s' not found in module '%s'", errorName, sourceModule)
			}
		}

		// Choose a reference error definition for the target module
		// We use the first source module's definition as the reference
		referenceModule := sourceModules[0]
		migration.ErrorDefinitions[errorName] = errorDefs[referenceModule][errorName]

		// Record the migration
		for _, sourceModule := range sourceModules {
			migration.ErrorsToMigrate = append(migration.ErrorsToMigrate, ErrorToMigrate{
				ErrorName:       errorName,
				SourceModule:    sourceModule,
				TargetModule:    config.TargetModule,
				CreateAlias:     true,
				AliasModuleName: sourceModule,
				// Set HasNamespaceConflict to false initially, we'll update it later
				HasNamespaceConflict: false,
			})
		}
		
		// Detect potential namespace conflicts
		for _, module := range sourceModules {
			hasConflict := false
			// Check if module has an enum with the same name as the module
			if errorDefs[module] != nil {
				for otherErrorName := range errorDefs[module] {
					// Case 1: Module has an enum with the same name as the module itself
					if otherErrorName == module {
						hasConflict = true
					}
				}
			}
			
			// Case 2: Module namespace has same name as another imported module
			// This checks for cases where both XPCProtocolsCore and SecurityProtocolsCore 
			// might be imported in the same file
			for i, errToMigrate := range migration.ErrorsToMigrate {
				if errToMigrate.SourceModule == module && errToMigrate.ErrorName == errorName {
					if hasConflict {
						// Mark this migration as having a namespace conflict
						errToMigrate.HasNamespaceConflict = true
						// Generate a suggested solution for this conflict
						errToMigrate.ConflictSolution = generateConflictSolution(module, errorName)
						migration.ErrorsToMigrate[i] = errToMigrate
						
						// Record the conflict
						if migration.NamespaceConflicts[module] == nil {
							migration.NamespaceConflicts[module] = []string{}
						}
						if !contains(migration.NamespaceConflicts[module], errorName) {
							migration.NamespaceConflicts[module] = append(migration.NamespaceConflicts[module], errorName)
						}
					}
				}
			}
		}
	}

	return migration, nil
}

// contains checks if a string slice contains a specific string
func contains(slice []string, str string) bool {
	for _, item := range slice {
		if item == str {
			return true
		}
	}
	return false
}

// generateConflictSolution generates a suggested solution for a namespace conflict
func generateConflictSolution(module, errorName string) string {
	return fmt.Sprintf(`
For references to %s.%s, consider these solutions:
1. Use contextual type inference where possible (e.g., 'throw %s')
2. Use type aliasing with a different name in problematic files (e.g., 'typealias %sError = %s.%s')
3. Import the %s module with an alias (e.g., 'import %s as %sModule')`,
		module, errorName, 
		errorName,
		module, module, errorName, 
		module, module, module)
}

// ValidateMigration validates a migration plan
func ValidateMigration(migration *Migration, errorDefs map[string]map[string]*ErrorDefinition) error {
	// Check for namespace conflicts
	if len(migration.NamespaceConflicts) > 0 {
		var conflictModules []string
		for module := range migration.NamespaceConflicts {
			conflictModules = append(conflictModules, module)
		}
		sort.Strings(conflictModules)
		
		warnings := "Warning: Potential namespace conflicts detected:\n"
		for _, module := range conflictModules {
			errorNames := migration.NamespaceConflicts[module]
			sort.Strings(errorNames)
			warnings += fmt.Sprintf("  - Module '%s' has potential namespace conflicts with errors: %v\n", 
				module, errorNames)
		}
		
		warnings += "\nThese conflicts may cause Swift compiler ambiguity when referencing error types.\n"
		warnings += "Please review the generated code carefully and consider the following recommendations:\n\n"
		warnings += "1. Avoid qualified names like 'ModuleName.ErrorName' where the module has an enum with the same name\n"
		warnings += "2. Use contextual type inference where possible\n"
		warnings += "3. In files that import multiple modules with conflicting error names, use import aliases\n"
		warnings += "   Example: import SecurityProtocolsCore as SPCore\n"
		warnings += "4. Consider using explicit type aliases in affected files\n"
		
		fmt.Println(warnings)
	}

	// Validate each error to migrate
	for _, errToMigrate := range migration.ErrorsToMigrate {
		// Make sure source module exists
		if _, exists := errorDefs[errToMigrate.SourceModule]; !exists {
			return fmt.Errorf("source module '%s' not found for error '%s'", 
				errToMigrate.SourceModule, errToMigrate.ErrorName)
		}
		
		// Make sure error exists in source module
		if _, exists := errorDefs[errToMigrate.SourceModule][errToMigrate.ErrorName]; !exists {
			return fmt.Errorf("error '%s' not found in module '%s'", 
				errToMigrate.ErrorName, errToMigrate.SourceModule)
		}
	}

	// Make sure we have error definitions for all errors to migrate
	for _, errToMigrate := range migration.ErrorsToMigrate {
		if _, exists := migration.ErrorDefinitions[errToMigrate.ErrorName]; !exists {
			return fmt.Errorf("missing error definition for '%s'", errToMigrate.ErrorName)
		}
	}

	return nil
}

// GetErrorDefinition gets the error definition for a specific error and module
func GetErrorDefinition(errorName, moduleName string, errorDefinitions map[string]map[string]*ErrorDefinition) (*ErrorDefinition, error) {
	if _, exists := errorDefinitions[moduleName]; !exists {
		return nil, fmt.Errorf("module '%s' not found", moduleName)
	}
	
	if _, exists := errorDefinitions[moduleName][errorName]; !exists {
		return nil, fmt.Errorf("error '%s' not found in module '%s'", errorName, moduleName)
	}
	
	return errorDefinitions[moduleName][errorName], nil
}
