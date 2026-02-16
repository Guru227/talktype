#!/usr/bin/env python3
"""
TalkType toggle for GNOME Wayland
Press once to start recording, press again to stop and transcribe
"""
import os
import signal
import sys
from pathlib import Path

STATE_FILE = Path.home() / ".cache" / "talktype_state.pid"
STATE_FILE.parent.mkdir(exist_ok=True)

def send_signal():
    """Send SIGUSR1 to the talktype daemon to toggle recording"""
    daemon_pid_file = Path.home() / ".cache" / "talktype_daemon.pid"

    if not daemon_pid_file.exists():
        print("TalkType daemon not running")
        print("Start it with: python talktype_daemon.py")
        sys.exit(1)

    pid = int(daemon_pid_file.read_text().strip())

    try:
        os.kill(pid, signal.SIGUSR1)
        print(f"Toggled recording (sent signal to PID {pid})")
    except ProcessLookupError:
        print("Daemon PID file exists but process not found")
        daemon_pid_file.unlink()
        sys.exit(1)

if __name__ == "__main__":
    send_signal()
