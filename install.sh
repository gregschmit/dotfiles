#!/bin/sh

# Helper to install symlinks to `src` directory.

# Remove any existing file/symlink at $2, then symlink $1 -> $2.
install_symlink() {
  echo "Removing:    $2"
  rm -rf "$2"
  echo "Symlinking:  $1"
  ln -s "$1" "$2"
}

# Directories whose *contents* are symlinked individually into the corresponding ~/dir/ rather than
# symlinking the directory itself. This is needed for `.config` where AppArmor allows `~/.config`
# but doesn't follow symlinks to it.
EXPAND_DIRS=".config"

# Ensure current directory is the script location.
cd "`dirname "$0"`"

for path in ./src/.* ./src/*; do
  # Get filename and ignore "." and "..".
  fn=$(basename $path)
  if [ $fn = "." ] || [ $fn = ".." ]; then continue; fi;

  src_file="`pwd`/src/$fn"

  # Check whether this entry should be expanded entry-by-entry.
  expand=0
  for expand_dir in $EXPAND_DIRS; do
    if [ "$fn" = "$expand_dir" ]; then
      expand=1
      break
    fi
  done

  if [ $expand -eq 1 ]; then
    # Symlink each item inside the directory into ~/fn/.
    home_dir=~/$fn

    # If the target exists as a symlink (e.g. from a previous install), remove it.
    if [ -L "$home_dir" ]; then
      echo "Removing:    $home_dir (symlink)"
      rm -rf "$home_dir"
    fi

    mkdir -p "$home_dir"
    for entry_path in "$src_file"/.* "$src_file"/*; do
      entry=$(basename "$entry_path")
      if [ "$entry" = "." ] || [ "$entry" = ".." ]; then continue; fi;

      home_entry="$home_dir/$entry"
      install_symlink "$entry_path" "$home_entry"
    done
  else
    home_file=~/$fn

    # Remove and symlink the file.
    install_symlink "$src_file" "$home_file"
  fi
done
