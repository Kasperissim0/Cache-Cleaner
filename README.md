# Repo Content Explanation
## What
Monitors & clears cache files when they reach a certain size.
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
    launchctl list | egrep "PID\s*Status\s*Label" && launchctl list | grep --color=always cachecleaner
### List All Active User Created Daemons
######
    launchctl list | egrep "PID\s*Status\s*Label" && launchctl list | grep --color=always com.user
## Get Ouput
######
    cat "Documents/1_Projects/Cache Cleaner/cache_cleaner.log"

# The Contents Of com.user.cachecleaner.plist
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
        <string>/Users/kornienkodaniel/Documents/1_Projects/Cache Cleaner/Extra/Script & Spec/cache_cleaner.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/kornienkodaniel/Documents/1_Projects/Cache Cleaner/Extra/cache_cleaner_out.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/kornienkodaniel/Documents/1_Projects/Cache Cleaner/Extra/cache_cleaner_err.log</string>
</dict>
</plist>
```
