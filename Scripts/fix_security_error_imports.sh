#!/bin/bash
#
# Script to fix 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' warnings
# This script finds Swift files that use SecurityError but don't import ErrorHandlingDomains
# and adds the necessary import statement.
#

# Set to true to just show what would be changed without making changes
DRY_RUN=false

# Directory to scan
ROOT_DIR="/Users/mpy/CascadeProjects/UmbraCore"

# Function to process a file
process_file() {
    local file="$1"
    echo "Examining $file..."
    
    # Check if file uses SecurityError but doesn't import ErrorHandlingDomains
    if grep -q "SecurityError" "$file" && ! grep -q "import ErrorHandlingDomains" "$file"; then
        echo "  - Found issue in $file"
        
        # Check if there's already another import statement to add after
        if grep -q "^import " "$file"; then
            if [ "$DRY_RUN" = true ]; then
                echo "  - Would add 'import ErrorHandlingDomains' after existing imports"
            else
                # Add import after the last import statement
                sed -i '' '/^import .*/!b;:a;n;/^import .*/ba;i\\
import ErrorHandlingDomains
' "$file"
                echo "  - Added 'import ErrorHandlingDomains' after existing imports"
            fi
        else
            # Add import at the top of the file (after any comments or header)
            if [ "$DRY_RUN" = true ]; then
                echo "  - Would add 'import ErrorHandlingDomains' at the top of the file"
            else
                # Find first non-comment, non-empty line
                line_num=$(grep -n "^[^/]" "$file" | head -1 | cut -d: -f1)
                if [ -z "$line_num" ]; then
                    # If no non-comment line found, add at the end
                    echo "import ErrorHandlingDomains" >> "$file"
                else
                    # Add before the first non-comment line
                    sed -i '' "${line_num}i\\
import ErrorHandlingDomains
" "$file"
                fi
                echo "  - Added 'import ErrorHandlingDomains' at line $line_num"
            fi
        fi
    fi
}

# Find all Swift files and process them
find "$ROOT_DIR" -name "*.swift" -type f | while read -r file; do
    process_file "$file"
done

echo "Script completed."
echo "Note: You may need to run 'bazelisk build //...' again to verify all issues are resolved."
