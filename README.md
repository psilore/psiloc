
# Psiloc

A dotfiles repository for Debian Trixie development environments with automated setup and backup scripts.

![Comical TRON-inspired terminal scene](docs/images/psiloc.png)

## Overview

Personal configuration repository containing dotfiles, setup automation, and backup scripts for maintaining a consistent development environment across machines.

## Structure

```bash
psiloc/
├── config/                # Configuration files for various applications
│   ├── vscode/            # VS Code settings and extensions
│   ├── nvim/              # Neovim with LazyVim configuration
│   ├── ghostty/           # Ghostty terminal config (Dracula theme)
│   ├── gnome-terminal/    # GNOME Terminal color profiles
│   ├── shell/zsh/         # Zsh configuration
│   └── git/               # Git configuration
├── scripts/
│   ├── setup.sh            # Interactive setup menu (21 options)
│   └── backup.sh           # Configuration backup menu (10 options)
└── docs/                   # Documentation and images
```

## Quick Start

```bash
# Clone repository
cd ~/github/psilore
git clone https://github.com/psilore/psiloc.git
cd psiloc/scripts

# Run interactive setup
./setup.sh

# Backup configurations
./backup.sh
```
