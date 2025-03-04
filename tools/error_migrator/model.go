package main

// ErrorDefinition represents an error type definition
type ErrorDefinition struct {
	ErrorName       string   `json:"errorName"`
	ModuleName      string   `json:"moduleName"`
	FilePath        string   `json:"filePath"`
	IsPublic        bool     `json:"isPublic"`
	IsEnum          bool     `json:"isEnum"`          // Whether this is an enum or struct
	CaseNames       []string `json:"caseNames"`       // For enums, the case names
	CaseDetails     []string `json:"caseDetails"`     // For enums, additional details for each case
	ImportedBy      []string `json:"importedBy"`      // List of modules that import this error
	ReferencedFiles []string `json:"referencedFiles"` // List of files that reference this error
	LineNumber      int      `json:"lineNumber"`      // Line number in the file
}

// MigrationConfig represents the configuration for an error migration
type MigrationConfig struct {
	TargetModule    string              `json:"targetModule"`    // Target module for consolidated errors
	ErrorsToMigrate map[string][]string `json:"errorsToMigrate"` // Map of error name to source modules
	DryRun          bool                `json:"dryRun"`          // Whether to perform a dry run
	OutputDir       string              `json:"outputDir"`       // Output directory for generated files
}

// Migration represents a migration plan
type Migration struct {
	TargetModule       string                        // Target module for consolidated errors
	ErrorsToMigrate    []ErrorToMigrate              // List of errors to migrate
	ErrorDefinitions   map[string]*ErrorDefinition   // Maps error name to its definition
	NamespaceConflicts map[string][]string           // Maps module names to errors affected by namespace conflicts
}

// ErrorToMigrate represents an error to be migrated
type ErrorToMigrate struct {
	ErrorName           string // Name of the error
	SourceModule        string // Source module
	TargetModule        string // Target module
	CreateAlias         bool   // Whether to create an alias
	AliasModuleName     string // Name of the module for the alias
	HasNamespaceConflict bool   // Whether this error has a namespace conflict
	ConflictSolution    string // Suggested solution for resolving the conflict
}

// ErrorAnalysis represents an analysis of an error type
type ErrorAnalysis struct {
	ModuleName     string   // Module containing the error
	IsEnum         bool     // Whether the error is an enum
	HasCases       bool     // Whether the enum has cases
	CaseNames      []string // Names of enum cases
	IsPublic       bool     // Whether the error is public
	ReferencedBy   []string // Modules that reference this error
	FilePath       string   // Path to the file containing the error
}

// GeneratedCode represents generated code for a migration
type GeneratedCode struct {
	TargetModuleCode map[string]string // Maps error name to code
	AliasModuleCode  map[string]string // Maps module name to alias code
	UpdatedImports   map[string]string // File path -> updated file content
}
