#!/bin/bash

# JSON Cache Coverage Analysis Script
# Analyzes fallback logs to identify gaps in JSON cache coverage

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Find log file
LOG_FILE=""
if [ -n "$1" ]; then
    LOG_FILE="$1"
else
    # Search for common log file names
    for pattern in "wormbase-catalyst-access.log" "wormbase*.log" "catalyst*.log"; do
        found=$(find logs/ -name "$pattern" 2>/dev/null | head -1)
        if [ -n "$found" ]; then
            LOG_FILE="$found"
            break
        fi
    done
fi

if [ -z "$LOG_FILE" ] || [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}Error: Log file not found${NC}"
    echo "Usage: $0 [path/to/logfile]"
    echo "Or run from project root with logs in ./logs/ directory"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}JSON Cache Coverage Analysis${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Log file: ${BLUE}$LOG_FILE${NC}"
echo ""

# Total fallbacks
echo -e "${YELLOW}1. Total Fallback Requests:${NC}"
total_fallbacks=$(grep '\[FALLBACK\]' "$LOG_FILE" | wc -l | tr -d ' ')
echo -e "   ${BLUE}$total_fallbacks${NC} requests fell back to CouchDB/Datomic/ACeDB"
echo ""

# Backend breakdown
echo -e "${YELLOW}2. Breakdown by Backend Source:${NC}"
grep 'served by' "$LOG_FILE" | \
  sed 's/.*served by //' | \
  sort | uniq -c | sort -rn | \
  awk '{printf "   %-40s %s\n", $2" "$3" "$4" "$5, $1}'
echo ""

# Missing widgets by type
echo -e "${YELLOW}3. Missing Widgets (by widget type):${NC}"
grep '\[FALLBACK\] JSON cache miss for widget' "$LOG_FILE" 2>/dev/null | \
  awk '{print $NF}' | \
  awk -F'/' '{print $3}' | \
  sort | uniq -c | sort -rn | head -20 | \
  awk '{printf "   %-30s %s requests\n", $2, $1}' || echo "   No widget fallbacks found"
echo ""

# Missing fields by type
echo -e "${YELLOW}4. Missing Fields (by field type):${NC}"
grep '\[FALLBACK\] JSON cache miss for field' "$LOG_FILE" 2>/dev/null | \
  awk '{print $NF}' | \
  awk -F'/' '{print $3}' | \
  sort | uniq -c | sort -rn | head -20 | \
  awk '{printf "   %-30s %s requests\n", $2, $1}' || echo "   No field fallbacks found"
echo ""

# Top missing widgets (class/name/widget combinations)
echo -e "${YELLOW}5. Top 20 Missing Widgets (specific requests):${NC}"
grep '\[FALLBACK\] JSON cache miss for widget' "$LOG_FILE" 2>/dev/null | \
  sed 's/.*widget //' | \
  sed 's/ -.*//' | \
  sort | uniq -c | sort -rn | head -20 | \
  awk '{printf "   %-50s %s requests\n", $2, $1}' || echo "   No widget fallbacks found"
echo ""

# Breakdown by class
echo -e "${YELLOW}6. Fallbacks by Object Class:${NC}"
grep '\[FALLBACK\] JSON cache miss' "$LOG_FILE" 2>/dev/null | \
  awk -F'/' '{print $1}' | \
  awk '{print $NF}' | \
  sort | uniq -c | sort -rn | \
  awk '{printf "   %-20s %s requests\n", $2, $1}' || echo "   No class data found"
echo ""

# Success rate
echo -e "${YELLOW}7. JSON Cache Hit Rate:${NC}"
total_attempts=$(grep 'Attempting to load.*from JSON disk cache' "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')
successful=$(grep '\[SUCCESS\] Using JSON from disk' "$LOG_FILE" 2>/dev/null | wc -l | tr -d ' ')

if [ "$total_attempts" -gt 0 ]; then
    hit_rate=$(echo "scale=2; ($successful / $total_attempts) * 100" | bc)
    echo -e "   Total attempts:  ${BLUE}$total_attempts${NC}"
    echo -e "   Successful:      ${GREEN}$successful${NC}"
    echo -e "   Fallbacks:       ${RED}$total_fallbacks${NC}"
    echo -e "   Hit rate:        ${GREEN}${hit_rate}%${NC}"
else
    echo "   No cache attempts found in log"
fi
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Analysis Complete${NC}"
echo -e "${GREEN}========================================${NC}"
