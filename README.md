# Psiloc

A dotfiles repository for Debian Trixie development environments with automated setup and backup scripts.

![Comical TRON-inspired terminal scene](docs/images/psiloc.png)

## Overview

Personal configuration repository containing dotfiles, a Go-based setup automation CLI, and backup scripts for maintaining a consistent development environment across machines. The legacy bash setup menu has been replaced with a robust, zero-dependency Go application.

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

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
