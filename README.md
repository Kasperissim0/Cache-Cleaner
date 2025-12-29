# Cache Cleaner Daemon

## What
Automatically monitors and clears cache directories when they exceed configured size thresholds.

## Why
To free up disk space by removing accumulated cache files that can safely be regenerated. Prevents caches from consuming excessive storage over time.

## How
A macOS LaunchAgent daemon that:
- Runs continuously in the background
- Checks configured cache directories every 5 minutes
- Deletes cache contents when a directory exceeds its specific threshold
- Logs all operations with human-readable sizes and detailed file deletion records

## Features
- **Per-directory thresholds**: Different size limits for different caches (e.g., 750MB for general caches, 1GB for browser caches)
- **Detailed logging**: Records every file deleted with its size
- **Two-pass deletion**: Logs file sizes before deletion for accurate records
- **Permission-safe**: Skips directories that require elevated permissions

# Configuration

## Monitored Directories & Thresholds
Edit the `CACHE_CONFIGS` array in the script to customize:
```bash
declare -a CACHE_CONFIGS=(
    "750|$HOME/Library/Caches"
    "500|$HOME/Library/Application Support/obsidian/Code Cache"
    "1000|$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Service Worker/CacheStorage"
    "200|$HOME/Library/Caches/BraveSoftware/Brave-Browser/Default/Cache/Cache_Data"
    "200|$HOME/Library/Caches/BraveSoftware/Brave-Browser/Default/Code Cache"
    "300|$HOME/Library/Application Support/Code/Cache/Cache_Data"
)
```

Format: `"threshold_in_MB|/path/to/directory"`

## Check Interval
Default: 300 seconds (5 minutes)
```bash
CHECK_INTERVAL=300
```

# Relevant Commands

## Daemon Control

### Enable Daemon
```bash
launchctl load ~/Library/LaunchAgents/com.user.cachecleaner.plist
```

### Disable Daemon
```bash
launchctl unload ~/Library/LaunchAgents/com.user.cachecleaner.plist
```

### Restart Daemon (after config changes)
```bash
launchctl unload ~/Library/LaunchAgents/com.user.cachecleaner.plist && \
launchctl load ~/Library/LaunchAgents/com.user.cachecleaner.plist
```

## Status Checks

### Check If Daemon Is Running
```bash
launchctl list | grep cachecleaner
```

### List All User Daemons
```bash
launchctl list | sort -k3 | egrep -i --color "com.user|$"
```

## View Logs

### View All Logs
```bash
find ~/Code/Cache\ Cleaner/ -type f -name "*cache*.log" -exec bat {} \;
```

### View Main Activity Log
```bash
bat ~/Code/Cache\ Cleaner/cache_cleaner.log
```

### View Detailed Deletion Log
```bash
bat ~/Code/Cache\ Cleaner/Extra/cache_cleaner_out.log
```

### Tail Live Activity
```bash
tail -f ~/Code/Cache\ Cleaner/cache_cleaner.log
```

### Check Most Recent Activity
```bash
tail -n 50 ~/Code/Cache\ Cleaner/cache_cleaner.log
```

## Troubleshooting

### Check Error Log
```bash
bat ~/Code/Cache\ Cleaner/Extra/cache_cleaner_err.log
```

### Manual Test Run
```bash
~/Code/Cache\ Cleaner/Extra/Script\ \&\ Spec/cache_cleaner.sh
```
Press `Control + Z` to stop after testing.

# Log Format Examples

## Main Activity Log (`cache_cleaner.log`)
```
Mon Dec 29 13:26:08 CET 2025: ════════════════════════════════════════════════
Mon Dec 29 13:26:08 CET 2025: Cache cleaner daemon started
Mon Dec 29 13:26:08 CET 2025: Check interval: 300s (5min)
Mon Dec 29 13:26:08 CET 2025: Configured directories:
Mon Dec 29 13:26:08 CET 2025:   - 750MB: /Users/kasperissim0/Library/Caches
Mon Dec 29 13:26:08 CET 2025:   - 500MB: /Users/kasperissim0/Library/Application Support/obsidian/Code Cache
Mon Dec 29 13:26:08 CET 2025: ════════════════════════════════════════════════
Mon Dec 29 13:26:08 CET 2025: ┌─ Starting cache check...
Mon Dec 29 13:26:08 CET 2025: │  ✓ OK: 192.00KB / 750.00MB - /Users/kasperissim0/Library/Caches
Mon Dec 29 13:26:08 CET 2025: │  ⚠ OVER THRESHOLD: 1.30GB > 1.00GB
Mon Dec 29 13:26:08 CET 2025: │  📁 Path: /Users/kasperissim0/Library/Application Support/BraveSoftware/.../CacheStorage
Mon Dec 29 13:26:08 CET 2025: │  ✓ Cleared 1.30GB from '...'
Mon Dec 29 13:26:08 CET 2025: └─ Check complete
Mon Dec 29 13:26:08 CET 2025:    Directories checked: 6
Mon Dec 29 13:26:08 CET 2025:    Directories cleared: 1
Mon Dec 29 13:26:08 CET 2025:    Total space freed: 1.30GB
```

## Detailed Deletion Log (`cache_cleaner_out.log`)
```
Mon Dec 29 13:26:08 CET 2025: Deleting files from: /path/to/cache
  1.23MB: /path/to/cache/file1
  456.78KB: /path/to/cache/file2
  2.34GB: /path/to/cache/bigfile
```

# Files Structure
```
~/Code/Cache Cleaner/
├── cache_cleaner.log              # Main activity log
├── Extra/
│   ├── cache_cleaner_out.log      # Detailed deletion log
│   ├── cache_cleaner_err.log      # Error log
│   └── Script & Spec/
│       └── cache_cleaner.sh       # Main daemon script
```

# LaunchAgent Configuration @ 2025-12-29

Location: `~/Library/LaunchAgents/com.user.cachecleaner.plist`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.cachecleaner</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/kasperissim0/Code/Cache Cleaner/Extra/Script & Spec/cache_cleaner.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/kasperissim0/Code/Cache Cleaner/Extra/cache_cleaner_out.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/kasperissim0/Code/Cache Cleaner/Extra/cache_cleaner_err.log</string>
</dict>
</plist>
```

# Safety Notes

- **Caches are safe to delete**: Applications regenerate cache files as needed
- **Browser caches**: May cause temporary slowdown as browser rebuilds cache
- **Full Disk Access**: May be required for some system cache directories (grant to `/bin/bash` in System Settings → Privacy & Security)
- **Backup important data**: This script only targets cache directories, but always maintain backups

# Performance

- **Negligible impact**: Checking 750MB takes ~2-5 seconds every 5 minutes
- **Two-pass approach**: Logs file sizes before deletion for accurate records
- **Non-blocking**: Runs in background without affecting system performance