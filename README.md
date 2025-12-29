# Repo Content Explanation
## What
Monitors & clears cache files/directories when they reach a certain size.
## Why
To automatically manage cache size and free up disk space.
## How
Creates a daemon that checks cache directories every 5 minutes. If a directory exceeds 500MB, it will be logged. The actual deletion is disabled by default for safety.

# Relevant Commands
## Daemon Control
### Enable Daemon
######
    launchctl load ~/Library/LaunchAgents/com.user.cachecleaner.plist
### Disable Daemon
######
    launchctl unload ~/Library/LaunchAgents/com.user.cachecleaner.plist
## Check Working Script(s)
### Check If This Particular Daemon Is Active
######
    launchctl list | grep cachecleaner
### List All Active User Created Daemons
######
    launchctl list | sort -k3 | egrep -i --color "com.user|$"
## Get Ouput
######
    find ~/Code/Cache\ Cleaner/ -type f -name "*cache*.log" -exec bat {} \;

# The Contents Of com.user.cachecleaner.plist @ 2025-12-29
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
