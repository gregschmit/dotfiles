#!/bin/sh

# Replace this user's home directory dotfiles with symlinks to this directory.

# First, `cd` into this directory.
cd "$(dirname "$0")"

# Iterate over dotfiles and symlink them.