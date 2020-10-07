#!/usr/bin/env bash

# Define variables
version=$VIPS_VERSION
pre_version=$VIPS_PRE_VERSION
tag_version=$version${pre_version:+-$pre_version}
vips_tarball=https://github.com/libvips/libvips/releases/download/v$tag_version/vips-$tag_version.tar.gz

# Exit immediately if a command exits with a non-zero status
set -e

# Do we already have the correct vips built?
if [ -d "$HOME/vips/bin" ]; then
    installed_version=$($HOME/vips/bin/vips --version | awk -F- '{print $2}')
    echo "Need vips $version"
    echo "Found vips $installed_version"

    if [ "$installed_version" = "$version" ]; then
        echo "Using cached vips directory"
        exit 0
    fi
fi

# Make sure the vips folder exist
mkdir -p "$HOME/vips"

# Do we need to install vips from source?
if [ "$version" = "master" ]; then
    echo "Installing vips from source"

    git clone -b master --single-branch https://github.com/libvips/libvips.git vips-$version
    cd vips-$version
    ./autogen.sh --prefix="$HOME/vips" "$@"
    make -j$JOBS && make install
else
    echo "Installing vips $version"

    curl -Ls $vips_tarball | tar xz
    cd vips-$version
    ./configure --prefix="$HOME/vips" "$@"
    make -j$JOBS && make install
fi

# Clean-up build directory
cd ../
rm -rf vips-$version
