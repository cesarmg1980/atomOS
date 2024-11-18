#!/bin/bash

# This script will build a cross-compiler for i686-elf on macOS.
# Warning: this script will only work on macOS. If you are using Linux, you will need to modify the script accordingly.
echo -e "${YELLOW}Warning${NC}: this script will only work on macOS. If you are using Linux, you will need to modify the script accordingly."
echo -e "Press any key to continue or Ctrl+C to exit."
read -n 1 -s

# Exit immediately if a command exits with a non-zero status
set -e

# Setting Debugging mode, uncomment to enable
# set -x

# Define color codes and symbols
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No color
CHECKMARK="\xE2\x9C\x94"
CROSS="\xE2\x9C\x97"

# Setting up Environment Variables, Dependencies and other variables
echo "Setting up environment variables PREFIX, TARGET, and PATH..."
export TARGET=i686-elf
export PREFIX="$HOME/cross-$TARGET"
export PATH="$PREFIX/bin:$PATH"

# Define the required dependencies
DEPENDENCIES=("make" "bison" "flex" "gmp" "libmpc" "mpfr" "texinfo" "isl")

# Define the Compoents Version, Urls and other stuff
# Note: Add any new components's Url, Version and related stuff here!

# Homebrew URL
HOMEBREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Binutils
BINUTILS_URL="https://ftp.gnu.org/gnu/binutils"
BINUTILS_VERSION_TAR="binutils-2.43.tar.xz"
BINUTILS_VERSION="binutils-2.43"

# GDB
GDB_URL="https://ftp.gnu.org/gnu/gdb"
GDB_VERSION_TAR="gdb-15.2.tar.gz"
GDB_VERSION="gdb-15.2"

# GCC
GCC_VERSION_URL="https://ftp.gnu.org/gnu/gcc"
GCC_VERSION_TAR="gcc-13.2.0.tar.xz"
GCC_VERSION="gcc-13.2.0"

SOURCES_PATH="$HOME/sources"

# Helper functions section
check_brew_installed() {
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL $HOMEBREW_URL)"
        echo -e "${GREEN}${CHECKMARK}${NC} Homebrew installed successfully."
    else
        echo -e "${GREEN}${CHECKMARK}${NC} Homebrew is already installed."
    fi
}

check_dependecies_installed() {
    for dep in "$DEPENDENCIES"; do
        if ! brew list "$dep" &>/dev/null; then
            echo "Dependency $dep is not installed. Installing..."
            brew install "$dep"
            echo -e "${GREEN}${CHECKMARK}${NC} Dependency $dep installed successfully."
        else
            echo -e "${GREEN}${CHECKMARK}${NC} Dependency $dep is already installed."
        fi
    done
}

_run_make_for_component() {
    # Receives a command or a list of commands to run i.e make && make install
    local MAKE_COMMAND=$1
    echo "Running make command..."
    $(MAKE_COMMAND)
}

install_component() {
    local CROSS_COMPONENT=$1
    local COMPONENT_VERSION=$2
    local COMPONENT_URL=$3
    local COMPONENT_VERSION_TAR=$4
    local COMPONENT_BUILD_DIR=$5
    local COMPONENT_CONFIGURE_OPTIONS=$6
    local MAKE_COMMAND=$7

    echo "Checking if $CROSS_COMPONENT is installed..."
    cd $SOURCES_PATH
    if ! command -v "$CROSS_COMPONENT" &> /dev/null; then
        echo "$CROSS_COMPONENT is not installed."
        echo "Checking if $COMPONENT_VERSION folder exists..."
        if [ -d "$COMPONENT_VERSION" ]; then
            echo "$COMPONENT_VERSION folder exists. Skipping download, proceeding to installation..."
        else
            echo "$COMPONENT_VERSION folder does not exist. Downloading..."
            curl -O $COMPONENT_URL/$COMPONENT_VERSION_TAR
            echo -e "${GREEN}${CHECKMARK}${NC} $COMPONENT_VERSION_TAR downloaded successfully."
            echo "Extracting $COMPONENT_VERSION_TAR..."
            tar -xf $COMPONENT_VERSION_TAR
            echo -e "${GREEN}${CHECKMARK}${NC} $COMPONENT_VERSION_TAR extracted successfully."
            echo "Removing $COMPONENT_VERSION_TAR..."
            rm -r $COMPONENT_VERSION_TAR
            echo -e "${GREEN}${CHECKMARK}${NC} $COMPONENT_VERSION_TAR removed successfully."
        fi  
        mkdir -p $COMPONENT_BUILD_DIR
        cd $COMPONENT_BUILD_DIR
        ../$COMPONENT_VERSION/configure $COMPONENT_CONFIGURE_OPTIONS
        _run_make_for_component $MAKE_COMMAND
        echo -e "${GREEN}${CHECKMARK}${NC} $BINUTILS_VERSION installation completed."
    else
        echo -e "${GREEN}${CHECKMARK}${NC} $BINUTILS_VERSION is already installed."
    fi
}

verify_installation() {
    local COMPONENT=$1
    echo "Verifying installation..."
    if $COMPONENT --version > /dev/null 2>&1; then
        echo -e "${GREEN}${CHECKMARK}${NC} $COMPONENT verification successful."
    else
        echo -e "${RED}${CROSS}${NC} $COMPONENT verification failed, please check the installation."
    fi
}
# End of Helper functions section

# Main script section

# Checking Brew and Dependencies
check_brew_installed

# Checking Dependencies
check_dependecies_installed

# Creating Directories
echo "Creating directories for sources: $SOURCES_PATH and crosscompiler: $PREFIX"
mkdir -p "$PREFIX"
mkdir -p "$SOURCES_PATH"
echo -e "${GREEN}${CHECKMARK}${NC} Directories for sources and crosscompiler created successfully."

# Component Installation Section
# Note: Install any new components here below using the install_component function

# Specify the commands to be run that will allow to know if it's already installed using the pattern $TARGET-<executable>
CROSS_BINUTILS="$TARGET-as"
CROSS_GCC="$TARGET-gcc"
CROSS_GDB="$TARGET-gdb"

# Install Binutils
install_component \
    $CROSS_BINUTILS \
    $BINUTILS_VERSION \
    $BINUTILS_URL \
    $BINUTILS_VERSION_TAR \
    "build-binutils" \
    "--target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror" \
    "make && make install"

# Install GDB
install_component \
    $CROSS_GDB \
    $GDB_VERSION \
    $GDB_URL \
    $GDB_VERSION_TAR \
    "build-gdb" \
    "--target=$TARGET --prefix=$PREFIX --program-prefix=$TARGET- --disable-nls" \
    "make all-gdb && make install-gdb"

# Install GCC
install_component \
    $CROSS_GCC \
    $GCC_VERSION \
    $GCC_VERSION_URL \
    $GCC_VERSION_TAR \
    "build-gcc" \
    "--target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers" \
    "make all-gcc && make all-target-libgcc && make install-gcc && make install-target-libgcc"

# Check that the component was successfully installed
verify_installation $CROSS_GCC

echo -e "${GREEN}${CHECKMARK}${NC} Done!"
# End of script