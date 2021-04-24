# Netatalk for macOS
This is a fork of the 3.1 branch of the Netatalk repo on SourceForge. It has been patched for clean compilation and use on current versions of macOS only, and enables AFP2 file sharing between modern macs and classic macs running Mac OS 9.2.2.  It has been tested on macOS 11 (Big Sur) and 10.14 (Mojave). All code unused in macOS has been removed so this version of Netatalk will only run on modern Intel or Apple Silicon macs.
#### Credits:
-[The Netatalk open-source AFP filesever project](http://netatalk.sourceforge.net) -all developers past and present.

#### Quick how-to:

1. Install Homebrew:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

2. Install Apple's Command Line Tools for Xcode:

sudo xcode-select --install

3. Install Netatalk3's dependencies from Homebrew:

brew install automake autoconf libtool libgcrypt berkeley-db openssl libevent mysql pkg-config

4. Clone the repo:

git clone https://github.com/dgsga/Netatalk3.git

5. cd to the repo then:

./bootstrap

make

sudo make install

6. Set up your afp.conf file and specify AFP shares as needed
