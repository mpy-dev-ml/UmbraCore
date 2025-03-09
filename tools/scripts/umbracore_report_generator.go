package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"
	"sort"
	"strconv"
	"time"
)

type Target struct {
	Name        string
	Type        string
	TotalLOC    int
	FileCount   int
	Files       []File
}

type File struct {
	Path string
	LOC  int
}

func main() {
	fmt.Println("Generating UmbraCore analysis report...")
	start := time.Now()

	// Open the CSV file
	file, err := os.Open("umbracore_loc_analysis.csv")
	if err != nil {
		fmt.Printf("Error opening CSV file: %v\n", err)
		return
	}
	defer file.Close()

	// Parse the CSV data
	targets, allFiles, err := parseCSV(file)
	if err != nil {
		fmt.Printf("Error parsing CSV: %v\n", err)
		return
	}

	// Generate the markdown report
	err = generateReport(targets, allFiles)
	if err != nil {
		fmt.Printf("Error generating report: %v\n", err)
		return
	}

	elapsed := time.Since(start)
	fmt.Printf("Report generated in %s\n", elapsed)
}

func parseCSV(file io.Reader) (map[string]*Target, []File, error) {
	reader := csv.NewReader(file)
	
	// Skip header row
	_, err := reader.Read()
	if err != nil {
		return nil, nil, fmt.Errorf("error reading CSV header: %v", err)
	}

	targets := make(map[string]*Target)
	var allFiles []File
	var currentTarget *Target

	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return nil, nil, fmt.Errorf("error reading CSV record: %v", err)
		}

		// Skip empty records
		if len(record) < 5 {
			continue
		}

		targetName := record[0]
		targetType := record[1]
		totalLOCStr := record[2]
		filePath := record[3]
		fileLOCStr := record[4]
		
		// If this record contains target information
		if targetName != "" {
			// Create a new target or get existing one
			var exists bool
			currentTarget, exists = targets[targetName]
			
			if !exists {
				totalLOC := 0
				if totalLOCStr != "" {
					totalLOC, err = strconv.Atoi(totalLOCStr)
					if err != nil {
						fmt.Printf("Warning: Could not parse LOC for target %s: %v\n", targetName, err)
						totalLOC = 0
					}
				}
				
				currentTarget = &Target{
					Name:      targetName,
					Type:      targetType,
					TotalLOC:  totalLOC,
					FileCount: 0,
					Files:     []File{},
				}
				targets[targetName] = currentTarget
			}
		}

		// If this record contains file information
		if filePath != "" && currentTarget != nil {
			fileLOC := 0
			if fileLOCStr != "" {
				fileLOC, err = strconv.Atoi(fileLOCStr)
				if err != nil {
					fmt.Printf("Warning: Could not parse LOC for file %s: %v\n", filePath, err)
					fileLOC = 0
				}
			}
			
			file := File{
				Path: filePath,
				LOC:  fileLOC,
			}
			
			currentTarget.Files = append(currentTarget.Files, file)
			currentTarget.FileCount++
			
			// Also add to our global list of files
			allFiles = append(allFiles, file)
		}
	}

	// Update file counts for each target
	for _, target := range targets {
		target.FileCount = len(target.Files)
	}

	return targets, allFiles, nil
}

func generateReport(targets map[string]*Target, allFiles []File) error {
	// Convert map to slice for sorting
	targetsList := make([]*Target, 0, len(targets))
	for _, t := range targets {
		if t.TotalLOC > 0 {
			targetsList = append(targetsList, t)
		}
	}

	// Sort targets by LOC
	sort.Slice(targetsList, func(i, j int) bool {
		return targetsList[i].TotalLOC > targetsList[j].TotalLOC
	})

	// Sort files by LOC
	sort.Slice(allFiles, func(i, j int) bool {
		return allFiles[i].LOC > allFiles[j].LOC
	})

	// Generate the markdown report
	reportFile, err := os.Create("umbracore_analysis_report.md")
	if err != nil {
		return fmt.Errorf("error creating report file: %v", err)
	}
	defer reportFile.Close()

	// Calculate summary statistics
	totalLOC := 0
	totalFiles := 0
	for _, t := range targetsList {
		totalLOC += t.TotalLOC
		totalFiles += t.FileCount
	}

	// Write the report header with table
	reportFile.WriteString("# UmbraCore Project Analysis Report\n\n")
	reportFile.WriteString(fmt.Sprintf("*Generated on %s*\n\n", time.Now().Format("2 January 2006 at 15:04:05")))
	
	// Add colour legend
	reportFile.WriteString("## Colour Legend\n\n")
	reportFile.WriteString("| Colour | Meaning |\n")
	reportFile.WriteString("|--------|--------|\n")
	reportFile.WriteString("| <span style=\"color:#FFA500\">Amber</span> | File exceeds 500 lines of code - consider refactoring |\n")
	reportFile.WriteString("| <span style=\"color:#FF0000\">Red</span> | File exceeds 750 lines of code - high priority for refactoring |\n\n")
	
	// Write summary as a table
	reportFile.WriteString("## Summary\n\n")
	reportFile.WriteString("| Metric | Value |\n")
	reportFile.WriteString("|--------|-------|\n")
	reportFile.WriteString(fmt.Sprintf("| Total Targets with Code | %d |\n", len(targetsList)))
	reportFile.WriteString(fmt.Sprintf("| Total Files | %d |\n", totalFiles))
	reportFile.WriteString(fmt.Sprintf("| Total Lines of Code | %d |\n\n", totalLOC))

	// Write the targets section (already a table)
	reportFile.WriteString("## Targets by Lines of Code\n\n")
	reportFile.WriteString("| Rank | Target | Type | Files | Lines of Code |\n")
	reportFile.WriteString("|------|--------|------|-------|---------------|\n")
	
	for i, t := range targetsList {
		if i >= 20 {
			break // Only show top 20
		}
		reportFile.WriteString(fmt.Sprintf("| %d | `%s` | %s | %d | %d |\n", 
			i+1, t.Name, t.Type, t.FileCount, t.TotalLOC))
	}
	
	reportFile.WriteString("\n")

	// Write the files section with colour highlighting
	reportFile.WriteString("## Top 20 Files by Lines of Code\n\n")
	reportFile.WriteString("| Rank | File | Lines of Code |\n")
	reportFile.WriteString("|------|------|---------------|\n")
	
	for i, f := range allFiles {
		if i >= 20 {
			break // Only show top 20
		}
		
		// Add colour formatting based on LOC thresholds
		locStr := formatLOCWithColour(f.LOC)
		reportFile.WriteString(fmt.Sprintf("| %d | `%s` | %s |\n", 
			i+1, f.Path, locStr))
	}
	
	// Create a consolidated table showing each target and its files
	reportFile.WriteString("\n## Detailed Breakdown: All Targets and Files\n\n")
	reportFile.WriteString("| Target | Target Type | Total LOC | File | File LOC |\n")
	reportFile.WriteString("|--------|------------|-----------|------|----------|\n")
	
	for _, t := range targetsList {
		// Sort files within this target by LOC
		sort.Slice(t.Files, func(i, j int) bool {
			return t.Files[i].LOC > t.Files[j].LOC
		})
		
		// First row contains target information and first file
		if len(t.Files) > 0 {
			locStr := formatLOCWithColour(t.Files[0].LOC)
			reportFile.WriteString(fmt.Sprintf("| `%s` | %s | %d | `%s` | %s |\n", 
				t.Name, t.Type, t.TotalLOC, t.Files[0].Path, locStr))
			
			// Remaining files for this target
			for i := 1; i < len(t.Files); i++ {
				locStr := formatLOCWithColour(t.Files[i].LOC)
				reportFile.WriteString(fmt.Sprintf("| | | | `%s` | %s |\n", 
					t.Files[i].Path, locStr))
			}
		} else {
			reportFile.WriteString(fmt.Sprintf("| `%s` | %s | %d | | |\n", 
				t.Name, t.Type, t.TotalLOC))
		}
		
		// Add a separator row between targets for better readability
		reportFile.WriteString("| | | | | |\n")
	}

	fmt.Println("Report written to umbracore_analysis_report.md")
	return nil
}

// Format LOC with colour highlighting based on thresholds
func formatLOCWithColour(loc int) string {
	if loc > 750 {
		return fmt.Sprintf("<span style=\"color:#FF0000\">%d</span>", loc)
	} else if loc > 500 {
		return fmt.Sprintf("<span style=\"color:#FFA500\">%d</span>", loc)
	}
	return fmt.Sprintf("%d", loc)
}
