package swift

import (
    "bufio"
    "bytes"
    "flag"
    "fmt"
    "os"
    "path/filepath"
    "sort"
    "strings"
    "unicode"

    "github.com/bazelbuild/bazel-gazelle/config"
    "github.com/bazelbuild/bazel-gazelle/label"
    "github.com/bazelbuild/bazel-gazelle/language"
    "github.com/bazelbuild/bazel-gazelle/resolve"
    "github.com/bazelbuild/bazel-gazelle/repo"
    "github.com/bazelbuild/bazel-gazelle/rule"
)

const (
    swiftName = "swift"
    languageName = "swift"
)

func NewLanguage() language.Language {
    return &swiftLang{}
}

type swiftLang struct{}

type swiftConfig struct {
    defaultCopts []string
}

func (*swiftLang) Name() string { return swiftName }

func (*swiftLang) RegisterFlags(fs *flag.FlagSet, cmd string, c *config.Config) {
    // No flags needed for now
}

func (*swiftLang) Register(c *config.Config) {
    if c.Exts == nil {
        c.Exts = make(map[string]interface{})
    }
    
    sc := &swiftConfig{
        defaultCopts: []string{
            "-target",
            "arm64-apple-macos14.0",
            "-strict-concurrency=complete",
            "-warn-concurrency",
            "-enable-actor-data-race-checks",
        },
    }
    
    c.Exts[swiftName] = sc
}

func (*swiftLang) CheckFlags(fs *flag.FlagSet, c *config.Config) error {
    return nil
}

func (*swiftLang) KnownDirectives() []string {
    return []string{
        "swift_default_module_name",
        "swift_default_visibility",
        "swift_default_copts",
    }
}

func (*swiftLang) Kinds() map[string]rule.KindInfo {
    return map[string]rule.KindInfo{
        "swift_library": {
            MatchAny: true,
            NonEmptyAttrs: map[string]bool{"srcs": true},
            MergeableAttrs: map[string]bool{
                "srcs": true,
                "deps": true,
                "copts": true,
            },
            ResolveAttrs: map[string]bool{"deps": true},
        },
        "swift_test": {
            MatchAny: true,
            NonEmptyAttrs: map[string]bool{"srcs": true},
            MergeableAttrs: map[string]bool{
                "srcs": true,
                "deps": true,
                "copts": true,
            },
            ResolveAttrs: map[string]bool{"deps": true},
        },
    }
}

func (*swiftLang) Loads() []rule.LoadInfo {
    return []rule.LoadInfo{
        {
            Name: "@build_bazel_rules_swift//swift:swift.bzl",
            Symbols: []string{
                "swift_library",
                "swift_test",
            },
        },
    }
}

func (*swiftLang) Configure(c *config.Config, rel string, f *rule.File) {
    // No configuration needed for now
}

func generateUniqueTargetName(rel, dir, repoRoot string) string {
    // Convert path components to valid target name
    parts := strings.Split(strings.TrimPrefix(dir, repoRoot), string(os.PathSeparator))
    var nameParts []string
    for _, part := range parts {
        if part != "" {
            nameParts = append(nameParts, strings.Map(func(r rune) rune {
                if unicode.IsLetter(r) || unicode.IsDigit(r) {
                    return r
                }
                return '_'
            }, part))
        }
    }
    return strings.Join(nameParts, "_")
}

func generateModuleName(dir string) string {
    // Extract module name from directory path
    parts := strings.Split(dir, string(os.PathSeparator))
    var moduleParts []string
    
    // Find the "Sources" or "Tests" directory
    sourcesIdx := -1
    for i, part := range parts {
        if part == "Sources" || part == "Tests" {
            sourcesIdx = i
            break
        }
    }
    
    if sourcesIdx >= 0 && sourcesIdx < len(parts)-1 {
        // Get all parts after Sources/Tests
        moduleParts = parts[sourcesIdx+1:]
        
        // Convert each part to CamelCase and join
        for i, part := range moduleParts {
            if part != "" && part != "." {
                // Split by any non-alphanumeric character
                words := strings.FieldsFunc(part, func(r rune) bool {
                    return !unicode.IsLetter(r) && !unicode.IsNumber(r)
                })
                
                // Capitalize each word
                for j, word := range words {
                    if len(word) > 0 {
                        words[j] = strings.ToUpper(word[:1]) + strings.ToLower(word[1:])
                    }
                }
                
                moduleParts[i] = strings.Join(words, "")
            }
        }
        
        // Join all parts
        return strings.Join(moduleParts, "")
    }
    
    return "UnknownModule"
}

func parseSwiftFileForImports(content []byte) ([]resolve.ImportSpec, error) {
    var imports []resolve.ImportSpec
    scanner := bufio.NewScanner(bytes.NewReader(content))
    for scanner.Scan() {
        line := strings.TrimSpace(scanner.Text())
        if strings.HasPrefix(line, "import ") {
            parts := strings.Fields(line)
            if len(parts) >= 2 {
                moduleName := strings.TrimSpace(parts[1])
                // Skip system modules
                if moduleName != "Foundation" && !strings.HasPrefix(moduleName, "Darwin") {
                    imports = append(imports, resolve.ImportSpec{
                        Lang: "swift",
                        Imp:  moduleName,
                    })
                }
            }
        }
    }
    return imports, scanner.Err()
}

func parseSwiftFilesForImports(args language.GenerateArgs) ([]resolve.ImportSpec, map[string]bool) {
    var imports []resolve.ImportSpec
    depSet := make(map[string]bool)
    
    for _, src := range args.RegularFiles {
        if strings.HasSuffix(src, ".swift") {
            content, err := os.ReadFile(filepath.Join(args.Dir, src))
            if err != nil {
                continue
            }
            
            parsedImports, err := parseSwiftFileForImports(content)
            if err != nil {
                continue
            }
            
            for _, imp := range parsedImports {
                // Skip system modules
                if imp.Imp != "Foundation" && !strings.HasPrefix(imp.Imp, "Darwin") {
                    if targetName, ok := findTargetForModule(imp.Imp, args.Config.RepoRoot); ok {
                        depSet[targetName] = true
                    } else {
                        // Add to imports for resolution
                        imports = append(imports, imp)
                    }
                }
            }
        }
    }
    
    return imports, depSet
}

func (*swiftLang) GenerateRules(args language.GenerateArgs) language.GenerateResult {
    var result language.GenerateResult
    
    // Skip if no Swift files found
    hasSwiftFiles := false
    for _, f := range args.RegularFiles {
        if strings.HasSuffix(f, ".swift") {
            hasSwiftFiles = true
            break
        }
    }
    if !hasSwiftFiles {
        return result
    }
    
    // Get the module name based on directory structure
    var ruleName, moduleName string
    
    // For submodules, we need to include the parent module name
    if strings.Contains(args.Dir, "Sources/") {
        parts := strings.Split(args.Dir, "Sources/")
        if len(parts) > 1 {
            subParts := strings.Split(parts[1], "/")
            if len(subParts) > 1 {
                // This is a submodule
                parentModule := subParts[0]
                submoduleType := subParts[len(subParts)-1]
                
                // Generate names based on our conventions
                ruleName = parentModule + submoduleType
                moduleName = ruleName
            } else {
                // This is a top-level module
                ruleName = subParts[0]
                moduleName = ruleName
            }
        }
    } else if strings.Contains(args.Dir, "Tests/") {
        parts := strings.Split(args.Dir, "Tests/")
        if len(parts) > 1 {
            // This is a test module
            ruleName = "Tests_" + parts[1]
            moduleName = parts[1]
        }
    }
    
    if ruleName == "" {
        // Use the directory name as a fallback
        ruleName = filepath.Base(args.Dir)
        moduleName = ruleName
    }
    
    // Create rule with proper name
    r := rule.NewRule("swift_library", ruleName)
    
    // Add sources
    r.SetAttr("srcs", args.RegularFiles)
    
    // Set visibility
    r.SetAttr("visibility", []string{"//visibility:public"})
    
    // Set module name
    r.SetAttr("module_name", moduleName)
    
    // Set copts
    r.SetAttr("copts", []string{
        "-target",
        "arm64-apple-macos14.0",
        "-strict-concurrency=complete",
        "-enable-actor-data-race-checks",
        "-warn-concurrency",
    })
    
    // Parse imports and find dependencies
    imports, depSet := parseSwiftFilesForImports(args)
    
    // Add deps
    if len(depSet) > 0 {
        deps := make([]string, 0, len(depSet))
        for dep := range depSet {
            // For submodules, try to find the correct target
            if strings.HasSuffix(dep, "Types") || strings.HasSuffix(dep, "Protocols") || strings.HasSuffix(dep, "Services") || strings.HasSuffix(dep, "Commands") || strings.HasSuffix(dep, "Models") {
                // Extract parent module name
                var parentModule string
                if strings.HasSuffix(dep, "Types") {
                    parentModule = strings.TrimSuffix(dep, "Types")
                } else if strings.HasSuffix(dep, "Protocols") {
                    parentModule = strings.TrimSuffix(dep, "Protocols")
                } else if strings.HasSuffix(dep, "Services") {
                    parentModule = strings.TrimSuffix(dep, "Services")
                } else if strings.HasSuffix(dep, "Commands") {
                    parentModule = strings.TrimSuffix(dep, "Commands")
                } else if strings.HasSuffix(dep, "Models") {
                    parentModule = strings.TrimSuffix(dep, "Models")
                }
                
                // Check if the parent module exists
                if parentModule != "" {
                    // Try to find the submodule in the parent module directory
                    submoduleType := strings.TrimPrefix(dep, parentModule)
                    submodulePath := filepath.Join(args.Config.RepoRoot, "Sources", parentModule, submoduleType)
                    if _, err := os.Stat(submodulePath); err == nil {
                        deps = append(deps, fmt.Sprintf("//Sources/%s/%s:%s", parentModule, submoduleType, dep))
                        continue
                    }
                }
            }
            
            // Handle test dependencies
            if strings.HasPrefix(dep, "Tests_") {
                deps = append(deps, fmt.Sprintf("//Tests/%s:%s", strings.TrimPrefix(dep, "Tests_"), dep))
            } else {
                // For regular dependencies, try to find the target
                if target, ok := findTargetForModule(dep, args.Config.RepoRoot); ok {
                    deps = append(deps, target)
                }
            }
        }
        sort.Strings(deps)
        r.SetAttr("deps", deps)
    }
    
    result.Gen = append(result.Gen, r)
    
    // Convert imports to []interface{}
    importsInterface := make([]interface{}, len(imports))
    for i, imp := range imports {
        importsInterface[i] = imp
    }
    result.Imports = importsInterface
    
    return result
}

func setSrcsAttr(r *rule.Rule, files []string) {
    var srcs []string
    for _, f := range files {
        if strings.HasSuffix(f, ".swift") {
            srcs = append(srcs, f)
        }
    }
    r.SetAttr("srcs", srcs)
}

func setVisibilityAttr(r *rule.Rule, args language.GenerateArgs) {
    visibility := "//visibility:private"
    if v, ok := args.Config.Exts["swift_default_visibility"].(string); ok {
        visibility = v
    }
    r.SetAttr("visibility", []string{visibility})
}

func findTargetForModule(moduleName string, repoRoot string) (string, bool) {
    // Check if this is a submodule
    if strings.HasSuffix(moduleName, "Types") || strings.HasSuffix(moduleName, "Protocols") || strings.HasSuffix(moduleName, "Services") || strings.HasSuffix(moduleName, "Commands") || strings.HasSuffix(moduleName, "Models") {
        // Extract parent module name
        var parentModule string
        if strings.HasSuffix(moduleName, "Types") {
            parentModule = strings.TrimSuffix(moduleName, "Types")
        } else if strings.HasSuffix(moduleName, "Protocols") {
            parentModule = strings.TrimSuffix(moduleName, "Protocols")
        } else if strings.HasSuffix(moduleName, "Services") {
            parentModule = strings.TrimSuffix(moduleName, "Services")
        } else if strings.HasSuffix(moduleName, "Commands") {
            parentModule = strings.TrimSuffix(moduleName, "Commands")
        } else if strings.HasSuffix(moduleName, "Models") {
            parentModule = strings.TrimSuffix(moduleName, "Models")
        }
        
        // Check if the parent module exists
        if parentModule != "" {
            // Try to find the submodule in the parent module directory
            submoduleType := strings.TrimPrefix(moduleName, parentModule)
            submodulePath := filepath.Join(repoRoot, "Sources", parentModule, submoduleType)
            if _, err := os.Stat(submodulePath); err == nil {
                return fmt.Sprintf("//Sources/%s/%s:%s", parentModule, submoduleType, moduleName), true
            }
        }
    }
    
    // Try finding the module directly in Sources
    sourcePath := filepath.Join(repoRoot, "Sources", moduleName)
    if _, err := os.Stat(sourcePath); err == nil {
        return fmt.Sprintf("//Sources/%s:%s", moduleName, moduleName), true
    }
    
    // Try finding the module in Tests
    testPath := filepath.Join(repoRoot, "Tests", moduleName)
    if _, err := os.Stat(testPath); err == nil {
        return fmt.Sprintf("//Tests/%s:%s", moduleName, moduleName), true
    }
    
    return "", false
}

func ensureTargetTriple(r *rule.Rule, sc *swiftConfig) {
    copts := r.AttrStrings("copts")
    hasTargetTriple := false
    for _, copt := range copts {
        if copt == "-target" {
            hasTargetTriple = true
            break
        }
    }
    if !hasTargetTriple {
        copts = append(sc.defaultCopts, copts...)
        r.SetAttr("copts", copts)
    }
}

func (*swiftLang) Fix(c *config.Config, f *rule.File) {
    sc := c.Exts[swiftName].(*swiftConfig)
    
    for _, r := range f.Rules {
        if r.Kind() != "swift_library" && r.Kind() != "swift_test" {
            continue
        }
        
        ensureTargetTriple(r, sc)
    }
}

func (*swiftLang) Imports(c *config.Config, r *rule.Rule, f *rule.File) []resolve.ImportSpec {
    return nil
}

func (*swiftLang) Resolve(c *config.Config, ix *resolve.RuleIndex, rc *repo.RemoteCache, r *rule.Rule, imports interface{}, from label.Label) {
    if r.Kind() != "swift_library" {
        return
    }
    
    var deps []string
    
    // Get existing deps if any
    if existingDeps := r.AttrStrings("deps"); len(existingDeps) > 0 {
        deps = append(deps, existingDeps...)
    }
    
    // Process imports
    for _, imp := range imports.([]resolve.ImportSpec) {
        // Handle external dependencies
        switch imp.Imp {
        case "SwiftyBeaver":
            deps = append(deps, "@swiftpkg_swiftybeaver//:SwiftyBeaver")
        case "CryptoSwift":
            deps = append(deps, "@swiftpkg_cryptoswift//:CryptoSwift")
        default:
            // Try to find target using our module mapping first
            if target, ok := findTargetForModule(imp.Imp, c.RepoRoot); ok {
                deps = append(deps, target)
                continue
            }
            
            // Handle internal dependencies
            matches := ix.FindRulesByImport(imp, "swift")
            for _, m := range matches {
                if m.Label.Pkg == from.Pkg {
                    continue // Skip self-imports
                }
                deps = append(deps, "//"+m.Label.Pkg+":"+m.Label.Name)
            }
        }
    }
    
    // Remove duplicates
    seen := make(map[string]bool)
    var uniqueDeps []string
    for _, dep := range deps {
        if !seen[dep] {
            seen[dep] = true
            uniqueDeps = append(uniqueDeps, dep)
        }
    }
    
    if len(uniqueDeps) > 0 {
        r.SetAttr("deps", uniqueDeps)
    }
}

func (*swiftLang) Embeds(r *rule.Rule, from label.Label) []label.Label {
    return nil
}

func setModuleName(r *rule.Rule, dir string) {
    moduleName := generateModuleName(dir)
    r.SetAttr("module_name", moduleName)
}
