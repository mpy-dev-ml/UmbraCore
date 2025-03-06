#!/usr/bin/env swift

import Foundation

// MARK: - Configuration

struct Config {
    let rootPath: String
    let sourcesDir: String
    let outputDir: String
    
    static func fromArguments() -> Config {
        let args = CommandLine.arguments
        var rootPath = FileManager.default.currentDirectoryPath
        var outputDir = "refactoring_plan"
        
        for i in 1..<args.count {
            if args[i] == "--root" && i+1 < args.count {
                rootPath = args[i+1]
            } else if args[i] == "--output" && i+1 < args.count {
                outputDir = args[i+1]
            }
        }
        
        return Config(
            rootPath: rootPath,
            sourcesDir: "\(rootPath)/Sources",
            outputDir: "\(rootPath)/\(outputDir)"
        )
    }
}

// MARK: - Models

struct SwiftModule {
    let name: String
    let path: String
    var files: [SwiftFile] = []
    var dependencies: Set<String> = []
    var isolationFiles: [SwiftFile] = []
    var typeAliases: [TypeAlias] = []
    var risks: [String] = []
    var refactoringComplexity: Int = 0
}

struct SwiftFile {
    let filePath: String
    let fileName: String
    let moduleName: String
    var imports: [String] = []
    var typeAliases: [TypeAlias] = []
    var isIsolationFile: Bool = false
    var content: String = ""
    
    init(filePath: String, moduleName: String) {
        self.filePath = filePath
        self.fileName = URL(fileURLWithPath: filePath).lastPathComponent
        self.moduleName = moduleName
    }
}

struct TypeAlias {
    let name: String
    let targetType: String
    let filePath: String
    let lineNumber: Int
    var usageCount: Int = 0
    var usageLocations: [String] = []
}

struct RefactoringPlan {
    let moduleName: String
    let currentStructure: SwiftModule
    var isolationFilesCount: Int = 0
    var typeAliasCount: Int = 0
    var refactoringSteps: [RefactoringStep] = []
    var complexity: Int = 0
    var risks: [String] = []
}

struct RefactoringStep {
    let description: String
    let fileChanges: [FileChange]
    let complexity: Int // 1-10 scale
}

struct FileChange {
    let filePath: String
    let changeType: ChangeType
    let lineNumber: Int?
    let oldCode: String?
    let newCode: String?
}

enum ChangeType {
    case create
    case modify
    case delete
    case rename
    case move
}

// MARK: - Main Analysis Functions

func analyzeModules(config: Config) -> [SwiftModule] {
    print("Analyzing Swift modules in \(config.sourcesDir)...")
    
    var modules: [SwiftModule] = []
    let fileManager = FileManager.default
    
    guard let moduleDirectories = try? fileManager.contentsOfDirectory(atPath: config.sourcesDir) else {
        print("Error: Could not access source directory at \(config.sourcesDir)")
        return []
    }
    
    for moduleDir in moduleDirectories {
        let modulePath = "\(config.sourcesDir)/\(moduleDir)"
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: modulePath, isDirectory: &isDirectory) && isDirectory.boolValue {
            let module = analyzeModule(name: moduleDir, path: modulePath)
            modules.append(module)
        }
    }
    
    return modules
}

func analyzeModule(name: String, path: String) -> SwiftModule {
    print("Analyzing module: \(name)")
    var module = SwiftModule(name: name, path: path)
    
    let fileManager = FileManager.default
    guard let enumerator = fileManager.enumerator(atPath: path) else {
        print("Error: Could not enumerate files in \(path)")
        return module
    }
    
    while let filePath = enumerator.nextObject() as? String {
        if filePath.hasSuffix(".swift") {
            let fullPath = "\(path)/\(filePath)"
            var swiftFile = SwiftFile(filePath: fullPath, moduleName: name)
            
            do {
                let content = try String(contentsOfFile: fullPath, encoding: .utf8)
                swiftFile.content = content
                
                // Detect isolation files
                if filePath.contains("Isolation") || content.contains("isolation pattern") {
                    swiftFile.isIsolationFile = true
                    module.isolationFiles.append(swiftFile)
                }
                
                // Analyze imports
                let importPattern = #"import\s+([A-Za-z0-9_]+)"#
                let importRegex = try NSRegularExpression(pattern: importPattern)
                let importMatches = importRegex.matches(in: content, range: NSRange(content.startIndex..., in: content))
                
                for match in importMatches {
                    if let range = Range(match.range(at: 1), in: content) {
                        let importName = String(content[range])
                        swiftFile.imports.append(importName)
                        module.dependencies.insert(importName)
                    }
                }
                
                // Analyze type aliases
                let typeAliasPattern = #"public\s+typealias\s+([A-Za-z0-9_]+)\s*=\s*([A-Za-z0-9_\.]+)"#
                let typeAliasRegex = try NSRegularExpression(pattern: typeAliasPattern)
                let typeAliasMatches = typeAliasRegex.matches(in: content, range: NSRange(content.startIndex..., in: content))
                
                for match in typeAliasMatches {
                    if let nameRange = Range(match.range(at: 1), in: content),
                       let typeRange = Range(match.range(at: 2), in: content) {
                        let name = String(content[nameRange])
                        let targetType = String(content[typeRange])
                        
                        // Calculate line number (approximate)
                        let beforeMatch = content.prefix(match.range.location)
                        let lineNumber = beforeMatch.components(separatedBy: .newlines).count
                        
                        let typeAlias = TypeAlias(
                            name: name,
                            targetType: targetType,
                            filePath: fullPath,
                            lineNumber: lineNumber
                        )
                        
                        swiftFile.typeAliases.append(typeAlias)
                        module.typeAliases.append(typeAlias)
                    }
                }
                
                module.files.append(swiftFile)
                
            } catch {
                print("Error reading file \(fullPath): \(error)")
            }
        }
    }
    
    // Calculate refactoring complexity based on findings
    module.refactoringComplexity = calculateRefactoringComplexity(module: module)
    
    // Identify risks
    module.risks = identifyRefactoringRisks(module: module)
    
    return module
}

func calculateRefactoringComplexity(module: SwiftModule) -> Int {
    var complexity = 0
    
    // Isolation files contribute significantly to complexity
    complexity += module.isolationFiles.count * 3
    
    // Type aliases add complexity
    complexity += module.typeAliases.count
    
    // Dependencies add complexity
    complexity += module.dependencies.count
    
    // Scale to 1-10
    complexity = min(10, max(1, complexity))
    
    return complexity
}

func identifyRefactoringRisks(module: SwiftModule) -> [String] {
    var risks: [String] = []
    
    if module.isolationFiles.count > 0 {
        risks.append("Uses isolation pattern that will need careful refactoring")
    }
    
    if module.typeAliases.count > 3 {
        risks.append("Multiple type aliases increase risk of naming conflicts during refactoring")
    }
    
    if module.dependencies.count > 5 {
        risks.append("High number of dependencies increases chance of circular dependencies")
    }
    
    return risks
}

// MARK: - Type Usage Analysis

func findTypeUsage(modules: [SwiftModule], typeAliases: [TypeAlias]) -> [TypeAlias] {
    var updatedAliases = typeAliases
    
    for (aliasIndex, alias) in typeAliases.enumerated() {
        for module in modules {
            for file in module.files {
                let regex = try? NSRegularExpression(pattern: "\\b\(alias.name)\\b")
                if let matches = regex?.matches(in: file.content, range: NSRange(file.content.startIndex..., in: file.content)) {
                    updatedAliases[aliasIndex].usageCount += matches.count
                    if matches.count > 0 && !updatedAliases[aliasIndex].usageLocations.contains(file.filePath) {
                        updatedAliases[aliasIndex].usageLocations.append(file.filePath)
                    }
                }
            }
        }
    }
    
    return updatedAliases
}

// MARK: - Refactoring Plan Generation

func generateRefactoringPlans(modules: [SwiftModule]) -> [RefactoringPlan] {
    var plans: [RefactoringPlan] = []
    
    for module in modules {
        if module.isolationFiles.count > 0 || module.typeAliases.count > 0 {
            var plan = RefactoringPlan(
                moduleName: module.name,
                currentStructure: module,
                isolationFilesCount: module.isolationFiles.count,
                typeAliasCount: module.typeAliases.count,
                complexity: module.refactoringComplexity,
                risks: module.risks
            )
            
            // Add refactoring steps
            if module.isolationFiles.count > 0 {
                let step = createRefactoringStepForIsolationPattern(module: module)
                plan.refactoringSteps.append(step)
            }
            
            plans.append(plan)
        }
    }
    
    // Sort by complexity (highest first)
    return plans.sorted { $0.complexity > $1.complexity }
}

func createRefactoringStepForIsolationPattern(module: SwiftModule) -> RefactoringStep {
    var fileChanges: [FileChange] = []
    
    // For each isolation file, we'll need to create an adapter module
    for isolationFile in module.isolationFiles {
        let isolationName = URL(fileURLWithPath: isolationFile.filePath).deletingPathExtension().lastPathComponent
        let adapterModuleName = isolationName.replacingOccurrences(of: "Isolation", with: "Adapter")
        
        // Add file change for creating adapter module
        fileChanges.append(FileChange(
            filePath: "\(module.path)/../\(adapterModuleName)/\(adapterModuleName).swift",
            changeType: .create,
            lineNumber: nil,
            oldCode: nil,
            newCode: "// TODO: Create adapter module content"
        ))
        
        // Add file change for BUILD.bazel
        fileChanges.append(FileChange(
            filePath: "\(module.path)/../\(adapterModuleName)/BUILD.bazel",
            changeType: .create,
            lineNumber: nil,
            oldCode: nil,
            newCode: "// TODO: Create BUILD.bazel content"
        ))
        
        // Add file change for removing isolation file
        fileChanges.append(FileChange(
            filePath: isolationFile.filePath,
            changeType: .delete,
            lineNumber: nil,
            oldCode: nil,
            newCode: nil
        ))
    }
    
    return RefactoringStep(
        description: "Replace isolation files with proper adapter modules",
        fileChanges: fileChanges,
        complexity: 7
    )
}

// MARK: - Report Generation

func generateAnalysisReport(modules: [SwiftModule], config: Config) {
    print("Generating analysis report...")
    
    // Create output directory if it doesn't exist
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: config.outputDir) {
        try? fileManager.createDirectory(atPath: config.outputDir, withIntermediateDirectories: true)
    }
    
    // Summary report
    var summaryReport = "# Swift Module Analysis Report\n\n"
    summaryReport += "Generated on: \(Date())\n\n"
    summaryReport += "## Summary\n\n"
    summaryReport += "Total modules analyzed: \(modules.count)\n"
    
    let modulesWithIsolation = modules.filter { $0.isolationFiles.count > 0 }
    summaryReport += "Modules using isolation pattern: \(modulesWithIsolation.count)\n"
    
    let totalTypeAliases = modules.reduce(0) { $0 + $1.typeAliases.count }
    summaryReport += "Total type aliases found: \(totalTypeAliases)\n\n"
    
    summaryReport += "## Modules Prioritized for Refactoring\n\n"
    
    // Sort modules by refactoring complexity
    let sortedModules = modules.sorted { $0.refactoringComplexity > $1.refactoringComplexity }
    
    for module in sortedModules.prefix(10) {
        summaryReport += "### \(module.name)\n\n"
        summaryReport += "Complexity Score: \(module.refactoringComplexity)/10\n\n"
        
        if !module.risks.isEmpty {
            summaryReport += "**Risks:**\n"
            for risk in module.risks {
                summaryReport += "- \(risk)\n"
            }
            summaryReport += "\n"
        }
        
        if !module.isolationFiles.isEmpty {
            summaryReport += "**Isolation Files:**\n"
            for file in module.isolationFiles {
                summaryReport += "- \(file.fileName)\n"
            }
            summaryReport += "\n"
        }
        
        if !module.typeAliases.isEmpty {
            summaryReport += "**Type Aliases:**\n"
            for alias in module.typeAliases {
                summaryReport += "- `\(alias.name)` = `\(alias.targetType)`\n"
            }
            summaryReport += "\n"
        }
        
        summaryReport += "**Dependencies:**\n"
        for dependency in module.dependencies.sorted() {
            summaryReport += "- \(dependency)\n"
        }
        summaryReport += "\n"
    }
    
    try? summaryReport.write(toFile: "\(config.outputDir)/module_analysis.md", atomically: true, encoding: .utf8)
    print("Summary report written to \(config.outputDir)/module_analysis.md")
    
    // Generate detailed refactoring plans
    let plans = generateRefactoringPlans(modules: modules)
    
    var planReport = "# Swift Module Refactoring Plan\n\n"
    planReport += "Generated on: \(Date())\n\n"
    planReport += "## Modules to Refactor\n\n"
    
    for (index, plan) in plans.enumerated() {
        planReport += "## \(index + 1). \(plan.moduleName)\n\n"
        planReport += "Complexity: \(plan.complexity)/10\n\n"
        
        if !plan.risks.isEmpty {
            planReport += "**Risks:**\n"
            for risk in plan.risks {
                planReport += "- \(risk)\n"
            }
            planReport += "\n"
        }
        
        planReport += "**Current Structure:**\n"
        planReport += "- Isolation Files: \(plan.isolationFilesCount)\n"
        planReport += "- Type Aliases: \(plan.typeAliasCount)\n\n"
        
        if !plan.refactoringSteps.isEmpty {
            planReport += "**Refactoring Steps:**\n\n"
            for (stepIndex, step) in plan.refactoringSteps.enumerated() {
                planReport += "### Step \(stepIndex + 1): \(step.description)\n\n"
                planReport += "Complexity: \(step.complexity)/10\n\n"
                
                if !step.fileChanges.isEmpty {
                    planReport += "File Changes:\n"
                    for change in step.fileChanges {
                        let changeType = {
                            switch change.changeType {
                            case .create: return "Create"
                            case .modify: return "Modify"
                            case .delete: return "Delete"
                            case .rename: return "Rename"
                            case .move: return "Move"
                            }
                        }()
                        
                        planReport += "- \(changeType): \(change.filePath)\n"
                    }
                    planReport += "\n"
                }
            }
        }
    }
    
    try? planReport.write(toFile: "\(config.outputDir)/refactoring_plan.md", atomically: true, encoding: .utf8)
    print("Refactoring plan written to \(config.outputDir)/refactoring_plan.md")
}

// MARK: - Execution

func main() {
    let config = Config.fromArguments()
    let modules = analyzeModules(config: config)
    
    // Perform type usage analysis
    let allTypeAliases = modules.flatMap { $0.typeAliases }
    let _ = findTypeUsage(modules: modules, typeAliases: allTypeAliases)
    
    // Generate analysis report and refactoring plan
    generateAnalysisReport(modules: modules, config: config)
}

main()
