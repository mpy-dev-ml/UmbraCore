#!/bin/bash
#
# Script to fix 'SecurityError' aliases 'ErrorHandlingDomains.Protocols' warnings
# This script intelligently handles Swift namespace conflicts in the UmbraCore project.
#

# Set to true to just show what would be changed without making changes
DRY_RUN=false

# Log file to record all changes
LOG_FILE="/Users/mpy/CascadeProjects/UmbraCore/security_error_fixes.log"

# Directory to scan
ROOT_DIR="/Users/mpy/CascadeProjects/UmbraCore"

# Main module with the SecurityError definition
SECURITY_ERROR_MODULE="ErrorHandlingDomains"

# Clear log file
true > "$LOG_FILE"

# Log function
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "Starting security namespace fix script $(date)"
log "----------------------------------------"

# Function to fix security error imports in a file
fix_security_error_imports() {
    local file="$1"
    log "Examining $file..."
    
    # Check if file uses SecurityError but doesn't import ErrorHandlingDomains
    if grep -l -q "\bSecurityError\b" "$file" && ! grep -q "import $SECURITY_ERROR_MODULE" "$file"; then
        log "  - Found SecurityError usage without proper import"
        
        # Check for potential conflict patterns (using both SecurityProtocolsCore and another module with SecurityError)
        has_spc=$(grep -c "import SecurityProtocolsCore" "$file")
        has_xpc=$(grep -c "import XPCProtocolsCore" "$file")
        
        if [ "$has_spc" -gt 0 ] || [ "$has_xpc" -gt 0 ]; then
            log "  - Potential namespace conflict detected ($has_spc SecurityProtocolsCore, $has_xpc XPCProtocolsCore)"
        fi
        
        # Add import after existing imports
        if [ "$DRY_RUN" = true ]; then
            log "  - Would add 'import $SECURITY_ERROR_MODULE' after existing imports"
        else
            # Add import after the last import statement
            if grep -q "^import " "$file"; then
                # Get the line number of the last import statement
                last_import=$(grep -n "^import " "$file" | tail -1 | cut -d: -f1)
                sed -i '' "${last_import}a\\
import $SECURITY_ERROR_MODULE
" "$file"
                log "  - Added 'import $SECURITY_ERROR_MODULE' after line $last_import"
            else
                # Add after any file comments or pragmas
                line_num=$(grep -n -v "^//" "$file" | grep -v "^$" | head -1 | cut -d: -f1)
                if [ -z "$line_num" ]; then
                    echo "import $SECURITY_ERROR_MODULE" >> "$file"
                    log "  - Added 'import $SECURITY_ERROR_MODULE' at end of file"
                else
                    sed -i '' "${line_num}i\\
import $SECURITY_ERROR_MODULE
" "$file"
                    log "  - Added 'import $SECURITY_ERROR_MODULE' at line $line_num"
                fi
            fi
        fi
    fi
}

# Function to check for usage of ambiguous SecurityError
check_ambiguous_security_error_usage() {
    local file="$1"
    
    # Check if file imports both modules that could have SecurityError
    if grep -q "import SecurityProtocolsCore" "$file" && grep -q "import $SECURITY_ERROR_MODULE" "$file"; then
        log "  - File imports both SecurityProtocolsCore and $SECURITY_ERROR_MODULE"
        
        # Count unqualified SecurityError references
        unqualified=$(grep -c "\bSecurityError\b" "$file")
        qualified_spc=$(grep -c "SecurityProtocolsCore\.SecurityError" "$file")
        qualified_dom=$(grep -c "$SECURITY_ERROR_MODULE\.SecurityError" "$file")
        
        log "  - Found $unqualified unqualified, $qualified_spc SPC-qualified, and $qualified_dom domain-qualified references"
        
        if [ $unqualified -gt 0 ] && [ "$DRY_RUN" = false ]; then
            log "  - Would need to qualify ambiguous SecurityError references"
            # This would require more complex parsing, potentially needing a more sophisticated tool
        fi
    fi
}

# Find files with SecurityError usage and fix them
log "Scanning for files using SecurityError without proper imports..."
find "$ROOT_DIR" -name "*.swift" -type f -not -path "*/\.*" | while read -r file; do
    fix_security_error_imports "$file"
    check_ambiguous_security_error_usage "$file"
done

# Look for files specifically mentioned in warning output
log "Checking for files with known SecurityError warnings..."
grep -l "SecurityError.*aliases.*ErrorHandlingDomains\.Protocols" "$ROOT_DIR"/build_*.json | while read -r json_file; do
    # Extract file paths from build JSON (simplified approach)
    files=$(grep -o "/Users/mpy/CascadeProjects/UmbraCore/Sources/.*\.swift" "$json_file" | sort | uniq)
    for file in $files; do
        if [ -f "$file" ]; then
            log "Checking warning-specific file: $file"
            fix_security_error_imports "$file"
        fi
    done
done

log "----------------------------------------"
log "Script completed. Check $LOG_FILE for a full report of changes made."
log "Run 'bazelisk build //...' to verify issue resolution."
