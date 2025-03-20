# Deprecation Remover

This tool identifies and removes deprecated items from the UmbraCore codebase. It can identify deprecated items from two sources:

1. The `deprecated_inventory.md` file that lists all deprecated items
2. Deprecated typealiases marked with `@available(*, deprecated, message: "...")` annotations

## Features

- Identifies deprecated items from inventory markdown file
- Finds references to deprecated items in Swift code
- Can comment out or replace deprecated declarations
- Generates detailed reports of deprecated items and their references
- Supports dry-run mode for safe testing before making actual changes

## Usage

```
./deprecation_remover [options]
```

### Options

- `-inventory`: Path to the deprecated_inventory.md file (default: "deprecated_inventory.md")
- `-dry-run`: Perform a dry run without making any changes (default: false)
- `-verbose`: Enable verbose logging (default: false)
- `-report`: Generate a detailed report of deprecated items (default: false)
- `-module`: Process only a specific module (default: all modules)

### Examples

Run in dry-run mode with verbose logging:
```
./deprecation_remover -inventory=/path/to/deprecated_inventory.md -dry-run -verbose
```

Generate a report without making changes:
```
./deprecation_remover -inventory=/path/to/deprecated_inventory.md -dry-run -report
```

Process only a specific module:
```
./deprecation_remover -inventory=/path/to/deprecated_inventory.md -module=SecurityBridge
```

Remove all deprecated items and update references:
```
./deprecation_remover -inventory=/path/to/deprecated_inventory.md
```

## Report Format

The tool generates a markdown report that includes:

- Summary of deprecated items and references found
- Deprecated items grouped by module and type
- List of all references to deprecated items
- Information about available replacements

## How It Works

1. The tool parses the `deprecated_inventory.md` file to extract information about deprecated items
2. It scans Swift files in the specified modules to find references to these items
3. It comments out or modifies the declaration lines for deprecated items
4. For references to deprecated items, it replaces them with the recommended replacement if available

For items from the inventory file without specific line numbers, the tool uses regular expressions to locate the appropriate declarations in the code.
