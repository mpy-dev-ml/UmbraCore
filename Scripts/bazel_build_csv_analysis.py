import json
import csv
import sys
import pandas as pd

def json_to_csv(json_file, csv_file):
    """
    Converts a Bazel build event JSON file into a CSV file.
    """
    with open(json_file, 'r') as f:
        data = [json.loads(line) for line in f]

    # Extract relevant information
    csv_data = []
    for event in data:
        if "id" in event and "targetCompleted" in event["id"]:
            target_label = event["id"]["targetCompleted"]["label"]
            status = event.get("completed", {}).get("success", False)
            errors = event.get("completed", {}).get("failureDetail", {}).get("message", "No error message")
            csv_data.append([target_label, status, errors])

    # Write to CSV
    with open(csv_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Target", "Status", "Error Message"])
        writer.writerows(csv_data)

    print(f"CSV file generated: {csv_file}")

def analyze_csv(csv_file):
    """
    Loads CSV into Pandas, analyzes the failure count, and ranks failing targets.
    """
    df = pd.read_csv(csv_file)

    # Count total and failing targets
    total_targets = len(df)
    failing_targets = df[df['Status'] == False]
    total_failing = len(failing_targets)

    print("\n🔹 Build Analysis Summary:")
    print(f"   - Total Targets: {total_targets}")
    print(f"   - Failing Targets: {total_failing}")

    if total_failing == 0:
        print("✅ No failing targets detected.")
        return

    # Stack rank failing targets by occurrence
    failing_ranking = failing_targets.groupby("Target").size().reset_index(name="Failure Count")
    failing_ranking = failing_ranking.sort_values(by="Failure Count", ascending=False)

    print("\n🔥 Stack Ranked Failing Targets:")
    print(failing_ranking.to_string(index=False))

    # Display each error with verbose output
    print("\n📌 Detailed Errors per Target:")
    for target in failing_targets["Target"].unique():
        target_errors = failing_targets[failing_targets["Target"] == target]["Error Message"].values
        print(f"\n🚨 Target: {target} (Failures: {len(target_errors)})")
        for i, error in enumerate(target_errors, start=1):
            print(f"   {i}. {error}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python bazel_json_to_csv_analysis.py <bazel_build.json>")
        sys.exit(1)

    json_file = sys.argv[1]
    csv_file = "build_results.csv"

    # Convert JSON to CSV
    json_to_csv(json_file, csv_file)

    # Analyze the CSV
    analyze_csv(csv_file)