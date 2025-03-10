#!/bin/bash
# Script to extract stderr files referenced in the build output
# These files contain the actual error messages from failed builds

# Output directory for stderr files
mkdir -p build_errors

# Extract all stderr file references
echo "Extracting stderr file references..."
grep -o '"stderr":{"name":"stderr","uri":"[^"]*"' build_output.json | 
  sed 's/"stderr":{"name":"stderr","uri":"//' | 
  sed 's/"$//' > stderr_files.txt

# Count the number of stderr files
file_count=$(wc -l < stderr_files.txt)
echo "Found $file_count stderr file references"

# Create a CSV file to store the error analysis
ERROR_CSV="build_failures_analysis.csv"
echo "Target,Error,File,Line" > "$ERROR_CSV"

# Process each stderr file
count=0
while IFS= read -r file_uri; do
  count=$((count + 1))
  echo "Processing file $count of $file_count: $file_uri"
  
  # Extract the file path from the URI
  file_path=$(echo "$file_uri" | sed 's|file:///||')
  
  # Skip if file doesn't exist
  if [ ! -f "$file_path" ]; then
    echo "  File not found: $file_path"
    continue
  fi
  
  # Get the target name from the build output
  target=$(grep -B 5 "$file_uri" build_output.json | 
    grep -o '"label":"[^"]*"' | head -1 | 
    sed 's/"label":"//;s/"$//')
  
  # Create a copy of the stderr file
  output_file="build_errors/stderr_${count}.txt"
  cp "$file_path" "$output_file"
  
  # Extract Swift error messages
  grep "error:" "$file_path" | while IFS= read -r error_line; do
    # Extract file and line information if available
    if [[ $error_line =~ ([^:]+):([0-9]+):([0-9]+):\ error:\ (.*) ]]; then
      src_file="${BASH_REMATCH[1]}"
      line_num="${BASH_REMATCH[2]}"
      error_msg="${BASH_REMATCH[4]}"
      
      # Escape quotes for CSV
      error_msg=$(echo "$error_msg" | sed 's/"/""/g')
      
      # Add to CSV
      echo "\"$target\",\"$error_msg\",\"$src_file\",\"$line_num\"" >> "$ERROR_CSV"
    else
      # For errors without file/line info
      error_msg=$(echo "$error_line" | sed 's/.*error: //')
      error_msg=$(echo "$error_msg" | sed 's/"/""/g')
      echo "\"$target\",\"$error_msg\",\"\",\"\"" >> "$ERROR_CSV"
    fi
  done
  
  # Also check for other common error patterns
  grep -E "fatal error:|undefined symbol|linker command failed|cannot find" "$file_path" | 
  while IFS= read -r error_line; do
    error_msg=$(echo "$error_line" | sed 's/"/""/g')
    echo "\"$target\",\"$error_msg\",\"\",\"\"" >> "$ERROR_CSV"
  done
  
done < stderr_files.txt

# Create a summary by target
echo "Creating error summary by target..."
SUMMARY_CSV="build_failures_by_target.csv"
echo "Target,ErrorCount" > "$SUMMARY_CSV"

# Count errors per target and sort by count (descending)
tail -n +2 "$ERROR_CSV" | cut -d',' -f1 | sort | uniq -c | sort -nr | 
  sed 's/^ *\([0-9]*\) \(.*\)/\2,\1/' >> "$SUMMARY_CSV"

# Create a summary by file
echo "Creating error summary by file..."
FILE_SUMMARY="build_failures_by_file.csv"
echo "File,ErrorCount" > "$FILE_SUMMARY"

# Count errors per file and sort by count (descending)
tail -n +2 "$ERROR_CSV" | cut -d',' -f3 | grep -v '^""$' | sort | uniq -c | sort -nr | 
  sed 's/^ *\([0-9]*\) \(.*\)/\2,\1/' >> "$FILE_SUMMARY"

echo "Analysis complete. Results saved to:"
echo "- $ERROR_CSV (detailed errors)"
echo "- $SUMMARY_CSV (errors by target)"
echo "- $FILE_SUMMARY (errors by file)"
echo "- build_errors/ directory (raw stderr files)"

# Show the top 10 failing targets
echo ""
echo "Top 10 failing targets:"
head -n 11 "$SUMMARY_CSV"
