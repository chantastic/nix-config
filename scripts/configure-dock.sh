#!/bin/sh

echo "Configuring macOS dock with dockutil..."

# Check if dockutil is available
if ! command -v dockutil >/dev/null 2>&1; then
    echo "Error: dockutil is not installed or not in PATH. Please ensure it is installed via Nix (home.packages)."
    exit 1
fi

# Remove all items from dock
echo "Removing all items from dock..."
dockutil --remove all >/dev/null 2>&1

# Add applications to dock
echo "Adding applications to dock..."

# System applications
# dockutil --add /System/Applications/Messages.app >/dev/null 2>&1
# dockutil --add /System/Applications/Mail.app >/dev/null 2>&1
# dockutil --add /System/Applications/Safari.app >/dev/null 2>&1
# dockutil --add /System/Applications/Calendar.app >/dev/null 2>&1
# dockutil --add /System/Applications/Notes.app >/dev/null 2>&1

# User applications (adjust paths as needed)
# dockutil --add /Applications/Visual\ Studio\ Code.app >/dev/null 2>&1
# dockutil --add /Applications/iTerm.app >/dev/null 2>&1
# dockutil --add /Applications/Spotify.app >/dev/null 2>&1

# Add folders to dock (optional)
# dockutil --add ~/Downloads --view grid --display folder >/dev/null 2>&1
# dockutil --add ~/Documents --view grid --display folder >/dev/null 2>&1

echo "Dock configuration completed!"
echo "Restarting Dock to apply changes..."
killall Dock || true

echo "Dock configuration completed!"
echo "You may need to restart Dock for changes to take effect." 