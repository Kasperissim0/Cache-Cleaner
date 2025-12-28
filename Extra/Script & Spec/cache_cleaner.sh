#!/bin/bash
set -e

# Cache Cleaner Daemon
SAVE_PATH="/Users/kornienkodaniel/Documents/1_Projects/Cache Cleaner"
LOG_FILE="$SAVE_PATH/cache_cleaner.log"
OUT_FILE="$SAVE_PATH/cache_cleaner_out.log"
ERR_FILE="$SAVE_PATH/cache_cleaner_err.log"
CHECK_INTERVAL=300 # Check every 5 minutes
SIZE_THRESHOLD=500000000 # 500MB in bytes

# Cache directories to monitor - ADD MORE AS NEEDED
CACHE_DIRS=(
    "/Library/Caches"
    "$HOME/Library/Caches"
    "$HOME/Library/Application Support/Google/Chrome/Default/Application Cache"
    "$HOME/Library/Application Support/Code/User/workspaceStorage"
    "$HOME/Library/Application Support/discord/Cache"
    "$HOME/Library/Application Support/discord/Code Cache"
    # Add other cache directories here if you have them
)

# Function to get directory size in bytes (macOS compatible)
get_dir_size() {
    # Get size in kilobytes and multiply by 1024 for bytes
    size_in_kb=$(sudo du -sk "$1" | awk '{print $1}')
    echo $(($size_in_kb * 1024))
}

echo "$(date): Cache cleaner daemon started" >> "$LOG_FILE"

while true; do
    echo "$(date): Checking cache directories..." >> "$LOG_FILE"
    
    for dir_pattern in "${CACHE_DIRS[@]}"; do
        if [ -d "$dir_pattern" ]; then
            size=$(get_dir_size "$dir_pattern")
            echo "$(date): Directory '$dir_pattern' size: $size bytes" >> "$LOG_FILE"
            if [ "$size" -gt "$SIZE_THRESHOLD" ]; then
                echo "$(date): Cache '$dir_pattern' is over threshold ($size > $SIZE_THRESHOLD bytes)." >> "$LOG_FILE"
                echo "$(date): Clearing contents of '$dir_pattern'..." >> "$LOG_FILE"
                
                # --- Deletion is now active ---
                sudo find "$dir_pattern" -mindepth 1 -print -delete >> "$OUT_FILE" 2>> "$ERR_FILE"
                
                echo "$(date): Cleared contents of '$dir_pattern'." >> "$LOG_FILE"
            fi
        else
            for item in $dir_pattern/*; do
                if [ -d "$item" ]; then
                    size=$(get_dir_size "$item")
                    echo "$(date): Directory '$item' size: $size bytes" >> "$LOG_FILE"
                    if [ "$size" -gt "$SIZE_THRESHOLD" ]; then
                        echo "$(date): Cache '$item' is over threshold ($size > $SIZE_THRESHOLD bytes)." >> "$LOG_FILE"
                        echo "$(date): Clearing '$item'..." >> "$LOG_FILE"
                        
                        # --- Deletion is now active ---
                        sudo rm -rfv "$item" >> "$OUT_FILE" 2>> "$ERR_FILE"
                        
                        echo "$(date): Cleared '$item'." >> "$LOG_FILE"
                    fi
                fi
            done
        fi
    done

    echo "$(date): Check complete. Next check in $CHECK_INTERVAL seconds." >> "$LOG_FILE"
    sleep $CHECK_INTERVAL
done