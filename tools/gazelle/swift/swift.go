package swift

import (
    "bufio"
    "bytes"
    "flag"
    "fmt"
    "os"
    "path/filepath"
    "strings"
    "unicode"

    "github.com/bazelbuild/bazel-gazelle/config"
    "github.com/bazelbuild/bazel-gazelle/label"
    "github.com/bazelbuild/bazel-gazelle/language"
    "github.com/bazelbuild/bazel-gazelle/resolve"
    "github.com/bazelbuild/bazel-gazelle/repo"
    "github.com/bazelbuild/bazel-gazelle/rule"
)

const swiftName = "swift"

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
    for i := len(parts) - 1; i >= 0; i-- {
        if parts[i] != "" && parts[i] != "." {
            return parts[i]
        }
    }
    return "UnknownModule"
}

func setModuleName(r *rule.Rule, dir string) {
    moduleName := generateModuleName(dir)
    r.SetAttr("module_name", moduleName)
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
    
    // Create rule
    r := rule.NewRule("swift_library", generateUniqueTargetName(args.Rel, args.Dir, args.Config.RepoRoot))
    
    // Add sources
    setSrcsAttr(r, args.RegularFiles)
    
    // Set visibility
    setVisibilityAttr(r, args)
    
    // Set module name
    setModuleName(r, args.Dir)
    
    // Process imports and dependencies
    imports, depSet := parseSwiftFilesForImports(args)
    
    // Convert depSet to deps slice
    var deps []string
    for dep := range depSet {
        deps = append(deps, dep)
    }
    
    // Set dependencies if any found
    if len(deps) > 0 {
        r.SetAttr("deps", deps)
    }
    
    // Add the rule to the result
    result.Gen = append(result.Gen, r)
    var importsInterface []interface{}
    for _, imp := range imports {
        importsInterface = append(importsInterface, imp)
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
    // Common module name to target mappings
    moduleToTarget := map[string]string{
        "SecurityTypes": "//Sources/SecurityTypes:Sources_SecurityTypes",
        "SecurityUtils": "//Sources/SecurityUtils:Sources_SecurityUtils",
        "CryptoTypes":  "//Sources/CryptoTypes:Sources_CryptoTypes",
        "UmbraLogging": "//Sources/UmbraLogging:Sources_UmbraLogging",
        "UmbraCore":    "//Sources/UmbraCore:Sources_UmbraCore",
        "UmbraXPC":     "//Sources/XPC:Sources_XPC",
        "Models":       "//Sources/ErrorHandling/Models:Sources_ErrorHandling_Models",
        "Services":     "//Sources/Core/Services:Sources_Core_Services",
    }
    
    if target, ok := moduleToTarget[moduleName]; ok {
        return target, true
    }
    
    // Check if this is a Services module in a subdirectory
    if strings.HasSuffix(moduleName, "Service") || strings.HasSuffix(moduleName, "Services") {
        // Try to find the module in the Services directory
        servicesDir := filepath.Join(repoRoot, "Sources", "Services")
        if _, err := os.Stat(servicesDir); err == nil {
            // Look for a directory matching the module name
            matches, err := filepath.Glob(filepath.Join(servicesDir, "*", moduleName))
            if err == nil && len(matches) > 0 {
                // Found a match, create target
                rel, err := filepath.Rel(repoRoot, matches[0])
                if err == nil {
                    return fmt.Sprintf("//%s:Sources_%s", rel, moduleName), true
                }
            }
        }
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
