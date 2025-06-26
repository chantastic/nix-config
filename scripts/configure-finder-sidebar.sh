#!/bin/sh

echo "Configuring Finder sidebar with mysides..."

# Check if mysides is available
if ! command -v mysides >/dev/null 2>&1; then
    echo "Error: mysides is not installed or not in PATH. Please ensure it is installed via Nix (home.packages)."
    exit 1
fi

# Remove unwanted sidebar items
echo "Removing unwanted sidebar items..."
mysides remove Recents >/dev/null 2>&1
mysides remove Movies >/dev/null 2>&1
mysides remove Music >/dev/null 2>&1
mysides remove Pictures >/dev/null 2>&1

# Configure user-specific folders
echo "Configuring user folders..."

# Home directory
mysides remove chan >/dev/null 2>&1
mysides add chan file:///Users/chan/

# Documents
mysides remove Documents >/dev/null 2>&1
mysides add Documents file:///Users/chan/Documents/

# Downloads
mysides remove Downloads >/dev/null 2>&1
mysides add Downloads file:///Users/chan/Downloads/

# Desktop
mysides remove Desktop >/dev/null 2>&1
mysides add Desktop file:///Users/chan/Desktop/

# Applications
mysides remove Applications >/dev/null 2>&1
mysides add Applications file:///Applications/

echo "Finder sidebar configuration completed!"
echo "Restarting Finder to apply changes..."
killall Finder || true

echo "Finder sidebar configuration completed!"
echo "You may need to restart Finder for changes to take effect." 