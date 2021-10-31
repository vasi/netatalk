#!/bin/zsh

# Script for compiling Netatalk binaries on macOS

# Set the path for the executable to current folder
cd "$(dirname $0)"

# Global variables
local cores
cores=$(getconf _NPROCESSORS_ONLN)

# zsh options
set -e # errexit

# Update git repo
git pull

# Cleanup
make distclean -j "$cores"
if [ -d "autom4te.cache" ]; then rm -Rf autom4te.cache; fi

# Build and install
./bootstrap
make -j "$cores"
make html -j "$cores"
make install -j "$cores"

# Install startup daemon
sudo cp com.netatalk.daemon.plist /Library/LaunchDaemons
sudo launchctl load -w /Library/LaunchDaemons/com.netatalk.daemon.plist



# Exit gracefully
osascript -e 'tell application "Terminal" to close (every window whose name contains ".command")' &
exit
