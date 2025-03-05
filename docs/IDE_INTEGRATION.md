# IDE Integration Guide for UmbraCore

This guide provides instructions for integrating UmbraCore's coding standards and tools with your preferred IDE.

## SwiftFormat Integration

UmbraCore uses [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) version 0.55.5 to maintain consistent code style. Here's how to integrate it with various IDEs:

### Xcode

1. **Using Xcode Source Editor Extension**:
   - Install the [SwiftFormat for Xcode](https://github.com/nicklockwood/SwiftFormat#xcode-source-editor-extension) extension
   - Configure it to use the project's `.swiftformat` file
   - Format code with: Editor > SwiftFormat > Format File (or use the keyboard shortcut)

2. **Using Xcode Build Phase**:
   - Add a new "Run Script" build phase to your target
   - Add the following script:
     ```bash
     if which swiftformat >/dev/null; then
       swiftformat "${SRCROOT}" --config "${SRCROOT}/.swiftformat"
     else
       echo "warning: SwiftFormat not installed, install with 'brew install swiftformat'"
     fi
     ```

### Visual Studio Code

1. Install the [Swift Format](https://marketplace.visualstudio.com/items?itemName=vknabel.vscode-swiftformat) extension for VS Code
2. Configure it to use the project's `.swiftformat` file in settings.json:
   ```json
   {
     "swiftformat.configSearchPaths": [".swiftformat"],
     "editor.formatOnSave": true,
     "[swift]": {
       "editor.defaultFormatter": "vknabel.vscode-swiftformat"
     }
   }
   ```

### JetBrains AppCode / CLion

1. Install the [Swift Format](https://plugins.jetbrains.com/plugin/12293-swiftformat) plugin
2. Go to Preferences > Tools > SwiftFormat
3. Configure it to use the project's `.swiftformat` file
4. Enable "Format on Save" if desired

### Command Line

You can also format code from the command line using our script:

```bash
# Format all files in the project
./scripts/format_code.sh

# Check formatting without making changes
./scripts/format_code.sh --check

# Format only staged files
./scripts/format_code.sh --staged-only

# Format specific files or directories
./scripts/format_code.sh path/to/file.swift path/to/directory
```

## Git Hooks

We provide a script to install Git hooks that enforce code style standards:

```bash
# Install Git hooks
./scripts/install-git-hooks.sh
```

This will install a pre-commit hook that checks the formatting of staged Swift files before committing.

## Continuous Integration

Our CI pipeline includes SwiftFormat checks to ensure all code adheres to the style guidelines. If your PR fails due to formatting issues, you can fix them by running:

```bash
./scripts/format_code.sh
```

## Troubleshooting

If you encounter issues with SwiftFormat:

1. Ensure you have the correct version installed: `swiftformat --version` should show 0.55.5
2. Update using: `brew upgrade swiftformat`
3. Check for conflicting configurations in your home directory (~/.swiftformat)
4. For IDE-specific issues, consult the documentation for your IDE's SwiftFormat plugin
