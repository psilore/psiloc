#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Backup functions
backup_vscode_settings() {
    print_message "Backing up VS Code settings..."
    
    VSCODE_CONFIG="$HOME/.config/Code/User"
    BACKUP_DIR="$REPO_DIR/config/vscode/settings"
    
    if [ -d "$VSCODE_CONFIG" ]; then
        mkdir -p "$BACKUP_DIR"
        
        # Backup settings.json
        if [ -f "$VSCODE_CONFIG/settings.json" ]; then
            cp "$VSCODE_CONFIG/settings.json" "$BACKUP_DIR/settings.json"
            print_success "Backed up settings.json"
        fi
        
        # Backup keybindings.json
        if [ -f "$VSCODE_CONFIG/keybindings.json" ]; then
            cp "$VSCODE_CONFIG/keybindings.json" "$BACKUP_DIR/keybindings.json"
            print_success "Backed up keybindings.json"
        fi
        
        # Backup tasks.json
        if [ -f "$VSCODE_CONFIG/tasks.json" ]; then
            cp "$VSCODE_CONFIG/tasks.json" "$BACKUP_DIR/tasks.json"
            print_success "Backed up tasks.json"
        fi
        
        # Export installed extensions
        code --list-extensions > "$BACKUP_DIR/extensions.txt"
        print_success "Backed up extensions list"
    else
        print_error "VS Code config directory not found"
    fi
}

backup_zsh_config() {
    print_message "Backing up Zsh configuration..."
    
    BACKUP_DIR="$REPO_DIR/config/shell/zsh"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
        print_success "Backed up .zshrc"
    fi
    
    # Backup .zshenv
    if [ -f "$HOME/.zshenv" ]; then
        cp "$HOME/.zshenv" "$BACKUP_DIR/.zshenv"
        print_success "Backed up .zshenv"
    fi
    
    # Backup .zprofile
    if [ -f "$HOME/.zprofile" ]; then
        cp "$HOME/.zprofile" "$BACKUP_DIR/.zprofile"
        print_success "Backed up .zprofile"
    fi
}

backup_gnome_terminal() {
    print_message "Backing up GNOME Terminal profiles..."
    
    BACKUP_DIR="$REPO_DIR/config/gnome-terminal/colors"
    
    if command -v dconf >/dev/null 2>&1; then
        mkdir -p "$BACKUP_DIR"
        
        # Export current profile
        dconf dump /org/gnome/terminal/legacy/profiles:/ > "$BACKUP_DIR/current-profile.dconf"
        print_success "Backed up GNOME Terminal profile"
    else
        print_error "dconf not installed"
    fi
}

backup_nvim_config() {
    print_message "Backing up Neovim configuration..."
    
    SOURCE_DIR="$HOME/.config/nvim"
    BACKUP_DIR="$REPO_DIR/config/nvim"
    
    if [ -d "$SOURCE_DIR" ]; then
        # Check if it's already a symlink to our repo
        if [ -L "$SOURCE_DIR" ]; then
            LINK_TARGET=$(readlink -f "$SOURCE_DIR")
            if [[ "$LINK_TARGET" == "$BACKUP_DIR"* ]]; then
                print_warning "Neovim config is already symlinked to repo, skipping"
                return
            fi
        fi
        
        # Backup the config
        rsync -av --exclude='.git' "$SOURCE_DIR/" "$BACKUP_DIR/"
        print_success "Backed up Neovim configuration"
    else
        print_warning "Neovim config directory not found"
    fi
}

backup_ghostty_config() {
    print_message "Backing up Ghostty configuration..."
    
    SOURCE_FILE="$HOME/.config/ghostty/config"
    BACKUP_DIR="$REPO_DIR/config/ghostty"
    
    if [ -f "$SOURCE_FILE" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$SOURCE_FILE" "$BACKUP_DIR/config"
        print_success "Backed up Ghostty configuration"
    else
        print_warning "Ghostty config file not found"
    fi
}

backup_git_config() {
    print_message "Backing up Git configuration..."
    
    BACKUP_DIR="$REPO_DIR/config/git"
    
    mkdir -p "$BACKUP_DIR"
    
    if [ -f "$HOME/.gitconfig" ]; then
        cp "$HOME/.gitconfig" "$BACKUP_DIR/.gitconfig"
        print_success "Backed up .gitconfig"
    fi
    
    if [ -f "$HOME/.gitignore_global" ]; then
        cp "$HOME/.gitignore_global" "$BACKUP_DIR/.gitignore_global"
        print_success "Backed up .gitignore_global"
    fi
}

backup_ssh_config() {
    print_message "Backing up SSH configuration to 1Password..."
    
    # Check if 1Password CLI is installed
    if ! command -v op >/dev/null 2>&1; then
        print_error "1Password CLI (op) is not installed"
        print_error "Install it with: https://developer.1password.com/docs/cli/get-started/"
        return 1
    fi
    
    # Check if user is signed in to 1Password
    if ! op account list >/dev/null 2>&1; then
        print_error "Not signed in to 1Password"
        print_error "Run: eval \$(op signin)"
        return 1
    fi
    
    if [ ! -d "$HOME/.ssh" ]; then
        print_warning "SSH directory not found"
        return 1
    fi
    
    # Backup SSH config to 1Password
    if [ -f "$HOME/.ssh/config" ]; then
        SSH_CONFIG_CONTENT=$(cat "$HOME/.ssh/config")
        
        # Try to update existing item, or create new one
        if op item get "SSH Config" --vault "Private" >/dev/null 2>&1; then
            # Update existing item
            echo "$SSH_CONFIG_CONTENT" | op item edit "SSH Config" \
                --vault "Private" \
                "notesPlain[text]=-" >/dev/null 2>&1
            print_success "Updated SSH config in 1Password"
        else
            # Create new item
            op item create \
                --category "Secure Note" \
                --title "SSH Config" \
                --vault "Private" \
                "notesPlain[text]=$SSH_CONFIG_CONTENT" >/dev/null 2>&1
            print_success "Created SSH config in 1Password"
        fi
    else
        print_warning "SSH config file not found"
    fi
    
    # Also backup known_hosts to 1Password
    if [ -f "$HOME/.ssh/known_hosts" ]; then
        KNOWN_HOSTS_CONTENT=$(cat "$HOME/.ssh/known_hosts")
        
        if op item get "SSH Known Hosts" --vault "Private" >/dev/null 2>&1; then
            echo "$KNOWN_HOSTS_CONTENT" | op item edit "SSH Known Hosts" \
                --vault "Private" \
                "notesPlain[text]=-" >/dev/null 2>&1
            print_success "Updated SSH known_hosts in 1Password"
        else
            op item create \
                --category "Secure Note" \
                --title "SSH Known Hosts" \
                --vault "Private" \
                "notesPlain[text]=$KNOWN_HOSTS_CONTENT" >/dev/null 2>&1
            print_success "Created SSH known_hosts in 1Password"
        fi
    fi
    
    print_warning "SSH config stored in 1Password vault 'Private', NOT in repository"
}

backup_fonts() {
    print_message "Creating fonts backup list..."
    
    BACKUP_DIR="$REPO_DIR/config/fonts"
    
    mkdir -p "$BACKUP_DIR"
    
    # List installed fonts
    fc-list > "$BACKUP_DIR/installed-fonts.txt"
    print_success "Backed up fonts list"
}

backup_packages() {
    print_message "Backing up installed packages..."
    
    BACKUP_FILE="$SCRIPT_DIR/installed-packages"
    
    # Export manually installed packages (not dependencies)
    apt-mark showmanual > "$BACKUP_FILE"
    print_success "Backed up installed packages list"
}

backup_all() {
    print_message "Backing up all configurations..."
    backup_vscode_settings
    backup_zsh_config
    backup_gnome_terminal
    backup_nvim_config
    backup_ghostty_config
    backup_git_config
    backup_ssh_config
    backup_fonts
    backup_packages
    print_success "All backups complete!"
}

# Main menu
show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Configuration Backup Menu          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Backup destination: $REPO_DIR/config/"
    echo ""
    echo "  1)  Backup VS Code settings"
    echo "  2)  Backup Zsh configuration"
    echo "  3)  Backup GNOME Terminal profiles"
    echo "  4)  Backup Neovim configuration"
    echo "  5)  Backup Ghostty configuration"
    echo "  6)  Backup Git configuration"
    echo "  7)  Backup SSH configuration"
    echo "  8)  Backup fonts list"
    echo "  9)  Backup installed packages list"
    echo "  10) Backup ALL configurations"
    echo "  0)  Exit"
    echo ""
    echo -ne "${YELLOW}Enter your choice [0-10]:${NC} "
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) backup_vscode_settings ;;
        2) backup_zsh_config ;;
        3) backup_gnome_terminal ;;
        4) backup_nvim_config ;;
        5) backup_ghostty_config ;;
        6) backup_git_config ;;
        7) backup_ssh_config ;;
        8) backup_fonts ;;
        9) backup_packages ;;
        10) backup_all ;;
        0)
            print_message "Exiting backup script. Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please try again."
            ;;
    esac
    
    echo ""
    echo -ne "${YELLOW}Press Enter to continue...${NC}"
    read -r
done
