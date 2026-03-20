# Dotfiles Manager

A simple, lightweight, Makefile-driven utility to manage your dotfiles. It tracks your configuration files by mirroring their exact path relative to your `$HOME` directory, making it easy to sync, version control, and restore your system configuration across different machines.

## Features

- **Path Preservation:** Stores files in the repository using the exact same directory structure as your `$HOME` folder.
- **Zero Dependencies:** Uses standard Unix tools (`cp`, `mkdir`, `ln`, `find`) and `make`.
- **Easy Management:** Simple `make` commands to add new files, sync updates, and install them on new machines.
- **Safe Operations:** Creates necessary parent directories automatically and safely symlinks files.

## Prerequisites

- `make`
- Standard POSIX utilities (`cp`, `mkdir`, `ln`, `find`, `dirname`)

## Installation & Setup

1. Clone this repository to your preferred location (e.g., `~/Projects/dotfiles` or `~/.dotfiles`):
   ```bash
   git clone <your-repo-url> ~/Projects/dotfiles
   cd ~/Projects/dotfiles
   ```

2. Initialize your dotfiles by adding your first configuration file!

## Usage

This utility is entirely driven by the included `Makefile`.

### Adding a new dotfile (`make add`)

To track a new configuration file, use the `add` target and specify the file path using the `FILE` variable. You can provide either an absolute path or a path using `~`.

```bash
# Add a file in the home directory
make add FILE=~/.bashrc

# Add a file nested in .config
make add FILE=~/.config/nvim/init.lua
```

**What happens?**
The script computes the file's path relative to `$HOME`, creates the necessary parent directories inside the repository, and copies the file over. 

For example, `make add FILE=~/.config/nvim/init.lua` will copy the file to `./.config/nvim/init.lua` inside the repository.

### Syncing tracked dotfiles (`make sync`)

When you make changes to your configuration files on your system, you need to sync those changes back to this repository before committing them to version control.

```bash
make sync
```

**What happens?**
The utility scans all files currently tracked in the repository (excluding `.git`, `Makefile`, and `README.md`) and updates them with the latest versions from your `$HOME` directory. This is perfect for when you've been tweaking configs locally and want to securely save them.

### Installing dotfiles to a new machine (`make install`)

To deploy your tracked dotfiles onto a new system, use the `install` target.

```bash
make install
```

**What happens?**
The utility mirrors the repository's directory structure into your `$HOME` directory, creating any missing parent folders. It then creates symbolic links from the files in this repository to their correct locations in `$HOME`.

*Note: If a file already exists at the target location and is not a symlink, the script will create a backup (e.g., with a `.bak` extension) before creating the symlink.*

## Directory Structure Example

If you add `~/.zshrc` and `~/.config/alacritty/alacritty.yml`, your repository will look like this:

```text
dotfiles/
├── Makefile
├── README.md
├── .zshrc
└── .config/
    └── alacritty/
        └── alacritty.yml
```

When you run `make install`, it ensures `~/.config/alacritty` exists and safely symlinks the repository files into place.

## Source Control

Once you have added or synced your files, remember to use Git to commit and push your changes:

```bash
git add .
git commit -m "Update dotfiles"
git push
```
