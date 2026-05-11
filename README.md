# Psiloc

A dotfiles repository for Debian Trixie development environments with automated setup and backup scripts.

![Comical TRON-inspired terminal scene](docs/images/psiloc.png)

## Overview

Personal configuration repository containing dotfiles, a Go-based setup automation CLI, and backup scripts for maintaining a consistent development environment across machines. The legacy bash setup menu has been replaced with a robust, zero-dependency Go application.

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
├── src/                   # Go source code for setup-client CLI
│   ├── main.go            # Entry point for the Go app
│   └── README.md          # Developer docs for setup-client
├── scripts/               # Utility scripts executed by the Go app or manually
│   ├── backup.sh          # Configuration backup menu
│   ├── audit.sh           # Workstation security audit
│   ├── harden.sh          # Interactive security hardening
│   └── unharden.sh        # Interactive hardening reversal
└── docs/                  # Documentation and images
    ├── SECURITY.md        # Security audit & hardening guide
    └── CONTRIBUTING.md    # Guidelines for Conventional Commits
```

## Contributing

Please review our [Contributing Guidelines](docs/CONTRIBUTING.md) which requires the use of **Conventional Commits** to support our automated Semantic Release pipeline.

## Quick Start (Go App Usage)

The setup process is now managed by a Go CLI application `setup-client`, which provides an interactive menu for installing tools and hardening the system.

```bash
# Clone repository
cd ~/github/psilore
git clone https://github.com/psilore/psiloc.git
cd psiloc

# Build the Go setup client
cd src
go build -o ../setup-client main.go
cd ..

# Run interactive setup
./setup-client
```

### Features of `setup-client`

The Go application provides a robust menu with options to:

- Install necessary packages, tools, and environments (Docker, Terraform, Neovim, VS Code, Zsh, etc.)
- Set up automated cron backup jobs via `backup.sh`
- Perform local security audits and workstation hardening (calling `scripts/audit.sh`, `scripts/harden.sh`, and `scripts/unharden.sh`)

## Security

Psiloc provides built-in tools for auditing and hardening your Debian-based workstation. These can be run from the Go app menu or manually. For detailed information on these features, see the [Security Guide](docs/SECURITY.md).

- **Audit**: Select the audit option in `setup-client` or run `./scripts/audit.sh` (may prompt for sudo) to see your current security posture.
- **Harden**: Select the harden option in `setup-client` or run `./scripts/harden.sh` for an interactive security setup.
- **Revert**: Select the revert option in `setup-client` or run `./scripts/unharden.sh` to safely undo security changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
