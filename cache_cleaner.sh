#!/bin/bash
set -e

# --- Configuration ---
CHECK_INTERVAL=300 # Check every 5 minutes

# --- Functions ---
get_file_size() {
    # Get size in bytes (macOS compatible)
    stat -f%z "$1"
}

# --- Main Script ---
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file_to_watch> <size_threshold_in_bytes>"
    exit 1
fi

FILE_TO_WATCH=$1
SIZE_THRESHOLD=$2
LOG_FILE="$(dirname "$0")/cache_cleaner.log"

echo "$(date): Cache cleaner daemon started for file: $FILE_TO_WATCH" >> "$LOG_FILE"

while true; do
    echo "$(date): Checking file: $FILE_TO_WATCH" >> "$LOG_FILE"
    
    current_size=$(get_file_size "$FILE_TO_WATCH")
    echo "$(date): File '$FILE_TO_WATCH' size: $current_size bytes" >> "$LOG_FILE"

    if [ "$current_size" -gt "$SIZE_THRESHOLD" ]; then
        echo "$(date): Cache '$FILE_TO_WATCH' is over threshold ($current_size > $SIZE_THRESHOLD bytes)." >> "$LOG_FILE"
        echo "$(date): Clearing '$FILE_TO_WATCH'..." >> "$LOG_FILE"
        
        # --- Deletion is now active ---
        >"$FILE_TO_WATCH"
        
        echo "$(date): Cleared '$FILE_TO_WATCH'." >> "$LOG_FILE"
    fi

    echo "$(date): Check complete. Next check in $CHECK_INTERVAL seconds." >> "$LOG_FILE"
    sleep $CHECK_INTERVAL
done
