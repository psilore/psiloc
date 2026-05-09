#!/bin/bash

HOST="$1"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Installation functions
install_required_packages() {
    print_message "Installing required packages..."
    sudo apt-get update
    if [ -f "$SCRIPT_DIR/required-packages" ]; then
        xargs -a "$SCRIPT_DIR/required-packages" sudo apt-get install -y
    else
        print_error "File not found: $SCRIPT_DIR/required-packages"
    fi
}

install_neovim() {
    print_message "Installing Neovim (latest stable)..."
    
    # Check if Neovim is already installed
    if command -v nvim >/dev/null 2>&1; then
        CURRENT_VERSION=$(nvim --version 2>/dev/null | head -n1 || echo "unknown")
        print_message "Current Neovim: $CURRENT_VERSION"
    fi
    
    # Download latest stable Neovim tarball
    print_message "Downloading Neovim tarball..."
    if ! wget -qO /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz; then
        print_error "Failed to download Neovim"
        return 1
    fi
    
    # Remove old installation and extract
    print_message "Installing to /opt/nvim-linux-x86_64..."
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
    rm /tmp/nvim-linux-x86_64.tar.gz
    
    # Create symlink
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    
    # Verify installation
    if command -v nvim >/dev/null 2>&1; then
        print_message "Neovim installed successfully: $(nvim --version | head -n1)"
        print_message "Note: Add 'export PATH=\"\$PATH:/opt/nvim-linux-x86_64/bin\"' to your ~/.zshrc if needed"
    else
        print_error "Failed to install Neovim"
        return 1
    fi
}

remove_unwanted_packages() {
    print_message "Removing unwanted packages..."
    if [ -f "$SCRIPT_DIR/unwanted-packages" ]; then
        xargs -a "$SCRIPT_DIR/unwanted-packages" sudo apt-get remove -y
    else
        print_warning "File not found: $SCRIPT_DIR/unwanted-packages"
    fi
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
}

setup_cron_backup() {
    if [ -z "$HOST" ]; then
        print_error "HOST parameter required for cron backup setup. Run: $0 <hostname>"
        return 1
    fi
    print_message "Setting up cron backup job..."
    cp ~/backup.sh /home/"$USER"/backup.sh
    (crontab -u "$USER" -l 2>/dev/null; echo "0 0 */1 * * /home/$USER/backup.sh $HOST") | crontab -u "$USER" -
}

install_1password() {
    print_message "Installing 1Password..."
    wget -qO ~/Downloads/1password-latest.deb https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb
    sudo apt-get update && sudo apt-get install ~/Downloads/1password-latest.deb -y
}

install_chrome() {
    print_message "Installing Google Chrome..."
    wget -qO ~/Downloads/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt-get update && sudo apt-get install ~/Downloads/google-chrome-stable_current_amd64.deb -y
}

install_tailscale() {
    print_message "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
}

install_terraform() {
    print_message "Installing Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update && sudo apt-get install terraform -y
}

install_docker() {
    print_message "Installing Docker..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
}

install_vscode() {
    print_message "Installing VS Code..."
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt-get update && sudo apt-get install code -y
}

install_zsh_setup() {
    print_message "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_fzf() {
    print_message "Installing FuzzyFinder (fzf)..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    "$HOME"/.fzf/install
}

install_zsh_plugins() {
    print_message "Installing Zsh plugins..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        git clone --depth 1 -- https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}"/plugins/fzf-tab
        git clone --depth 1 -- https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
        git clone --depth 1 -- https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting
        git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}"/plugins/zsh-autocomplete
    else
        print_error "Oh-My-Zsh not installed. Please install it first."
    fi
}

setup_lazyvim() {
    print_message "Setting up LazyVim for Neovim..."
    if command -v nvim >/dev/null 2>&1; then
        # Backup existing Neovim config if it exists
        if [ -d "$HOME/.config/nvim" ]; then
            mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"
        fi
        if [ -d "$HOME/.local/share/nvim" ]; then
            mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak.$(date +%Y%m%d_%H%M%S)"
        fi
        if [ -d "$HOME/.local/state/nvim" ]; then
            mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak.$(date +%Y%m%d_%H%M%S)"
        fi
        if [ -d "$HOME/.cache/nvim" ]; then
            mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak.$(date +%Y%m%d_%H%M%S)"
        fi
        
        # Clone LazyVim starter
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
        rm -rf "$HOME/.config/nvim/.git"
        
        echo "LazyVim installed! Run 'nvim' to complete the setup."
    else
        print_error "Neovim not installed. Please install required packages first."
    fi
}

install_nerd_fonts() {
    print_message "Installing Source Code Pro Nerd Fonts..."
    wget -qO ~/Downloads/SourceCodePro.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip
    unzip -o ~/Downloads/SourceCodePro.zip -d ~/Downloads/SourceCodePro
    mkdir -p ~/.local/share/fonts
    cp ~/Downloads/SourceCodePro/* ~/.local/share/fonts/
    fc-cache -fv
}

setup_gnome_terminal() {
    print_message "Setting up GNOME Terminal profile..."
    
    # Check if dconf is installed
    if ! command -v dconf >/dev/null 2>&1; then
        print_error "dconf not installed. Please install required packages first."
        return 1
    fi
    
    # Find available dconf profiles
    GNOME_CONFIG_DIR="$SCRIPT_DIR/../config/gnome-terminal/colors"
    
    if [ ! -d "$GNOME_CONFIG_DIR" ]; then
        print_error "Config directory not found: $GNOME_CONFIG_DIR"
        return 1
    fi
    
    # Get list of .dconf files
    mapfile -t PROFILES < <(find "$GNOME_CONFIG_DIR" -name "*.dconf" -type f -exec basename {} .dconf \;)
    
    if [ ${#PROFILES[@]} -eq 0 ]; then
        print_error "No .dconf profiles found in $GNOME_CONFIG_DIR"
        return 1
    fi
    
    # Display available profiles
    echo ""
    echo -e "${BLUE}Available GNOME Terminal profiles:${NC}"
    for i in "${!PROFILES[@]}"; do
        echo "  $((i+1))) ${PROFILES[$i]}"
    done
    echo "  0) Cancel"
    echo ""
    echo -ne "${YELLOW}Choose a profile [0-${#PROFILES[@]}]:${NC} "
    read -r profile_choice
    
    # Validate choice
    if [[ "$profile_choice" == "0" ]]; then
        print_warning "Profile setup cancelled"
        return 0
    fi
    
    if ! [[ "$profile_choice" =~ ^[0-9]+$ ]] || [ "$profile_choice" -lt 1 ] || [ "$profile_choice" -gt ${#PROFILES[@]} ]; then
        print_error "Invalid choice"
        return 1
    fi
    
    # Apply selected profile
    SELECTED_PROFILE="${PROFILES[$((profile_choice-1))]}"
    PROFILE_FILE="$GNOME_CONFIG_DIR/${SELECTED_PROFILE}.dconf"
    
    print_message "Applying profile: $SELECTED_PROFILE"
    dconf load /org/gnome/terminal/legacy/profiles:/ < "$PROFILE_FILE"
    print_success "GNOME Terminal profile '$SELECTED_PROFILE' applied successfully"
}

setup_zsh_default() {
    print_message "Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
    $SHELL --version
}

install_ghostty() {
    print_message "Installing Ghostty terminal..."
    
    # Check if already installed
    if command -v ghostty >/dev/null 2>&1; then
        print_message "Ghostty is already installed: $(ghostty --version 2>&1 | head -n1)"
        return 0
    fi
    
    # Show installation options
    echo ""
    echo "Choose installation method:"
    echo "  1) Snap (recommended - easiest, official)"
    echo "  2) Ubuntu .deb package (community-maintained)"
    echo "  3) AppImage (universal, community-maintained)"
    echo "  0) Cancel"
    echo ""
    echo -ne "${YELLOW}Enter your choice [0-3]:${NC} "
    read -r install_choice
    
    case $install_choice in
        1)
            print_message "Installing Ghostty via Snap..."
            if ! command -v snap >/dev/null 2>&1; then
                print_message "Installing snapd..."
                sudo apt-get update
                sudo apt-get install -y snapd
            fi
            sudo snap install ghostty --classic
            
            if command -v ghostty >/dev/null 2>&1; then
                print_success "Ghostty installed successfully via Snap: $(ghostty --version 2>&1 | head -n1)"
            else
                print_error "Failed to install Ghostty via Snap"
                return 1
            fi
            ;;
            
        2)
            print_message "Installing Ghostty via Ubuntu .deb package..."
            print_warning "This is a community-maintained package"
            
            # Run the community installation script
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
            
            if command -v ghostty >/dev/null 2>&1; then
                print_success "Ghostty installed successfully: $(ghostty --version 2>&1 | head -n1)"
            else
                print_error "Failed to install Ghostty via .deb package"
                return 1
            fi
            ;;
            
        3)
            print_message "Installing Ghostty via AppImage..."
            print_warning "This is a community-maintained AppImage"
            
            # Create directory for AppImages
            mkdir -p "$HOME/.local/bin"
            
            # Detect architecture
            ARCH=$(uname -m)
            if [ "$ARCH" = "x86_64" ]; then
                ARCH="x86_64"
            elif [ "$ARCH" = "aarch64" ]; then
                ARCH="aarch64"
            else
                print_error "Unsupported architecture: $ARCH"
                return 1
            fi
            
            # Get latest release URL
            print_message "Downloading latest Ghostty AppImage..."
            LATEST_URL=$(curl -s https://api.github.com/repos/pkgforge-dev/ghostty-appimage/releases/latest | \
                grep "browser_download_url.*${ARCH}.appimage\"" | \
                cut -d '"' -f 4)
            
            if [ -z "$LATEST_URL" ]; then
                print_error "Failed to find AppImage download URL"
                return 1
            fi
            
            wget -O "$HOME/.local/bin/ghostty.appimage" "$LATEST_URL"
            chmod +x "$HOME/.local/bin/ghostty.appimage"
            
            # Create wrapper script
            cat > "$HOME/.local/bin/ghostty" <<'EOF'
#!/bin/bash
exec "$HOME/.local/bin/ghostty.appimage" "$@"
EOF
            chmod +x "$HOME/.local/bin/ghostty"
            
            # Create desktop file
            mkdir -p "$HOME/.local/share/applications"
            cat > "$HOME/.local/share/applications/ghostty.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Ghostty
Comment=Fast terminal emulator
Exec=$HOME/.local/bin/ghostty
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF
            
            if [ -f "$HOME/.local/bin/ghostty" ]; then
                print_success "Ghostty AppImage installed to ~/.local/bin/ghostty"
                print_message "Make sure ~/.local/bin is in your PATH"
            else
                print_error "Failed to install Ghostty AppImage"
                return 1
            fi
            ;;
            
        0)
            print_message "Installation cancelled"
            return 0
            ;;
            
        *)
            print_error "Invalid option"
            return 1
            ;;
    esac
}

uninstall_ghostty() {
    print_message "Uninstalling Ghostty terminal..."
    
    # Check if Ghostty is installed
    if ! command -v ghostty >/dev/null 2>&1 && ! snap list ghostty >/dev/null 2>&1 && [ ! -f "$HOME/.local/bin/ghostty" ]; then
        print_warning "Ghostty is not installed"
        return 0
    fi
    
    # Detect installation method and uninstall accordingly
    if snap list ghostty >/dev/null 2>&1; then
        print_message "Detected Snap installation, removing..."
        sudo snap remove ghostty
        print_success "Ghostty Snap removed"
    fi
    
    if dpkg -l | grep -q ghostty 2>/dev/null; then
        print_message "Detected .deb package installation, removing..."
        sudo apt-get remove -y ghostty
        sudo apt-get autoremove -y
        print_success "Ghostty .deb package removed"
    fi
    
    if [ -f "$HOME/.local/bin/ghostty.appimage" ]; then
        print_message "Detected AppImage installation, removing..."
        rm -f "$HOME/.local/bin/ghostty.appimage"
        rm -f "$HOME/.local/bin/ghostty"
        print_success "Ghostty AppImage removed"
    fi
    
    # Remove desktop file
    if [ -f "$HOME/.local/share/applications/ghostty.desktop" ]; then
        print_message "Removing desktop file..."
        rm -f "$HOME/.local/share/applications/ghostty.desktop"
    fi
    
    # Remove source directory (if exists from old build attempts)
    if [ -d "$HOME/.local/src/ghostty" ]; then
        print_message "Removing source directory..."
        rm -rf "$HOME/.local/src/ghostty"
    fi
    
    # Remove Zig if installed (from old build method)
    zig_dirs=()
    if command -v zig >/dev/null 2>&1; then
        for d in /opt/zig-linux-x86_64-*; do
            [ -d "$d" ] && zig_dirs+=("$d")
        done
        if [ "${#zig_dirs[@]}" -gt 0 ]; then
            echo -ne "${YELLOW}Remove Zig compiler (from previous build attempt)? (y/N):${NC} "
            read -r remove_zig
            if [[ "$remove_zig" =~ ^[Yy]$ ]]; then
                print_message "Removing Zig compiler..."
                sudo rm -f /usr/local/bin/zig
                for d in "${zig_dirs[@]}"; do
                    sudo rm -rf "$d"
                done
                print_success "Zig removed"
            else
                print_message "Keeping Zig compiler"
            fi
        fi
    fi
    
    # Verify removal
    if ! command -v ghostty >/dev/null 2>&1; then
        print_success "Ghostty uninstalled successfully"
    else
        print_warning "Ghostty command still found, manual cleanup may be needed"
    fi
}

setup_firewall() {
    print_message "Setting up UFW firewall..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw limit ssh
    sudo ufw enable
}

refresh_shell() {
    print_message "Refreshing shell configuration..."
    if [ -f "$HOME/.zshrc" ]; then
        print_success "Reloading .zshrc..."
        exec zsh
    elif [ -f "$HOME/.bashrc" ]; then
        print_success "Reloading .bashrc..."
        exec bash
    else
        print_warning "No shell configuration file found"
        print_message "Starting new shell session..."
        exec $SHELL
    fi
}

# Main menu
show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     System Setup Menu ($USER)         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    # Display system information
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        echo -e "${GREEN}System:${NC} $PRETTY_NAME"
        echo -e "${GREEN}Kernel:${NC} $(uname -r)"
        echo -e "${GREEN}Hostname:${NC} $(hostname)"
    fi
    echo ""
    echo "  1)  Install required packages"
    echo "  2)  Remove unwanted packages"
    echo "  3)  Install Neovim (latest stable)"
    echo "  4)  Setup cron backup job"
    echo "  5)  Install 1Password"
    echo "  6)  Install Google Chrome"
    echo "  7)  Install Tailscale"
    echo "  8)  Install Terraform"
    echo "  9)  Install Docker"
    echo "  10) Install VS Code"
    echo "  11) Install Oh-My-Zsh"
    echo "  12) Install FuzzyFinder (fzf)"
    echo "  13) Install Zsh plugins"
    echo "  14) Setup LazyVim for Neovim"
    echo "  15) Install Nerd Fonts"
    echo "  16) Setup GNOME Terminal profile"
    echo "  17) Install Ghostty terminal"
    echo "  18) Uninstall Ghostty terminal"
    echo "  19) Set Zsh as default shell"
    echo "  20) Setup UFW firewall"
    echo "  21) Install ALL (runs all options)"
    echo "  22) Refresh shell (reload configuration)"
    echo "  0)  Exit"
    echo ""
    echo -ne "${YELLOW}Enter your choice [0-22]:${NC} "
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) install_required_packages ;;
        2) remove_unwanted_packages ;;
        3) install_neovim ;;
        4) setup_cron_backup ;;
        5) install_1password ;;
        6) install_chrome ;;
        7) install_tailscale ;;
        8) install_terraform ;;
        9) install_docker ;;
        10) install_vscode ;;
        11) install_zsh_setup ;;
        12) install_fzf ;;
        13) install_zsh_plugins ;;
        14) setup_lazyvim ;;
        15) install_nerd_fonts ;;
        16) setup_gnome_terminal ;;
        17) install_ghostty ;;
        18) uninstall_ghostty ;;
        19) setup_zsh_default ;;
        20) setup_firewall ;;
        21)
            print_message "Installing everything..."
            sudo apt-get update
            install_required_packages
            remove_unwanted_packages
            install_neovim
            setup_cron_backup
            install_1password
            install_chrome
            install_tailscale
            install_terraform
            install_docker
            install_vscode
            install_zsh_setup
            install_fzf
            install_zsh_plugins
            setup_lazyvim
            install_nerd_fonts
            setup_gnome_terminal
            install_ghostty
            setup_zsh_default
            setup_firewall
            print_message "All installations complete!"
            ;;
        22) refresh_shell ;;
        0)
            print_message "Exiting setup script. Goodbye!"
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
