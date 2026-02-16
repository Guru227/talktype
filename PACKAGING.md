# TalkType Debian Package Building

## Prerequisites

Install build tools:

```bash
sudo apt install build-essential debhelper dh-python devscripts
```

## Building the Package

### Quick Build

```bash
./build-deb.sh
```

This will create `talktype_0.1.0_all.deb` in the parent directory.

### Manual Build

```bash
dpkg-buildpackage -us -uc -b
```

## Installing the Package

```bash
sudo apt install ../talktype_0.1.0_all.deb
```

Or with automatic dependency installation:

```bash
sudo apt install -f ../talktype_0.1.0_all.deb
```

## Package Structure

```
/opt/talktype/                  - Main installation directory
  ├── venv/                     - Python virtual environment (created on install)
  ├── talktype_daemon.py        - Main daemon
  ├── talktype_toggle.py        - Toggle script
  ├── talktype                  - CLI command
  ├── requirements.txt          - Python dependencies
  └── ...                       - Other files

/usr/local/bin/talktype         - Symlink to /opt/talktype/talktype
```

## Post-Installation Steps

The package will display these instructions after installation:

1. Add yourself to the `input` group
2. Set up GNOME keyboard shortcut
3. Install systemd service
4. Load bash aliases

Or run the automated setup:

```bash
talktype install
```

## Uninstalling

### Remove but keep configuration:

```bash
sudo apt remove talktype
```

### Complete removal (purge):

```bash
sudo apt purge talktype
```

This removes:
- `/opt/talktype/` directory
- Virtual environment
- User systemd services

**Note:** User-specific bashrc modifications are NOT removed.

## Version Management

Version is defined in `debian/changelog`. To create a new version:

```bash
# Edit debian/changelog
dch -v 0.2.0 "New features..."

# Build new package
./build-deb.sh
```

## Testing the Package

```bash
# Install
sudo apt install ../talktype_0.1.0_all.deb

# Check installation
talktype check

# View logs
talktype logs

# Remove
sudo apt remove talktype
```

## Debian Package Files

| File | Purpose |
|------|---------|
| `debian/control` | Package metadata, dependencies |
| `debian/changelog` | Version history |
| `debian/rules` | Build instructions |
| `debian/compat` | Debhelper compatibility level (12) |
| `debian/postinst` | Post-installation script (setup venv, show instructions) |
| `debian/prerm` | Pre-removal script (stop daemon) |
| `debian/postrm` | Post-removal script (cleanup) |
| `debian/copyright` | License information |

## Troubleshooting

### Build fails with "debhelper not found"

```bash
sudo apt install debhelper
```

### Build fails with "dh-python not found"

```bash
sudo apt install dh-python
```

### Package won't install due to dependencies

```bash
sudo apt install -f
```

### Clean build artifacts

```bash
rm -rf debian/talktype
rm -f ../talktype_*
```

## Development vs Installed Version

### Installed version (from .deb):
- Location: `/opt/talktype/`
- Command: `/usr/local/bin/talktype`
- Service: `talktype.service`

### Development version (from source):
- Location: `~/talktype/`
- Command: `~/talktype/talktype`
- Service: `talktype-dev.service` (if you create one)

**Tip:** Disable one to avoid conflicts:

```bash
# Disable installed version
sudo systemctl --user disable talktype

# Use dev version
cd ~/talktype && ./talktype start
```

## Publishing

### To a PPA (Launchpad):

1. Sign up for Launchpad account
2. Create PPA
3. Build source package:
   ```bash
   dpkg-buildpackage -S -sa
   ```
4. Upload:
   ```bash
   dput ppa:your-username/your-ppa ../talktype_0.1.0_source.changes
   ```

### To GitHub Releases:

1. Build the package
2. Create a new release on GitHub
3. Attach the `.deb` file

Users can then download and install:

```bash
wget https://github.com/Guru227/talktype/releases/download/v0.1.0/talktype_0.1.0_all.deb
sudo apt install ./talktype_0.1.0_all.deb
```
