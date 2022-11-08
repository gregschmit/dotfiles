#!/usr/bin/env python

# Replace this user's home directory files with symlinks to the `src` directory.

from argparse import ArgumentParser
import os
import shutil

if __name__ == "__main__":
    # Parse arguments.
    parser = ArgumentParser(
        description="Install (symlink) files into the current user's home directory."
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        default=False,
        help="overwrite existing files",
    )
    args = parser.parse_args()

    # Setup directory variables.
    project_dir = os.path.dirname(os.path.abspath(__file__))
    src_dir = os.path.join(project_dir, "src")
    home_dir = os.path.expanduser("~")
    src_files = os.listdir(src_dir)
    pad = max([len(f) for f in src_files]) + 1

    # Iterate over `src` files and symlink them.
    for f in src_files:
        home_file = os.path.join(home_dir, f)
        src_file = f"{src_dir}/{f}"

        # Check if symlink already exists.
        try:
            if os.path.realpath(home_file) == src_file:
                print(f"{f:{pad}}: already symlinked")
                continue
        except:
            pass

        # Attempt to symlink the file.
        try:
            # If `home_file` exists and `args.force` is specified, then remove the `home_file`.
            if args.force:
                if os.path.islink(home_file) or os.path.isfile(home_file):
                    os.remove(home_file)
                elif os.path.isdir(home_file):
                    shutil.rmtree(home_file)

            # Symlink the file.
            os.symlink(src_file, home_file)
            print(f"{f:{pad}}: successfully symlinked")
        except Exception as e:
            print(f"{f:{pad}}: failed to symlink ({e})")
