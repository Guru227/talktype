#!/bin/bash
# TalkType startup script

cd /home/guru/talktype
source venv/bin/activate

# Force X11 mode for Wayland compatibility
export GDK_BACKEND=x11

# Start with the base model (good balance of speed and accuracy)
# You can change this to: tiny, base, small, medium, or large-v3
# Using Ctrl+Space as the hotkey
python talktype.py --model base --hotkey "ctrl+space"
