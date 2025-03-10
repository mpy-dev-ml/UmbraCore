#!/bin/bash
# Script to extract Swift compilation errors from Bazel build output
# This script focuses on finding actual Swift error messages

# Output file for the error analysis
OUTPUT_FILE="swift_build_errors.csv"
echo "Target,Error,File,Line" > "$OUTPUT_FILE"

# Extract stderr content from the build output
echo "Extracting Swift compilation errors..."
grep -a "stderr" build_output.json | grep -a "error:" > swift_errors_raw.txt

# Process each error line
while IFS= read -r line; do
  # Extract the stderr content using jq
  error_msg=$(echo "$line" | jq -r '.stderr')
  
  # Skip if empty
  if [ -z "$error_msg" ]; then
    continue
  fi
  
  # Extract target information if available
  target=""
  if echo "$line" | grep -q "actionCompleted"; then
    target=$(echo "$line" | jq -r '.id.actionCompleted.primaryOutput' | grep -o '[^/]*$' | sed 's/\.o$//')
  fi
  
  # Process each line of the error message
  echo "$error_msg" | grep -a "error:" | while IFS= read -r err_line; do
    # Extract file, line number and error message
    file=$(echo "$err_line" | grep -o '[^:]*:[0-9]*:[0-9]*:' | head -1)
    error=$(echo "$err_line" | sed 's/.*error: //')
    
    # Clean up the data for CSV
    file=$(echo "$file" | sed 's/:[0-9]*:[0-9]*:$//')
    line_num=$(echo "$err_line" | grep -o ':[0-9]*:' | head -1 | tr -d ':')
    
    # Escape quotes for CSV
    error=$(echo "$error" | sed 's/"/""/g')
    
    # Write to CSV
    echo "\"$target\",\"$error\",\"$file\",\"$line_num\"" >> "$OUTPUT_FILE"
  done
done < swift_errors_raw.txt

# Clean up
rm swift_errors_raw.txt

# Create a summary by target
echo "Creating error summary by target..."
SUMMARY_FILE="swift_errors_summary.csv"
echo "Target,ErrorCount" > "$SUMMARY_FILE"

# Count errors per target and sort by count (descending)
tail -n +2 "$OUTPUT_FILE" | cut -d',' -f1 | sort | uniq -c | sort -nr | 
  sed 's/^ *\([0-9]*\) \(.*\)/\2,\1/' >> "$SUMMARY_FILE"

# Create a summary by file
echo "Creating error summary by file..."
FILE_SUMMARY="swift_errors_by_file.csv"
echo "File,ErrorCount" > "$FILE_SUMMARY"

# Count errors per file and sort by count (descending)
tail -n +2 "$OUTPUT_FILE" | cut -d',' -f3 | sort | uniq -c | sort -nr | 
  sed 's/^ *\([0-9]*\) \(.*\)/\2,\1/' >> "$FILE_SUMMARY"

echo "Analysis complete. Results saved to:"
echo "- $OUTPUT_FILE (detailed errors)"
echo "- $SUMMARY_FILE (errors by target)"
echo "- $FILE_SUMMARY (errors by file)"
