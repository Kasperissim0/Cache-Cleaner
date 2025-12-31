#!/bin/bash
set -e

# Cache Cleaner Daemon
SAVE_PATH="/Users/kasperissim0/Code/Projects/Cache Cleaner"
LOG_FILE="$SAVE_PATH/cache_cleaner.log"
OUT_FILE="$SAVE_PATH/Extra/cache_cleaner_out.log"
CHECK_INTERVAL=300 # Check every 5 minutes

# Cache directories with their thresholds (in MB for readability)
# Format: "threshold_mb|directory_path"
declare -a CACHE_CONFIGS=(
    "750|$HOME/Library/Caches"
    "500|$HOME/Library/Application Support/obsidian/Code Cache"
    "850|$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Service Worker/CacheStorage"
    "200|$HOME/Library/Caches/BraveSoftware/Brave-Browser/Default/Cache/Cache_Data"
    "200|$HOME/Library/Caches/BraveSoftware/Brave-Browser/Default/Code Cache"
    "300|$HOME/Library/Application Support/Code/Cache/Cache_Data"
    "300|$HOME/Library/Containers/com.apple.mediaanalysisd/Data/Library/Caches"
    "100|$HOME/Library/Application Support/obsidian/Service Worker/CacheStorage"
)

# Function to convert bytes to human readable format
bytes_to_human() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        printf "%.2fKB" "$(echo "scale=2; $bytes/1024" | bc)"
    elif [ $bytes -lt 1073741824 ]; then
        printf "%.2fMB" "$(echo "scale=2; $bytes/1048576" | bc)"
    else
        printf "%.2fGB" "$(echo "scale=2; $bytes/1073741824" | bc)"
    fi
}

# Function to convert MB to bytes
mb_to_bytes() {
    echo $(($1 * 1048576))
}

# Function to get directory size in bytes (suppresses permission errors)
get_dir_size() {
    local dir="$1"
    local size_in_kb=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
    if [ -z "$size_in_kb" ]; then
        echo "0"
    else
        echo $(($size_in_kb * 1024))
    fi
}

# Function to clear directory contents
clear_cache_dir() {
    local dir="$1"
    local size_before=$2
    
    echo "$(date): Deleting files from: $dir" >> "$OUT_FILE"
    
    # First pass: log all files with sizes
    find "$dir" -mindepth 1 -type f 2>/dev/null | while read -r file; do
        local fsize=$(stat -f%z "$file" 2>/dev/null || echo 0)
        echo "  $(bytes_to_human $fsize): $file" >> "$OUT_FILE"
    done
    
    # Second pass: delete everything
    find "$dir" -mindepth 1 -delete 2>/dev/null
    
    local size_after=$(get_dir_size "$dir")
    local freed=$((size_before - size_after))
    
    echo "$(date): ✓ Cleared $(bytes_to_human $freed) from '$dir'" >> "$LOG_FILE"
    echo "" >> "$OUT_FILE"
}

echo "$(date): ════════════════════════════════════════════════" >> "$LOG_FILE"
echo "$(date): Cache Cleaner daemon started" >> "$LOG_FILE"
echo "$(date): Check interval: ${CHECK_INTERVAL}s ($(($CHECK_INTERVAL/60))min)" >> "$LOG_FILE"
echo "$(date): Configured directories:" >> "$LOG_FILE"
for config in "${CACHE_CONFIGS[@]}"; do
    threshold_mb="${config%%|*}"
    dir="${config##*|}"
    echo "$(date):   - ${threshold_mb}MB: $dir" >> "$LOG_FILE"
done
echo "$(date): ════════════════════════════════════════════════" >> "$LOG_FILE"

while true; do
    echo "$(date): ┌─ Starting cache check..." >> "$LOG_FILE"
    
    total_checked=0
    total_cleared=0
    total_freed=0
    
    for config in "${CACHE_CONFIGS[@]}"; do
        # Parse config
        threshold_mb="${config%%|*}"
        dir="${config##*|}"
        threshold_bytes=$(mb_to_bytes $threshold_mb)
        
        if [ -d "$dir" ]; then
            size=$(get_dir_size "$dir")
            size_human=$(bytes_to_human $size)
            threshold_human=$(bytes_to_human $threshold_bytes)
            
            total_checked=$((total_checked + 1))
            
            if [ "$size" -gt "$threshold_bytes" ]; then
                echo "$(date): │  ⚠ OVER THRESHOLD: $size_human > $threshold_human" >> "$LOG_FILE"
                echo "$(date): │  📁 Path: $dir" >> "$LOG_FILE"
                
                clear_cache_dir "$dir" "$size"
                total_cleared=$((total_cleared + 1))
                total_freed=$((total_freed + size))
            else
                echo "$(date): │  ✓ OK: $size_human / $threshold_human - $dir" >> "$LOG_FILE"
            fi
        else
            echo "$(date): │  ⊘ SKIP: Directory not found - $dir" >> "$LOG_FILE"
        fi
    done
    
    echo "$(date): └─ Check complete" >> "$LOG_FILE"
    echo "$(date):    Directories checked: $total_checked" >> "$LOG_FILE"
    echo "$(date):    Directories cleared: $total_cleared" >> "$LOG_FILE"
    if [ $total_freed -gt 0 ]; then
        echo "$(date):    Total space freed: $(bytes_to_human $total_freed)" >> "$LOG_FILE"
    fi
    echo "$(date):    Next check in ${CHECK_INTERVAL}s" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    sleep $CHECK_INTERVAL
done