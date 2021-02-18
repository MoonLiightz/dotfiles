# Dotfiles

Welcome to my dotfiles repo. I am currently still in the process of creating this, this also includes this readme.

## What's provided

Maybe a lot, in any case too much to list it all here but I like it, obviously. Take a look at the files and configs that I am currently using and pick up what you like also. If you want to create your own dotfile repo and you like most of my stuff, you can just fork my repo and make your changes. You are also welcome to send cool changes back to me in a PR.

## Setup and Installation

### Clone the repo

First you have to clone the repo into your home directory.

```bash
$ git clone https://github.com/MoonLiightz/dotfiles.git ~/.dotfiles
```

### Backup

Before you start the installation, you may want to make a backup of your existing configurations. The bootstrap script provides a function that saves all symlinked files in a backup folder. The folder is automatically created under `~/dotfiles-backup` if it doesn't already exist. To create a backup run the following.

```bash
$ cd ~/.dotfiles
$ ./bootstrap.sh backup
```

### Installation

The setup is made up of a few parts.

- Create a symlink in your home directory for all `.symlink` files in this repo.
- Setup Homebrew (or Linuxbrew on Linux) and install packages from the [Brewfile](homebrew/Brewfile).
  - Packages can alternatively be installed with the system's own package manager like apt.
- Setup zsh, oh-my-zsh, some plugins and the powerlevel10k theme.
- Set your default shell to zsh.
- Setup git config with your personal information (name, email, ...).

```bash
$ cd ~/.dotfiles

# With Homebrew (Linuxbrew)
$ ./bootstrap.sh all

# Or with default package manger like apt
# this skips the setup of Homebrew
$ ./bootstrap.sh all --no-homebrew-setup
```

Before the individual steps of the installation starts, a small list of information about the current installation step will be printed. Each step must be confirmed before the execution will start. This allows a step to be skipped easily. The individual installation steps can also be called directly.

```bash
# Setup symlinks
$ ./bootstrap.sh link

# Setup Homebrew (Linuxbrew) and install packages
$ ./bootstrap.sh homebrew

# Install packages with system package manager
$ ./bootstrap.sh packages

# Setup zsh with oh-my-zsh, some plugins and the powerlevel10k theme
$ ./bootstrap.sh zsh

# Setup zsh as default shell
$ ./bootstrap.sh shell

# Setup git config with you personal information
$ ./bootstrap.sh git
```

## Updates

Updates can be easily pulled by using a provided command, which is a simple git pull with rebase and auto stash enabled, but you can use it from anywhere.

```bash
# Pull changes
$ dotfiles update

# Reload configs
$ src

# Reload tmux
Ctrl + a   r 
```

## Fonts

I am currently using `Meslo Nerd Font patched for Powerlevel10k` as my default font. You can find more about it and a download link in the [powerlevel10k](https://github.com/romkatv/powerlevel10k/blob/master/font.md) repo. 

### Credits

- My dotfiles are highly inspired by [Nick Nisi](https://github.com/nicknisi) great [dotfiles](https://github.com/nicknisi/dotfiles).
- My tmux configs are a customized version of [Gregory Pakosz](https://github.com/gpakosz) awesome [configs](https://github.com/gpakosz/.tmux).