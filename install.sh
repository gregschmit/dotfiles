#!/bin/sh

# Helper to install symlinks to `src` directory.

# Ensure current directory is the script location.
cd "`dirname "$0"`"

for path in ./src/.* ./src/*; do
  # Get filename and ignore "." and "..".
  fn=$(basename $path)
  if [ $fn = "." ] || [ $fn = ".." ]; then continue; fi;

  home_file=~/$fn
  src_file="`pwd`/src/$fn"

  # Remove and symlink the file.
  echo "Removing:    $home_file"
  rm -rf $home_file
  echo "Symlinking:  $src_file"
  ln -s $src_file $home_file
done
