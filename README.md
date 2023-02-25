# My Home Directory Dotfiles

This is my personal collection of dotfiles (and some miscellaneous files).

Currently I don't include things that relate to personal information or secrets, such as
`.gitconfig`, `.ssh`, and `.gnupg`, because a lot of that is required to clone this repo anyway, but
it would also make this little project harder to share. So the focus here is on environment config.

Feel free to fork this repo and use for your own dotfiles.

## Installation

- If you're not me, you should fork this repo first to make your own personal adjustments.
- Clone the repo somewhere. I always have a `~/git` directory, so I end up cloning to
  `~/git/dotfiles`. You can also track upstream to keep things up to date:

```sh
git clone git@github.com/<username>/dotfiles
cd dotfiles
git remote add upstream https://github.com/gregschmit/dotfiles
git fetch upstream
```

- Run `./install.sh` to install dotfiles; note that this will clobber existing files/directories.
