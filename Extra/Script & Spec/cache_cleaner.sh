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
    for cache_dir in "${CACHE_DIRS[@]}"; do
        # Use a glob to iterate through subdirectories
        for item in $cache_dir; do
            if [ -d "$item" ]; then # Ensure it's a directory
                CURRENT_SIZE=$(get_dir_size "$item")
                
                if [ "$CURRENT_SIZE" -gt "$SIZE_THRESHOLD" ]; then
                    echo "$(date): Cache '$item' is over threshold ($CURRENT_SIZE > $SIZE_THRESHOLD bytes)." >> "$LOG_FILE"
                    echo "$(date): Clearing '$item'..." >> "$LOG_FILE"
                    
                    # --- UNCOMMENT THE LINE BELOW TO ENABLE DELETION ---
                    # rm -rf "$item"
                    
                    echo "$(date): Cleared '$item' (SIMULATED)." >> "$LOG_FILE"
                fi
            fi
        done
    done
    
    sleep $CHECK_INTERVAL
done
