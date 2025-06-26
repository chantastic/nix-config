#!/bin/sh

echo "Setting macOS preferences…"

# Global Domain Settings
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain com.apple.trackpad.scaling -int 2.5

# Finder Settings
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -int 0
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -int 1
defaults write com.apple.finder ShowRemovableMediaOnDesktop -int 1
defaults write com.apple.finder ShowMountedServersOnDesktop -int 0
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file:///Users/chan/"

# Dock Settings
defaults write com.apple.dock show-recents -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0

# Trackpad Settings
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Time Machine Settings
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# TextEdit Settings
defaults write com.apple.TextEdit RichText -int 0
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Software Update Settings
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Restart services after applying changes
killall Dock || true
killall Finder || true

echo "macOS settings applied successfully!" 