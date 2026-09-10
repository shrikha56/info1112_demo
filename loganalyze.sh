#!/bin/bash
chmod +x loganalyze.sh tests/run_tc01.sh

DATA_FILE="$HOME/analysisData.log"
SUMMARY_FILE="$HOME/summary.log"
 
if [ "$#" -eq 0 ]; then
    dir="$(pwd)"
elif [ "$#" -eq 1 ]; then
    if [ -d "$1" ]; then
        dir="$1"
    else
        echo -e "usage: arg needs to be a directory.\n"
        exit 1
    fi
else
    echo -e "usage: more than 1 arg is not allowed.\n"
    exit 2
fi

files=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "*.log" -mtime -7)
 
if [ -z "$files" ]; then
    echo -e "No. of modified log files: 0\n"
    exit 0
fi
 
: > "$DATA_FILE"
: > "$SUMMARY_FILE"
 
count=0
total=0
max_count=-1
max_file=""
 
while IFS= read -r f; do
    count=$((count + 1))
    errors=$(grep -oi "error" "$f" | wc -l)
 
    echo "$(basename "$f"): $errors" | tee -a "$DATA_FILE"
 
    total=$((total + errors))
 
    if [ "$errors" -gt "$max_count" ]; then
        max_count=$errors
        max_file=$(basename "$f")
    fi
done <<< "$files"

{   echo "No. of modified log files: $count"
    echo "Total no. of errors: $total"
        echo "File with the most errors: $max_file ($max_count)"
} | tee "$SUMMARY_FILE"
 
exit 0