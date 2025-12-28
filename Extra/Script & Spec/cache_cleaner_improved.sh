#!/bin/bash
set -e

# Cache Cleaner Daemon
SAVE_PATH="/Users/kornienkodaniel/Documents/1_Projects/Cache Cleaner"
LOG_FILE="$SAVE_PATH/cache_cleaner.log"
CHECK_INTERVAL=300 # Check every 5 minutes
SIZE_THRESHOLD=500000000 # 500MB in bytes

# Cache directories to monitor - ADD MORE AS NEEDED
CACHE_DIRS=(
    "$HOME/Library/Caches/*"
    # Add other cache directories here if you have them
)

# Function to get directory size in bytes (macOS compatible)
get_dir_size() {
    # Get size in kilobytes and multiply by 1024 for bytes
    size_in_kb=$(du -sk "$1" | awk '{print $1}')
    echo $(($size_in_kb * 1024))
}

echo "$(date): Cache cleaner daemon started" >> "$LOG_FILE"

while true; do
    echo "$(date): Checking cache directories..." >> "$LOG_FILE"
    
    declare -a dirs_to_check=()
    
    # Collect all subdirectories from CACHE_DIRS
    for cache_dir_pattern in "${CACHE_DIRS[@]}"; do
        for item in $cache_dir_pattern; do
            if [ -d "$item" ]; then
                dirs_to_check+=("$item")
            fi
        done
    done

    # Create a temporary file to store directory sizes
    size_file=$(mktemp)

    # Calculate size for each directory and store in the temp file
    for dir in "${dirs_to_check[@]}"; do
        size=$(get_dir_size "$dir")
        echo "$size $dir" >> "$size_file"
    done

    # Sort directories by size (descending) and log them
    sort -rn "$size_file" | while read -r size dir; do
        echo "$(date): Directory '$dir' size: $size bytes" >> "$LOG_FILE"
        if [ "$size" -gt "$SIZE_THRESHOLD" ]; then
            echo "$(date): Cache '$dir' is over threshold ($size > $SIZE_THRESHOLD bytes)." >> "$LOG_FILE"
            echo "$(date): Clearing '$dir'..." >> "$LOG_FILE"
            
            # --- Deletion is now active ---
            rm -rf "$dir"
            
            echo "$(date): Cleared '$dir'." >> "$LOG_FILE"
        fi
    done

    # Clean up the temporary file
    rm -f "$size_file"

    echo "$(date): Check complete. Next check in $CHECK_INTERVAL seconds." >> "$LOG_FILE"
    sleep $CHECK_INTERVAL
done
