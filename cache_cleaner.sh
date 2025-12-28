#!/bin/bash

# Log file paths
LOG_FILE="logs/cache_cleaner.log"
OUT_FILE="logs/cache_cleaner_out.log"
ERR_FILE="logs/cache_cleaner_err.log"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# --- Script Start ---
log_message "Cache Cleaner script started."

# --- Cache Directories ---
USER_CACHE_DIR="$HOME/Library/Caches"
SYSTEM_CACHE_DIR="/Library/Caches"

# --- Listing Cache Files ---
log_message "Listing files in User Cache: $USER_CACHE_DIR"
ls -la "$USER_CACHE_DIR" >> "$OUT_FILE" 2>> "$ERR_FILE"

log_message "Listing files in System Cache: $SYSTEM_CACHE_DIR"
ls -la "$SYSTEM_CACHE_DIR" >> "$OUT_FILE" 2>> "$ERR_FILE"

# --- Deleting Cache Files ---
read -p "Are you sure you want to delete all cache files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    log_message "User confirmed deletion of cache files."

    log_message "Deleting files from User Cache: $USER_CACHE_DIR"
    rm -rfv "$USER_CACHE_DIR"/* >> "$OUT_FILE" 2>> "$ERR_FILE"

    log_message "Deleting files from System Cache: $SYSTEM_CACHE_DIR"
    rm -rfv "$SYSTEM_CACHE_DIR"/* >> "$OUT_FILE" 2>> "$ERR_FILE"

    log_message "Cache files deleted."
else
    log_message "User cancelled deletion of cache files."
fi

# --- Script End ---
log_message "Cache Cleaner script finished."