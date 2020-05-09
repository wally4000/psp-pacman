#!/bin/bash
# pacman.sh by Wouter Wijsman (wwijsman@live.nl)

# Exit on errors
set -e

## Remove $CC and $CXX for configure
unset CC
unset CXX

## Enter the psp-pacman directory.
cd "$(dirname "$0")"

source common.sh
mkdir -p build

## Variables used to build
PACMAN_VERSION="5.2.1"
INSTALL_DIR="${PSPDEV}/share/pacman"
BASE_PATH="${PWD}"

## Only install if pacman is not available
if ! which "pacman" >/dev/null 2>&1; then
    cd "${BASE_PATH}/build"
    download_and_extract https://sources.archlinux.org/other/pacman/pacman-${PACMAN_VERSION}.tar.gz pacman-${PACMAN_VERSION}
    apply_patch pacman-${PACMAN_VERSION}

    ## Install meson and ninja in the current directory
    setup_build_system

    ## Build pacman
    meson build
    meson configure build -Dprefix=${INSTALL_DIR} -Dbuildscript=PSPBUILD -Droot-dir=${PSPDEV} -Ddoc=disabled -Dbash-completion=false
    cd build
    ninja

    ## Install
    ninja install
fi

## Install configuration files and wrapper script
cd "${BASE_PATH}"
install -D -m 644 config/pacman.conf "${INSTALL_DIR}/etc/pacman.conf"
install -D -m 644 config/makepkg.conf "${INSTALL_DIR}/etc/makepkg.conf"
install -D -m 755 scripts/psp-pacman "${PSPDEV}/bin/psp-pacman"
install -D -m 755 scripts/psp-makepkg "${PSPDEV}/bin/psp-makepkg"

## Make sure the dbpath directory exists
mkdir -p "${INSTALL_DIR}/var/lib/pacman"

## Done
echo "Installation finished."
