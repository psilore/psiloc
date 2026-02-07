
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
│   ├── setup.sh            # Interactive setup menu (23 options)
│   ├── backup.sh           # Configuration backup menu (10 options)
│   ├── audit.sh            # Workstation security audit
│   ├── harden.sh           # Interactive security hardening
│   └── unharden.sh         # Interactive hardening reversal
└── docs/                   # Documentation and images
    └── SECURITY.md         # Security audit & hardening guide
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

## Security

Psiloc provides built-in tools for auditing and hardening your Debian-based workstation. For detailed information on these features, see the [Security Guide](docs/SECURITY.md).

- **Audit**: Run `./scripts/audit.sh` to see your current security posture.
- **Harden**: Run `./scripts/harden.sh` for an interactive security setup.
- **Revert**: Run `./scripts/unharden.sh` to safely undo security changes.
