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

func main() {
    // Parse flags
    flag.Parse()
    
    // Get current working directory
    wd, err := os.Getwd()
    if err != nil {
        log.Fatal(err)
    }
    
    // Create configuration
    c := &config.Config{
        RepoRoot: wd,
    }
    
    // Create Swift language
    swiftLang := swift.NewLanguage()
    
    // Generate BUILD files
    if err := generateBuildFiles(wd, swiftLang, c); err != nil {
        log.Fatal(err)
    }
}

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
        
        // Create args for generating rules
        args := language.GenerateArgs{
            Config:       c,
            Dir:         path,
            Rel:         rel,
            RegularFiles: swiftFiles,
        }
        
        // Generate rules
        res := lang.GenerateRules(args)
        if len(res.Gen) == 0 {
            return nil
        }
        
        // Create BUILD file
        f := rule.EmptyFile("swift", "")
        for _, r := range res.Gen {
            r.Insert(f)
        }
        
        // Write BUILD file
        buildPath := filepath.Join(path, "BUILD.bazel")
        if err := os.WriteFile(buildPath, f.Format(), 0644); err != nil {
            return err
        }
        
        return nil
    })
}
