package main

import (
    "flag"
    "log"
    "os"
    "path/filepath"
    "strings"

    "github.com/bazelbuild/bazel-gazelle/config"
    "github.com/bazelbuild/bazel-gazelle/language"
    "github.com/bazelbuild/bazel-gazelle/rule"
    "github.com/mpy-dev-ml/UmbraCore/tools/gazelle/swift"
)

func generateBuildFiles(dir string, lang language.Language, c *config.Config) error {
    // Walk through all directories
    return filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
        if err != nil {
            return err
        }
        
        // Skip non-directories and hidden directories
        if !info.IsDir() || strings.HasPrefix(info.Name(), ".") {
            return nil
        }
        
        // Get all files in the directory
        files, err := os.ReadDir(path)
        if err != nil {
            return err
        }
        
        // Check if directory contains Swift files
        hasSwift := false
        var swiftFiles []string
        for _, file := range files {
            if !file.IsDir() && strings.HasSuffix(file.Name(), ".swift") {
                hasSwift = true
                swiftFiles = append(swiftFiles, file.Name())
            }
        }
        
        if !hasSwift {
            return nil
        }
        
        // Get relative path from root
        rel, err := filepath.Rel(c.RepoRoot, path)
        if err != nil {
            return err
        }
        
        // Generate rules
        args := language.GenerateArgs{
            Config:       c,
            Dir:         path,
            Rel:         rel,
            File:        rule.EmptyFile("BUILD.bazel", ""),
            RegularFiles: swiftFiles,
        }
        
        result := lang.GenerateRules(args)
        if len(result.Gen) > 0 {
            // Create BUILD file
            f := rule.EmptyFile("BUILD.bazel", "")
            f.AddLoad("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
            
            // Add rules
            for _, r := range result.Gen {
                f.AddRule(r)
            }
            
            // Write BUILD file
            buildPath := filepath.Join(path, "BUILD.bazel")
            if err := f.Save(buildPath); err != nil {
                log.Printf("Error writing BUILD.bazel in %s: %v", path, err)
            } else {
                log.Printf("Generated BUILD.bazel in %s", path)
            }
        }
        
        return nil
    })
}

func main() {
    // Initialize language
    lang := swift.NewLanguage()
    
    // Create configuration
    c := config.New()
    c.RepoRoot = "."
    c.ValidBuildFileNames = []string{"BUILD.bazel"}
    
    // Parse flags
    fs := flag.NewFlagSet("gazelle", flag.ExitOnError)
    lang.RegisterFlags(fs, "", c)
    if err := fs.Parse(os.Args[1:]); err != nil {
        log.Fatal(err)
    }
    
    // Configure language
    lang.Configure(c, "", &rule.File{})
    
    // Generate BUILD files
    if err := generateBuildFiles(".", lang, c); err != nil {
        log.Fatal(err)
    }
}
