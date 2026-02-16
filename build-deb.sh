#!/bin/bash
# Build TalkType .deb package

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        Building TalkType .deb package                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if required tools are installed
echo "Checking build dependencies..."
MISSING_DEPS=()

for cmd in dpkg-buildpackage debhelper dh-python; do
    if ! dpkg -l | grep -q "ii.*$(echo $cmd | cut -d- -f1)"; then
        MISSING_DEPS+=($cmd)
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "Missing build dependencies: ${MISSING_DEPS[@]}"
    echo ""
    echo "Install with:"
    echo "  sudo apt install build-essential debhelper dh-python devscripts"
    exit 1
fi

echo "✓ All build dependencies installed"
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf debian/talktype
rm -f ../talktype_*.deb
rm -f ../talktype_*.build*
rm -f ../talktype_*.changes
rm -f ../talktype_*.tar.*
rm -f ../talktype_*.dsc
echo "✓ Cleaned"
echo ""

# Build the package
echo "Building package..."
echo ""
dpkg-buildpackage -us -uc -b

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              Build Complete!                               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Find and display the built package
DEB_FILE=$(ls -t ../talktype_*.deb 2>/dev/null | head -1)

if [ -f "$DEB_FILE" ]; then
    echo "📦 Package created: $DEB_FILE"
    echo ""
    echo "Package info:"
    dpkg-deb -I "$DEB_FILE" | grep -E "Package:|Version:|Architecture:|Depends:"
    echo ""
    echo "Package size: $(du -h "$DEB_FILE" | cut -f1)"
    echo ""
    echo "To install:"
    echo "  sudo apt install $DEB_FILE"
    echo ""
    echo "To install and check:"
    echo "  sudo apt install $DEB_FILE && talktype check"
    echo ""
else
    echo "❌ Error: Package file not found!"
    exit 1
fi
