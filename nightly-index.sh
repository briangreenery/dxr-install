#!/bin/sh

set -e
set -x

if [ -z $1 ]; then
  echo 'Must specify which tree to build'
  exit 1
fi

WWW_DXR=/var/www/dxr

# Make the tmp directory to work in
rm -rf nightly-tmp
mkdir nightly-tmp
cd nightly-tmp

# Copy and modify the config to output to the tmp directory
cp ../dxr.config nightly.config
sed -i 's/^target_folder.*$/target_folder=output/' nightly.config

# Build the requested tree
dxr-build.py --tree $1 nightly.config

# Swap in the newly built index
mv $WWW_DXR/trees/$1 .
mv output/trees/$1 $WWW_DXR/trees

# Clean up
cd ..
rm -rf nightly-tmp
