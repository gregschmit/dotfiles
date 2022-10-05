#!/usr/bin/env python

# Replace this user's home directory dotfiles with symlinks to the dotfiles directory.

from argparse import ArgumentParser
import os

if __name__ == "__main__":
    # Parse arguments.
    parser = ArgumentParser(
        description="Install (symlink) dotfiles into the current user's home directory."
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
    dotfiles_dir = os.path.join(project_dir, "dotfiles")
    home_dir = os.path.expanduser("~")
    dotfiles = os.listdir(dotfiles_dir)
    pad = max([len(f) for f in dotfiles]) + 1

    # Iterate over dotfiles and symlink them.
    for f in os.listdir(dotfiles_dir):
        homefile = os.path.join(home_dir, f)
        dotfile = f"{dotfiles_dir}/{f}"

        # Check if symlink already exists.
        try:
            if os.path.realpath(homefile) == dotfile:
                print(f"{f:{pad}}: already symlinked")
                continue
        except:
            pass

        # Attempt to symlink the file.
        try:
            # If `homefile` exists and `args.force` is specified, then remove the `homefile`.
            if args.force and os.path.isfile(homefile):
                os.remove(homefile)

            # Symlink the file.
            os.symlink(dotfile, homefile)
            print(f"{f:{pad}}: successfully symlinked")
        except Exception as e:
            print(f"{f:{pad}}: failed to symlink ({e})")
