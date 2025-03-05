#!/bin/bash
# xpc_migration_manager.sh
#
# Master script to manage the XPC protocol migration process
# This script helps track progress and migrate files in a structured manner

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
JSON_REPORT="$PROJECT_ROOT/xpc_protocol_analysis.json"
PROGRESS_FILE="$PROJECT_ROOT/xpc_migration_progress.json"
MIGRATE_SCRIPT="$SCRIPT_DIR/migrate_xpc_file.sh"

# Ensure the analyzer has been run
if [ ! -f "$JSON_REPORT" ]; then
  echo "Error: Analysis report not found. Run run_xpc_analyzer.sh first."
  exit 1
fi

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "{\"migrated\": [], \"inProgress\": [], \"needsMigration\": [], \"lastUpdated\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" > "$PROGRESS_FILE"
  echo "Created new migration progress file."
fi

# Function to update progress file
update_progress() {
  local file="$1"
  local status="$2"
  
  # Read current progress
  local migrated=$(jq -r '.migrated' "$PROGRESS_FILE" | jq -c .)
  local in_progress=$(jq -r '.inProgress' "$PROGRESS_FILE" | jq -c .)
  local needs_migration=$(jq -r '.needsMigration' "$PROGRESS_FILE" | jq -c .)
  
  # Update based on status
  case "$status" in
    "migrated")
      # Remove from other lists and add to migrated
      in_progress=$(echo "$in_progress" | jq -c ". - [\"$file\"]")
      needs_migration=$(echo "$needs_migration" | jq -c ". - [\"$file\"]")
      migrated=$(echo "$migrated" | jq -c ". + [\"$file\"]")
      ;;
    "inProgress")
      # Remove from other lists and add to in progress
      migrated=$(echo "$migrated" | jq -c ". - [\"$file\"]")
      needs_migration=$(echo "$needs_migration" | jq -c ". - [\"$file\"]")
      in_progress=$(echo "$in_progress" | jq -c ". + [\"$file\"]")
      ;;
    "needsMigration")
      # Remove from other lists and add to needs migration
      migrated=$(echo "$migrated" | jq -c ". - [\"$file\"]")
      in_progress=$(echo "$in_progress" | jq -c ". - [\"$file\"]")
      needs_migration=$(echo "$needs_migration" | jq -c ". + [\"$file\"]")
      ;;
  esac
  
  # Update the progress file
  echo "{
    \"migrated\": $migrated,
    \"inProgress\": $in_progress,
    \"needsMigration\": $needs_migration,
    \"lastUpdated\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
  }" > "$PROGRESS_FILE"
}

# Function to initialize the needs migration list from the analysis report
initialize_needs_migration() {
  echo "Initializing migration status from analysis report..."
  
  # Get all files needing refactoring from the JSON report
  local files=$(jq -r '.fileAnalyses[] | select(.needsRefactoring == true) | .filePath' "$JSON_REPORT")
  
  # Add each file to the needs migration list
  while IFS= read -r file; do
    if [ ! -z "$file" ]; then
      update_progress "$file" "needsMigration"
    fi
  done <<< "$files"
  
  echo "Initialization complete."
}

# Function to display migration status
show_status() {
  echo -e "\n## XPC Migration Status ##"
  
  local migrated_count=$(jq '.migrated | length' "$PROGRESS_FILE")
  local in_progress_count=$(jq '.inProgress | length' "$PROGRESS_FILE")
  local needs_migration_count=$(jq '.needsMigration | length' "$PROGRESS_FILE")
  local total_count=$((migrated_count + in_progress_count + needs_migration_count))
  local percent_complete=$((migrated_count * 100 / total_count))
  
  echo "🟢 Migrated: $migrated_count / $total_count files ($percent_complete%)"
  echo "🟠 In Progress: $in_progress_count files"
  echo "🔴 Not Started: $needs_migration_count files"
  echo "Last updated: $(jq -r '.lastUpdated' "$PROGRESS_FILE")"
  
  # Show files by module
  echo -e "\n## Migration Status by Module ##"
  
  # Get modules from the JSON report
  local modules=$(jq -r '.modulesToRefactor[]' "$JSON_REPORT" | sort)
  
  echo "| Module | Migrated | In Progress | Not Started | Total |"
  echo "|--------|----------|-------------|-------------|-------|"
  
  while IFS= read -r module; do
    if [ ! -z "$module" ]; then
      # Get files for this module
      local module_files=$(jq -r ".fileAnalyses[] | select(.module == \"$module\" and .needsRefactoring == true) | .filePath" "$JSON_REPORT")
      
      local module_migrated=0
      local module_in_progress=0
      local module_needs_migration=0
      
      # Count status for each file
      while IFS= read -r file; do
        if [ ! -z "$file" ]; then
          if jq -r ".migrated[]" "$PROGRESS_FILE" | grep -q "^$file$"; then
            module_migrated=$((module_migrated + 1))
          elif jq -r ".inProgress[]" "$PROGRESS_FILE" | grep -q "^$file$"; then
            module_in_progress=$((module_in_progress + 1))
          else
            module_needs_migration=$((module_needs_migration + 1))
          fi
        fi
      done <<< "$module_files"
      
      local module_total=$((module_migrated + module_in_progress + module_needs_migration))
      
      echo "| $module | $module_migrated | $module_in_progress | $module_needs_migration | $module_total |"
    fi
  done <<< "$modules"
}

# Function to list files by status
list_files() {
  local status="$1"
  
  case "$status" in
    "migrated")
      echo -e "\n## Migrated Files ##"
      jq -r '.migrated[]' "$PROGRESS_FILE" | sort
      ;;
    "inProgress")
      echo -e "\n## Files In Progress ##"
      jq -r '.inProgress[]' "$PROGRESS_FILE" | sort
      ;;
    "needsMigration")
      echo -e "\n## Files Needing Migration ##"
      jq -r '.needsMigration[]' "$PROGRESS_FILE" | sort
      ;;
    *)
      echo "Invalid status: $status"
      exit 1
      ;;
  esac
}

# Function to start migration for a file
start_migration() {
  local file="$1"
  
  # Check if file exists and needs migration
  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    exit 1
  fi
  
  # Move file to in progress
  update_progress "$file" "inProgress"
  echo "Marked as in progress: $file"
  
  # Run the migration script
  echo "Starting migration..."
  "$MIGRATE_SCRIPT" "$file"
}

# Function to mark a file as migrated
mark_migrated() {
  local file="$1"
  
  # Check if file exists
  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    exit 1
  fi
  
  # Move file to migrated
  update_progress "$file" "migrated"
  echo "Marked as migrated: $file"
}

# Function to reset status for a file
reset_status() {
  local file="$1"
  
  # Check if file exists
  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    exit 1
  fi
  
  # Move file to needs migration
  update_progress "$file" "needsMigration"
  echo "Reset status for: $file"
}

# Function to suggest next file to migrate
suggest_next() {
  local module="$1"
  
  if [ -z "$module" ]; then
    # Get a file from a high priority module
    local priority_modules=("Core" "CryptoTypes" "UmbraSecurity" "SecurityInterfaces")
    
    for module in "${priority_modules[@]}"; do
      local file=$(jq -r ".fileAnalyses[] | select(.module == \"$module\" and .needsRefactoring == true) | .filePath" "$JSON_REPORT" | head -1)
      
      if [ ! -z "$file" ] && jq -r ".needsMigration[]" "$PROGRESS_FILE" | grep -q "^$file$"; then
        echo -e "\nRecommended next file to migrate (from high priority module $module):"
        echo "$file"
        return
      fi
    done
    
    # If no high priority files found, get any file
    local file=$(jq -r '.needsMigration[0]' "$PROGRESS_FILE")
    
    if [ ! -z "$file" ] && [ "$file" != "null" ]; then
      echo -e "\nRecommended next file to migrate:"
      echo "$file"
    else
      echo -e "\nNo files left to migrate!"
    fi
  else
    # Get a file from the specified module
    local file=$(jq -r ".fileAnalyses[] | select(.module == \"$module\" and .needsRefactoring == true) | .filePath" "$JSON_REPORT" | head -1)
    
    if [ ! -z "$file" ] && jq -r ".needsMigration[]" "$PROGRESS_FILE" | grep -q "^$file$"; then
      echo -e "\nRecommended next file to migrate from module $module:"
      echo "$file"
    else
      echo -e "\nNo files left to migrate in module $module!"
    fi
  fi
}

# Display help message
show_help() {
  echo "XPC Migration Manager"
  echo "Usage: $0 [command] [options]"
  echo ""
  echo "Commands:"
  echo "  init                 Initialize migration status from analysis report"
  echo "  status               Show migration status"
  echo "  list [status]        List files by status (migrated, inProgress, needsMigration)"
  echo "  start [file]         Start migration for a file"
  echo "  complete [file]      Mark a file as migrated"
  echo "  reset [file]         Reset status for a file to needs migration"
  echo "  next [module]        Suggest next file to migrate (optionally from a specific module)"
  echo "  help                 Show this help message"
}

# Main command processing
case "$1" in
  "init")
    initialize_needs_migration
    ;;
  "status")
    show_status
    ;;
  "list")
    list_files "${2:-needsMigration}"
    ;;
  "start")
    if [ -z "$2" ]; then
      echo "Error: No file specified."
      echo "Usage: $0 start [file]"
      exit 1
    fi
    start_migration "$2"
    ;;
  "complete")
    if [ -z "$2" ]; then
      echo "Error: No file specified."
      echo "Usage: $0 complete [file]"
      exit 1
    fi
    mark_migrated "$2"
    ;;
  "reset")
    if [ -z "$2" ]; then
      echo "Error: No file specified."
      echo "Usage: $0 reset [file]"
      exit 1
    fi
    reset_status "$2"
    ;;
  "next")
    suggest_next "$2"
    ;;
  "help"|"")
    show_help
    ;;
  *)
    echo "Error: Unknown command '$1'"
    show_help
    exit 1
    ;;
esac

exit 0
