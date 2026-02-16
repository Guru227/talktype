# TalkType Setup for Wayland/GNOME

This guide covers setting up TalkType on **GNOME Wayland** (Ubuntu 24.04+).

## Why the Daemon Approach?

On Wayland, global hotkey capture is restricted for security. We use:
- **GNOME keyboard shortcuts** to trigger voice input
- **talktype_daemon.py** that runs in the background
- **Clipboard workflow** (Wayland doesn't support auto-paste)

## Prerequisites

### System Packages

```bash
sudo apt install -y xdotool xclip portaudio19-dev
```

### Add User to Input Group

Required for microphone access:

```bash
sudo usermod -a -G input $USER
```

**Important:** Log out and log back in (or reboot) for this to take effect.

Verify with:
```bash
groups | grep input
```

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/talktype.git
cd talktype
```

### 2. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. Test Microphone

```bash
python test_mic.py
```

Speak when prompted. You should see:
- Audio energy levels
- "✅ Audio captured successfully!"

If audio levels are low, adjust your microphone volume in Settings.

## Configuration

### Set Up GNOME Keyboard Shortcut

1. Open **Settings** → **Keyboard** → **Keyboard Shortcuts**
2. Scroll to **Custom Shortcuts**
3. Click **"+"** to add new shortcut:
   - **Name:** TalkType Toggle
   - **Command:** `/home/YOUR_USERNAME/talktype/venv/bin/python /home/YOUR_USERNAME/talktype/talktype_toggle.py`
   - **Shortcut:** Press **Ctrl+Space** (or your preferred key combo)

### Set Up Auto-Start (systemd)

Copy the service file:

```bash
mkdir -p ~/.config/systemd/user
cp talktype.service ~/.config/systemd/user/
```

Edit the service file to update paths if needed:

```bash
nano ~/.config/systemd/user/talktype.service
```

Enable and start:

```bash
systemctl --user daemon-reload
systemctl --user enable talktype
systemctl --user start talktype
```

Check status:

```bash
systemctl --user status talktype
```

View logs:

```bash
journalctl --user -u talktype -f
```

### Convenient Aliases (Optional but Recommended)

Add these aliases to your `~/.bashrc` for easy daemon management:

```bash
# TalkType aliases
alias talktype-logs='journalctl --user -u talktype -f'
alias talktype-status='systemctl --user status talktype'
alias talktype-restart='systemctl --user restart talktype'
alias talktype-stop='systemctl --user stop talktype'
alias talktype-start='systemctl --user start talktype'
```

Then reload your bashrc:

```bash
source ~/.bashrc
```

Now you can simply run:
- `talktype-logs` - Follow logs in real-time
- `talktype-status` - Check if daemon is running
- `talktype-restart` - Restart the daemon
- `talktype-stop` - Stop the daemon
- `talktype-start` - Start the daemon

## Usage

### Voice Input Workflow

1. **Press Ctrl+Space** (or your chosen hotkey)
   - You'll hear a high beep
   - Daemon shows: `🎤 RECORDING...`

2. **Speak clearly** for 2+ seconds

3. **Press Ctrl+Space again**
   - You'll hear a mid beep
   - Daemon shows: `⏳ Transcribing...`
   - Then: `✅ [your transcribed text]`
   - And: `📋 Copied to clipboard!`

4. **Paste the text:**
   - **Terminal:** Press `Ctrl+Shift+V`
   - **Browser/Editor:** Press `Ctrl+V`

### Tips for Best Results

- **Speak loudly and clearly** - the microphone needs good audio levels
- **Speak for at least 2 seconds** - very short clips may be ignored
- **Check audio energy** in logs - should be > 0.005
- **Adjust mic volume** in Settings if energy is consistently low

## Files

### Core Files

- **talktype_daemon.py** - Background service for Wayland
- **talktype_toggle.py** - Script called by GNOME keyboard shortcut
- **talktype.service** - systemd service file
- **requirements.txt** - Python dependencies

### Test Files

- **test_mic.py** - Test microphone capture and audio levels
- **test_keyboard.py** - Test keyboard event capture (legacy)

### Original Files

- **talktype.py** - Original X11 version (use on X11 systems)
- **whisper_server.py** - Optional API server mode
- **start_talktype.sh** - Legacy startup script

## Troubleshooting

### No speech detected

**Check audio levels:**
```bash
python test_mic.py
```

If RMS energy < 0.005, increase microphone volume:
- Settings → Sound → Input → Microphone volume

### Keyboard shortcut not working

**Check GNOME shortcut setup:**
```bash
gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings
```

**Verify daemon is running:**
```bash
systemctl --user status talktype
journalctl --user -u talktype -n 20
```

### Transcription slow

The default model is `tiny` for speed. For better accuracy, edit `talktype_daemon.py`:

```python
MODEL = "base"  # or "small", "medium"
```

Larger models need more RAM and take longer.

## Model Sizes

| Model | Size | Speed | Accuracy | RAM |
|-------|------|-------|----------|-----|
| tiny | 75MB | Fastest | Good | ~1GB |
| base | 150MB | Fast | Better | ~1GB |
| small | 500MB | Medium | Great | ~2GB |
| medium | 1.5GB | Slow | Excellent | ~5GB |

## Wayland Limitations

Due to Wayland's security model:
- ❌ **Auto-paste doesn't work** - use clipboard workflow
- ❌ **Global hotkey capture doesn't work** - use GNOME shortcuts
- ✅ **Transcription works perfectly**
- ✅ **Clipboard copy works perfectly**

This is not a limitation of TalkType but a design choice in Wayland for security.

## Uninstallation

```bash
# Stop and disable service
systemctl --user stop talktype
systemctl --user disable talktype

# Remove files
rm -rf ~/talktype
rm ~/.config/systemd/user/talktype.service
systemctl --user daemon-reload

# Remove GNOME keyboard shortcut in Settings
```

## Credits

- Original TalkType by [lmacan1](https://github.com/lmacan1/talktype)
- Wayland/GNOME modifications for clipboard workflow
- Uses [faster-whisper](https://github.com/SYSTRAN/faster-whisper) for transcription
