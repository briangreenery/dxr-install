#!/bin/sh

set -e
set -x

if [ -z $1 ]; then
  echo 'Must specify which tree to build'
  exit 1
fi

# Make the tmp directory to work in
rm -rf index-tree-tmp
mkdir index-tree-tmp
cd index-tree-tmp

# Copy and modify dxr.config to output to the tmp directory
cp ../dxr.config tree.config
sed -i 's/^target_folder.*$/target_folder=output/' tree.config

# Build the requested tree
dxr-build.py --tree $1 tree.config

# Swap in the newly built index
mv /var/www/dxr/trees/$1 .
mv output/trees/$1 /var/www/dxr/trees

# Clean up
cd ..
rm -rf index-tree-tmp
