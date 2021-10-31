#!/bin/zsh

# Script for compiling Netatalk binaries on macOS

# Set the path for the executable to current folder
cd "$(dirname $0)"

# Correct permissions for installation folders on Apple Silicon (Homebrew does this on Intel)
arch=$(uname -m)
if [[ $arch == arm64 ]]; then
    sudo chown -R $(whoami) /usr/local/*
    echo -e "\e[1;91mCorrecting installation folder permissions for Apple Silicon\e[0m"
fi

# Global variables
local cores
cores=$(getconf _NPROCESSORS_ONLN)

# zsh options
set -e # errexit

# Update git repo
git pull

# Build and install
./bootstrap
make -j "$cores"
make html -j "$cores"
make install -j "$cores"

# Install startup daemon
sudo cp com.netatalk.daemon.plist /Library/LaunchDaemons
sudo launchctl load -w /Library/LaunchDaemons/com.netatalk.daemon.plist

# Cleanup
make distclean -j "$cores"
if [ -d "autom4te.cache" ]; then rm -Rf autom4te.cache; fi

# Exit gracefully
osascript -e 'tell application "Terminal" to close (every window whose name contains ".command")' &
exit
