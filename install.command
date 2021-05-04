#!/bin/zsh

# Script for compiling Netatalk binaries on macOS

# Go to the Netatalk3 root directory
cd "$(dirname $0)"

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
sudo make install -j "$cores"

# Cleanup
make clean -j "$cores"
if [ -d "autom4te.cache" ]; then rm -Rf autom4te.cache; fi

# Exit gracefully
osascript -e 'tell application "Terminal" to close (every window whose name contains ".command")' &
exit
