#!/bin/bash
# Script to extract build errors from Bazel build_output.json and convert to CSV
# Uses jq to process the JSON and extract relevant information

# Output CSV file
OUTPUT_CSV="build_errors.csv"

# Create CSV header
echo "Target,Error,File,Line" > "$OUTPUT_CSV"

# Process the build_output.json file
cat build_output.json | while read -r line; do
  # Extract failed targets with their errors
  echo "$line" | jq -r '
    # Check if this is a targetCompleted event with failure
    if (.id.targetCompleted != null and .completed != null and .completed.success == false) then
      .id.targetCompleted.label + ",\"Target failed to build\",\"\",\"\""
    # Check if this is an action with stderr (error output)
    elif (.id.actionCompleted != null and .stderr != null and .stderr != "") then
      # Try to extract target information
      (.id.actionCompleted.primaryOutput | split("/") | join("/")) as $output |
      # Extract error details using regex
      (.stderr | gsub("\n";" ") | gsub("\r";" ")) as $stderr |
      # Output as CSV
      $output + ",\"" + $stderr + "\",\"\",\"\""
    else
      empty
    end
  ' 2>/dev/null >> "$OUTPUT_CSV"
done

# Clean up the CSV to remove duplicates and empty lines
TMP_CSV="tmp_build_errors.csv"
cat "$OUTPUT_CSV" | sort | uniq | grep -v "^$" > "$TMP_CSV"
mv "$TMP_CSV" "$OUTPUT_CSV"

echo "Build errors extracted to $OUTPUT_CSV"

# Create a summary of errors by target
echo "Creating error summary by target..."
SUMMARY_CSV="build_errors_summary.csv"
echo "Target,ErrorCount" > "$SUMMARY_CSV"

# Count errors per target
tail -n +2 "$OUTPUT_CSV" | cut -d',' -f1 | sort | uniq -c | sort -nr | 
  awk '{print $2 "," $1}' >> "$SUMMARY_CSV"

echo "Error summary created in $SUMMARY_CSV"
