#!/bin/bash

#==============================================================================
# Directory Listing Script
#==============================================================================
# Description: Script to list all files and subdirectories in a given directory
#              and save the paths to a text file with optional tree-like output.
#
# Author:      JxH
# Email:       v7_@hotmail.com  
# Version:     1.0
# Date:        2025-06-29
# License:     MIT License
#
# Repository:  https://github.com/OmarJxH/-tree-lister.git
#==============================================================================

# Script metadata
SCRIPT_NAME="Directory Listing Script"
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="JxH"
SCRIPT_EMAIL="v7_@hotmail.com"
SCRIPT_DATE="2025-06-29"

# Display help information
show_help() {
    cat << EOF
$SCRIPT_NAME v$SCRIPT_VERSION
Author: $SCRIPT_AUTHOR <$SCRIPT_EMAIL>

USAGE:
    $0 [directory_path] [OPTIONS]

DESCRIPTION:
    Lists all files and subdirectories in the specified directory (or current 
    directory if none specified) and saves the output to a timestamped text file.

OPTIONS:
    --tree      Display output in tree format (default: simple list)
    --help      Show this help message
    --version   Show version information

EXAMPLES:
    $0                              # Scan current directory
    $0 /home/user/documents
    $0 /home/user/documents --tree
    $0 . --tree
    $0 --tree                       # Tree format for current directory

OUTPUT:
    Creates a file named 'directory_contents_YYYYMMDD_HHMMSS.txt' in the
    current directory containing the complete directory listing.

REQUIREMENTS:
    - Bash 4.0 or higher
    - Standard Unix utilities (find, sort, date, wc)
    - Optional: tree command for enhanced formatting

AUTHOR:
    $SCRIPT_AUTHOR ($SCRIPT_EMAIL)
    
LICENSE:
    MIT License - Feel free to use, modify, and distribute.

EOF
}

# Display version information
show_version() {
    echo "$SCRIPT_NAME v$SCRIPT_VERSION"
    echo "Author: $SCRIPT_AUTHOR <$SCRIPT_EMAIL>"
    echo "Date: $SCRIPT_DATE"
    echo "License: MIT"
}

# Check for help or version flags first
case "$1" in
    --help|-h)
        show_help
        exit 0
        ;;
    --version|-v)
        show_version
        exit 0
        ;;
esac

# Check if a directory path is provided as an argument
if [ -z "$1" ]; then
    echo "=========================================="
    echo "$SCRIPT_NAME v$SCRIPT_VERSION"
    echo "Author: $SCRIPT_AUTHOR"
    echo "=========================================="
    echo "❌ Error: No directory path provided!"
    echo ""
    echo "📁 Please specify a directory to scan:"
    echo "   Example: $0 /path/to/directory"
    echo "   Example: $0 /home/user/documents --tree"
    echo ""
    echo "💡 Use '$0 --help' for complete usage information."
    echo "=========================================="
    exit 1
fi

TARGET_DIR="$1"
OUTPUT_FORMAT="list" # Default to list format

# Parse additional arguments
shift # Shift past the TARGET_DIR argument
# Handle special case where first argument might be an option
while [ "$#" -gt 0 ]; do
    case "$1" in
        --tree)
            OUTPUT_FORMAT="tree"
            ;;
        *)
            echo "Warning: Unknown option '$1'. Use --help for valid options."
            ;;
    esac
    shift
done

# Check if the provided path is a valid directory
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' not found or is not a directory."
    exit 1
fi

# Check if directory is readable
if [ ! -r "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' is not readable. Check permissions."
    exit 1
fi

# Generate unique output filename with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BASE_NAME="directory_contents"
OUTPUT_FILE="${BASE_NAME}_${TIMESTAMP}.txt"

# Get absolute path for better display
ABS_TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

# Exclude the script itself from the listing
script_name=$(basename "$0")

echo "=========================================="
echo "$SCRIPT_NAME v$SCRIPT_VERSION"
echo "Author: $SCRIPT_AUTHOR"
echo "=========================================="
echo "📁 Scanning: '$ABS_TARGET_DIR'"
echo "📄 Output format: $OUTPUT_FORMAT"
echo "💾 Saving to: '$OUTPUT_FILE' (in current directory)"
echo "=========================================="

# Create file header
cat > "$OUTPUT_FILE" << EOF
================================================================================
$SCRIPT_NAME v$SCRIPT_VERSION
================================================================================
Author:           $SCRIPT_AUTHOR
Email:            $SCRIPT_EMAIL
Generated on:     $(date)
Target directory: $ABS_TARGET_DIR
Output format:    $OUTPUT_FORMAT
================================================================================

EOF

# Build the find command and generate output
if [ "$OUTPUT_FORMAT" = "tree" ]; then
    echo "DIRECTORY TREE:" >> "$OUTPUT_FILE"
    echo "================================================================================" >> "$OUTPUT_FILE"
    
    # Use tree command if available, otherwise use find with formatting
    if command -v tree >/dev/null 2>&1; then
        tree "$TARGET_DIR" -a -I "$script_name" >> "$OUTPUT_FILE" 2>/dev/null
    else
        # Alternative tree-like formatting using find and awk
        echo "$ABS_TARGET_DIR" >> "$OUTPUT_FILE"
        find "$TARGET_DIR" -mindepth 1 -not -name "$script_name" -print | \
        sort | \
        sed "s|^$TARGET_DIR/||" | \
        awk '
        BEGIN { FS = "/" }
        {
            depth = NF
            for (i = 1; i < depth; i++) {
                printf "│   "
            }
            if (depth > 0) {
                printf "├── "
            }
            print $NF
        }' >> "$OUTPUT_FILE"
    fi
else
    echo "DIRECTORY LISTING:" >> "$OUTPUT_FILE"
    echo "================================================================================" >> "$OUTPUT_FILE"
    find "$TARGET_DIR" -mindepth 1 -not -name "$script_name" -print | sort >> "$OUTPUT_FILE"
fi

# Add footer with statistics
echo "" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"
echo "STATISTICS:" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"

# Count files and directories
total_items=$(find "$TARGET_DIR" -mindepth 1 -not -name "$script_name" | wc -l)
total_files=$(find "$TARGET_DIR" -mindepth 1 -type f -not -name "$script_name" | wc -l)
total_dirs=$(find "$TARGET_DIR" -mindepth 1 -type d -not -name "$script_name" | wc -l)

echo "Total items:      $total_items" >> "$OUTPUT_FILE"
echo "Files:            $total_files" >> "$OUTPUT_FILE"
echo "Directories:      $total_dirs" >> "$OUTPUT_FILE"
echo "Script excluded:  $script_name" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Generated by $SCRIPT_NAME v$SCRIPT_VERSION" >> "$OUTPUT_FILE"
echo "Author: $SCRIPT_AUTHOR <$SCRIPT_EMAIL>" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"

# Display completion message
echo "✅ Scan completed successfully!"
echo "📁 Total items found: $total_items ($total_files files, $total_dirs directories)"
echo "📄 Results saved to: $OUTPUT_FILE"
echo "💾 File location: $(pwd)/$OUTPUT_FILE"
echo "=========================================="

exit 0
