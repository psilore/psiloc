
# Psiloc

A comprehensive repository for managing development environment configurations, color profiles, and automated setup scripts.

![Comical TRON-inspired terminal scene](docs/images/psiloc.png)
*Imagine your terminal as the Grid, but with more jokes and less danger!*

## Overview

This repository contains configuration files and setup scripts to quickly configure a development environment with consistent settings across machines. It includes VS Code settings, terminal color schemes, shell configurations, and automated installation scripts for common development tools.

## Repository Structure

### 📁 `config/`

Configuration files for various tools and applications:

#### `config/vscode/settings/`

VS Code editor settings and extensions:

- **`settings.json`**: VS Code user settings and preferences
- **`keybindings.json`**: Custom keyboard shortcuts
- **`tasks.json`**: Predefined VS Code tasks
- **`extensions.txt`**: List of installed VS Code extensions

#### `config/terminal/colors/`

GNOME Terminal color profiles:

- **`dracula.dconf`**: Dracula color scheme configuration
- **`monokai-dark.dconf`**: Monokai Dark color scheme with custom palette and font settings

#### `config/shell/zsh/environment/`

Shell configuration files:

- **`.zshrc`**: Zsh shell configuration with Oh My Zsh setup

### 📁 `scripts/`

Automation scripts for environment setup:

- **`setup.sh`**: Main setup script that:
  - Installs essential packages (git, zsh, htop, curl, etc.)
  - Removes unwanted pre-installed applications
  - Configures 1Password, Google Chrome, Tailscale, Terraform, Docker, and VS Code
  - Sets up Oh My Zsh with plugins (fzf, zsh-autosuggestions, zsh-syntax-highlighting, zsh-autocomplete)
  - Installs Source Code Pro fonts
  - Loads GNOME Terminal color profiles
  - Configures UFW firewall
  
- **`export-vscode-settings.sh`**: Exports current VS Code settings to the repository:
  - Backs up settings.json, keybindings.json, and tasks.json
  - Exports list of installed extensions
  - Copies code snippets directory

### 📁 `docs/`

Documentation and assets:

#### `docs/images/`

- **`psiloc.png`**: Repository logo and branding image

## Usage

### Initial Setup

Run the main setup script to configure a new development environment:

```bash
./scripts/setup.sh [hostname]
```

This will install and configure all development tools and settings.

### Export VS Code Settings

To backup your current VS Code configuration to this repository:

```bash
./scripts/export-vscode-settings.sh
```

### Apply Terminal Color Profiles

Load a terminal color profile using dconf:

```bash
dconf load /org/gnome/terminal/legacy/profiles:/ < config/terminal/colors/monokai-dark.dconf
```

### Restore VS Code Settings

To restore VS Code settings on a new machine:

1. Copy the files from `config/vscode/settings/` to `~/.config/Code/User/`
2. Install extensions:

   ```bash
   cat config/vscode/settings/extensions.txt | xargs -n 1 code --install-extension
   ```

### Apply Shell Configuration

Link or copy the Zsh configuration:

```bash
cp config/shell/zsh/environment/.zshrc ~/.zshrc
source ~/.zshrc
```

## Features

- **Automated Environment Setup**: One-command installation of development tools
- **Consistent Theming**: Pre-configured color schemes for terminal
- **VS Code Synchronization**: Easy backup and restore of editor settings
- **Security**: Includes basic UFW firewall configuration
- **Shell Enhancement**: Oh My Zsh with productivity-boosting plugins
- **Professional Fonts**: Source Code Pro font installation

---

This repository is designed to maintain a consistent, productive development environment across multiple machines.
