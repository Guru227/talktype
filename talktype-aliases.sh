#!/bin/bash
# TalkType shell aliases and functions
# Source this file in your ~/.bashrc or run: source talktype-aliases.sh

# View logs in real-time
alias talktype-logs='journalctl --user -u talktype -f'

# Check daemon status
alias talktype-status='systemctl --user status talktype'

# Restart the daemon
alias talktype-restart='systemctl --user restart talktype'

# Stop the daemon
alias talktype-stop='systemctl --user stop talktype'

# Start the daemon
alias talktype-start='systemctl --user start talktype'

# Quick test - shows last 20 log lines
alias talktype-test='journalctl --user -u talktype -n 20 --no-pager'

# Show recent transcriptions
alias talktype-recent='journalctl --user -u talktype --since "10 minutes ago" | grep "✅"'

# Function to check if daemon is working
talktype-check() {
    echo "🔍 Checking TalkType daemon..."
    echo ""

    if systemctl --user is-active talktype &>/dev/null; then
        echo "✅ Daemon is running"

        # Check recent activity
        local recent_logs=$(journalctl --user -u talktype --since "1 minute ago" --no-pager 2>/dev/null)
        if [ -n "$recent_logs" ]; then
            echo "✅ Recent activity detected"
        else
            echo "⚠️  No recent activity (try pressing your hotkey)"
        fi

        # Show last transcription
        local last_transcription=$(journalctl --user -u talktype --no-pager | grep "✅" | tail -1)
        if [ -n "$last_transcription" ]; then
            echo ""
            echo "Last transcription:"
            echo "$last_transcription"
        fi
    else
        echo "❌ Daemon is not running"
        echo ""
        echo "Start it with: talktype-start"
    fi
}

# Function to show help
talktype-help() {
    cat << 'EOF'
TalkType Commands:

  talktype-logs      View logs in real-time (Ctrl+C to exit)
  talktype-status    Check if daemon is running
  talktype-restart   Restart the daemon
  talktype-start     Start the daemon
  talktype-stop      Stop the daemon
  talktype-test      Show last 20 log entries
  talktype-recent    Show recent transcriptions
  talktype-check     Quick health check
  talktype-help      Show this help message

Usage:
  1. Press your hotkey (e.g., Ctrl+Space)
  2. Speak clearly and loudly for 2+ seconds
  3. Press hotkey again to stop
  4. Wait for "📋 Copied to clipboard!" message
  5. Paste with Ctrl+V (or Ctrl+Shift+V in terminal)

Troubleshooting:
  - Check audio levels: Audio energy must be > 0.005
  - View logs: talktype-logs
  - Test mic: cd ~/talktype && source venv/bin/activate && python test_mic.py

EOF
}

echo "✅ TalkType aliases loaded! Run 'talktype-help' for commands."
