#!/bin/bash
# TalkType Installation Script for Wayland/GNOME
# Ubuntu 24.04+ (GNOME Wayland)

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"

echo "=========================================="
echo "  TalkType Wayland/GNOME Installation"
echo "=========================================="
echo ""

# Check if running on Wayland
if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    echo "⚠️  Warning: You appear to be running X11, not Wayland."
    echo "This installation is optimized for Wayland/GNOME."
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 1: Check system dependencies
echo "Step 1: Checking system dependencies..."
MISSING_DEPS=()

for cmd in xdotool xclip pactl python3; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS+=($cmd)
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "Missing dependencies: ${MISSING_DEPS[@]}"
    echo "Installing..."
    sudo apt update
    sudo apt install -y xdotool xclip portaudio19-dev python3 python3-venv python3-pip
else
    echo "✓ All system dependencies installed"
fi

# Step 2: Add user to input group
echo ""
echo "Step 2: Adding user to 'input' group..."
if groups | grep -q '\binput\b'; then
    echo "✓ Already in 'input' group"
else
    sudo usermod -a -G input $USER
    echo "✓ Added to 'input' group"
    echo "⚠️  IMPORTANT: You must log out and log back in (or reboot) for this to take effect!"
    NEED_RELOGIN=true
fi

# Step 3: Create virtual environment
echo ""
echo "Step 3: Setting up Python virtual environment..."
if [ -d "$VENV_DIR" ]; then
    echo "✓ Virtual environment already exists"
else
    python3 -m venv "$VENV_DIR"
    echo "✓ Virtual environment created"
fi

# Step 4: Install Python dependencies
echo ""
echo "Step 4: Installing Python dependencies..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$SCRIPT_DIR/requirements.txt"
echo "✓ Python dependencies installed"

# Step 5: Test microphone
echo ""
echo "Step 5: Testing microphone..."
read -p "Run microphone test? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    python "$SCRIPT_DIR/test_mic.py"
fi

# Step 6: Install systemd service
echo ""
echo "Step 6: Installing systemd service..."
mkdir -p ~/.config/systemd/user
cp "$SCRIPT_DIR/talktype.service" ~/.config/systemd/user/
systemctl --user daemon-reload
echo "✓ Systemd service installed"

# Step 7: Set up aliases
echo ""
echo "Step 7: Setting up bash aliases..."
if grep -q "source.*talktype-aliases.sh" ~/.bashrc; then
    echo "✓ Aliases already sourced in ~/.bashrc"
else
    echo "" >> ~/.bashrc
    echo "# Source TalkType aliases" >> ~/.bashrc
    echo "[ -f \"$SCRIPT_DIR/talktype-aliases.sh\" ] && source \"$SCRIPT_DIR/talktype-aliases.sh\"" >> ~/.bashrc
    echo "✓ Aliases added to ~/.bashrc"
    echo "  Run 'source ~/.bashrc' to use them immediately"
fi

# Step 8: Instructions for GNOME keyboard shortcut
echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo ""
echo "1. If you were added to the 'input' group, LOG OUT and LOG BACK IN (or reboot)"
echo ""
echo "2. Set up GNOME keyboard shortcut:"
echo "   - Open Settings → Keyboard → Keyboard Shortcuts"
echo "   - Add Custom Shortcut:"
echo "     Name: TalkType Toggle"
echo "     Command: $VENV_DIR/bin/python $SCRIPT_DIR/talktype_toggle.py"
echo "     Shortcut: Press Ctrl+Space"
echo ""
echo "3. Enable and start the daemon:"
echo "   systemctl --user enable talktype"
echo "   systemctl --user start talktype"
echo ""
echo "4. Test it:"
echo "   - Press Ctrl+Space"
echo "   - Speak for 2+ seconds"
echo "   - Press Ctrl+Space again"
echo "   - Text is copied to clipboard!"
echo "   - Paste with Ctrl+V (or Ctrl+Shift+V in terminal)"
echo ""
echo "5. Use these aliases to manage the daemon:"
echo "   - talktype-logs    (view logs in real-time)"
echo "   - talktype-status  (check if running)"
echo "   - talktype-restart (restart daemon)"
echo ""
echo "For detailed documentation, see WAYLAND_SETUP.md"
echo ""

if [ "$NEED_RELOGIN" = true ]; then
    echo "⚠️  IMPORTANT: LOG OUT AND LOG BACK IN NOW!"
    echo ""
fi
