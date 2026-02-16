#!/usr/bin/env python3
"""Simple test to see if pynput can capture keyboard events"""

from pynput import keyboard

def on_press(key):
    try:
        print(f"Key pressed: {key}")
    except Exception as e:
        print(f"Error: {e}")

def on_release(key):
    print(f"Key released: {key}")
    if key == keyboard.Key.esc:
        print("ESC pressed - exiting")
        return False

print("Testing keyboard capture...")
print("Press any keys (including Ctrl, Space, etc.)")
print("Press ESC to exit")
print()

with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
    listener.join()
