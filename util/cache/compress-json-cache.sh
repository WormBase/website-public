#!/bin/bash

# Compress JSON cache files on disk
# Efficiently gzips JSON files in the sharded cache directory

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default settings
JSON_CACHE_ROOT="/mnt/json-cache-WS298/json"
PARALLEL_JOBS=4  # Number of parallel gzip processes
DRY_RUN=0

# Usage
usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <class|all>

Compress JSON cache files for a specific object class or all classes.

Arguments:
  <class>         Object class to compress (gene, protein, variation, etc.)
  all             Compress all classes

Options:
  -r <path>       JSON cache root directory (default: $JSON_CACHE_ROOT)
  -j <num>        Number of parallel jobs (default: $PARALLEL_JOBS)
  -d              Dry run - show what would be compressed without doing it
  -h              Show this help message

Examples:
  $0 gene                    # Compress all gene JSON files
  $0 protein                 # Compress all protein JSON files
  $0 all                     # Compress all classes
  $0 -j 8 gene              # Use 8 parallel jobs
  $0 -d gene                # Dry run to see what would be compressed

EOF
    exit 1
}

# Parse options
while getopts "r:j:dh" opt; do
    case $opt in
        r) JSON_CACHE_ROOT="$OPTARG" ;;
        j) PARALLEL_JOBS="$OPTARG" ;;
        d) DRY_RUN=1 ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

# Check arguments
if [ $# -ne 1 ]; then
    echo -e "${RED}Error: Missing class argument${NC}"
    usage
fi

CLASS="$1"

# Validate cache root
if [ ! -d "$JSON_CACHE_ROOT" ]; then
    echo -e "${RED}Error: JSON cache root not found: $JSON_CACHE_ROOT${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}JSON Cache Compression${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Cache root:      ${BLUE}$JSON_CACHE_ROOT${NC}"
echo -e "Class:           ${BLUE}$CLASS${NC}"
echo -e "Parallel jobs:   ${BLUE}$PARALLEL_JOBS${NC}"
echo -e "Dry run:         ${BLUE}$( [ $DRY_RUN -eq 1 ] && echo 'YES' || echo 'NO' )${NC}"
echo ""

# Determine search paths (array to handle both widgets and fields)
SEARCH_PATHS=()

if [ "$CLASS" = "all" ]; then
    SEARCH_PATHS+=("$JSON_CACHE_ROOT")
    echo -e "${YELLOW}Compressing all classes (widgets and fields)...${NC}"
else
    # Check for both widget and field directories
    WIDGET_PATH="$JSON_CACHE_ROOT/widget/$CLASS"
    FIELD_PATH="$JSON_CACHE_ROOT/field/$CLASS"

    if [ -d "$WIDGET_PATH" ]; then
        SEARCH_PATHS+=("$WIDGET_PATH")
        echo -e "${YELLOW}Found widget directory: ${NC}${BLUE}$WIDGET_PATH${NC}"
    fi

    if [ -d "$FIELD_PATH" ]; then
        SEARCH_PATHS+=("$FIELD_PATH")
        echo -e "${YELLOW}Found field directory: ${NC}${BLUE}$FIELD_PATH${NC}"
    fi

    if [ ${#SEARCH_PATHS[@]} -eq 0 ]; then
        echo -e "${RED}Error: No directories found for class '$CLASS'${NC}"
        echo "Tried:"
        echo "  $WIDGET_PATH"
        echo "  $FIELD_PATH"
        exit 1
    fi

    echo -e "${YELLOW}Compressing class: $CLASS${NC}"
    echo -e "Search paths: ${BLUE}${#SEARCH_PATHS[@]}${NC} directories"
fi
echo ""

# Count total uncompressed JSON files across all search paths
echo -e "${YELLOW}Scanning for uncompressed JSON files...${NC}"
TOTAL_FILES=0
for path in "${SEARCH_PATHS[@]}"; do
    count=$(find "$path" -type f -name "*.json" ! -name "*.json.gz" 2>/dev/null | wc -l | tr -d ' ')
    TOTAL_FILES=$((TOTAL_FILES + count))
done
echo -e "Found ${BLUE}$TOTAL_FILES${NC} uncompressed JSON files"
echo ""

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo -e "${GREEN}No files to compress!${NC}"
    exit 0
fi

# Calculate current size
echo -e "${YELLOW}Calculating current size...${NC}"
CURRENT_SIZE=0
for path in "${SEARCH_PATHS[@]}"; do
    size=$(find "$path" -type f -name "*.json" ! -name "*.json.gz" -exec du -b {} + 2>/dev/null | awk '{sum+=$1} END {print sum}')
    CURRENT_SIZE=$((CURRENT_SIZE + size))
done
CURRENT_SIZE_MB=$(echo "scale=2; $CURRENT_SIZE / 1048576" | bc)
echo -e "Current size: ${BLUE}${CURRENT_SIZE_MB} MB${NC}"
echo ""

if [ $DRY_RUN -eq 1 ]; then
    echo -e "${YELLOW}DRY RUN - Would compress:${NC}"
    count=0
    for path in "${SEARCH_PATHS[@]}"; do
        find "$path" -type f -name "*.json" ! -name "*.json.gz" 2>/dev/null | while read file; do
            if [ $count -lt 20 ]; then
                echo "$file"
                count=$((count + 1))
            fi
        done
    done
    if [ "$TOTAL_FILES" -gt 20 ]; then
        echo "... and $((TOTAL_FILES - 20)) more files"
    fi
    echo ""
    echo -e "${YELLOW}Estimated compression ratio: 85-95%${NC}"
    echo -e "Estimated final size: ${BLUE}$(echo "scale=2; $CURRENT_SIZE_MB * 0.10" | bc) - $(echo "scale=2; $CURRENT_SIZE_MB * 0.15" | bc) MB${NC}"
    exit 0
fi

# Compress files
echo -e "${YELLOW}Compressing files (using $PARALLEL_JOBS parallel jobs)...${NC}"
echo -e "${BLUE}Progress:${NC}"

# Check if GNU parallel is available
if command -v parallel >/dev/null 2>&1; then
    # Use GNU parallel for better progress reporting
    for path in "${SEARCH_PATHS[@]}"; do
        find "$path" -type f -name "*.json" ! -name "*.json.gz" -print0 2>/dev/null
    done | parallel -0 -j "$PARALLEL_JOBS" --bar gzip -9 {}
else
    # Fallback to xargs
    echo "(Using xargs - install 'parallel' for progress bar)"
    for path in "${SEARCH_PATHS[@]}"; do
        find "$path" -type f -name "*.json" ! -name "*.json.gz" -print0 2>/dev/null
    done | xargs -0 -P "$PARALLEL_JOBS" -n 1 gzip -9
fi

# Calculate compressed size
echo ""
echo -e "${YELLOW}Calculating compressed size...${NC}"
COMPRESSED_SIZE=0
for path in "${SEARCH_PATHS[@]}"; do
    size=$(find "$path" -type f -name "*.json.gz" -exec du -b {} + 2>/dev/null | awk '{sum+=$1} END {print sum}')
    COMPRESSED_SIZE=$((COMPRESSED_SIZE + size))
done
COMPRESSED_SIZE_MB=$(echo "scale=2; $COMPRESSED_SIZE / 1048576" | bc)
COMPRESSION_RATIO=$(echo "scale=2; ($CURRENT_SIZE - $COMPRESSED_SIZE) / $CURRENT_SIZE * 100" | bc)
SAVINGS_MB=$(echo "scale=2; $CURRENT_SIZE_MB - $COMPRESSED_SIZE_MB" | bc)

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Compression Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Files compressed:    ${BLUE}$TOTAL_FILES${NC}"
echo -e "Original size:       ${BLUE}${CURRENT_SIZE_MB} MB${NC}"
echo -e "Compressed size:     ${GREEN}${COMPRESSED_SIZE_MB} MB${NC}"
echo -e "Space saved:         ${GREEN}${SAVINGS_MB} MB${NC}"
echo -e "Compression ratio:   ${GREEN}${COMPRESSION_RATIO}%${NC}"
echo -e "${GREEN}========================================${NC}"
