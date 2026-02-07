#!/bin/bash
# Description: Workstation security hardening script for Debian-based systems.
# Supported: Debian, Ubuntu, Linux Mint, Pop!_OS, and other derivatives.
# Warning: Designed for standard desktop/laptop installations. 
#          Custom kernels, non-standard partitioning, or heavy container 
#          setups may yield inconsistent results.

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for non-interactive flag
NON_INTERACTIVE=false
for arg in "$@"; do
    if [[ "$arg" == "--yes" || "$arg" == "-y" ]]; then
        NON_INTERACTIVE=true
        break
    fi
done

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

# Function to ask for confirmation
confirm_step() {
    if [[ "$NON_INTERACTIVE" == "true" ]]; then
        return 0
    fi
    local step_name="$1"
    echo -e "\n${YELLOW}[?]${NC} Apply $step_name?"
    read -p "    Confirm action [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            print_warning "Skipping $step_name."
            echo -e "--------------------------------------------------------------------------------"
            return 1
            ;;
    esac
}

setup_firewall() {
    if ! confirm_step "Workstation Firewall (UFW)"; then return 0; fi
    print_message "Setting up Workstation Firewall (UFW)..."
    sudo apt-get install -y ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    # Only allow SSH if specifically requested, or keep it limited
    sudo ufw limit ssh
    sudo ufw --force enable
}

harden_bluetooth() {
    if confirm_step "Disable & Mask Bluetooth Service"; then
        print_message "Disabling and masking Bluetooth service..."
        sudo systemctl disable --now bluetooth 2>/dev/null
        sudo systemctl mask bluetooth 2>/dev/null
    fi
}

harden_gnome_security() {
    if command -v gsettings >/dev/null 2>&1; then
        if confirm_step "GNOME Screen Lock (Enabled + 10m Delay)"; then
            print_message "Setting GNOME idle delay to 10 minutes..."
            gsettings set org.gnome.desktop.session idle-delay 600
            print_message "Enabling GNOME screen lock..."
            gsettings set org.gnome.desktop.screensaver lock-enabled true
        fi
    fi
}

harden_directory_permissions() {
    if confirm_step "Secure Home & SSH Directory Permissions"; then
        print_message "Securing home directory ($HOME) to 750..."
        chmod 750 "$HOME"
        if [ -d "$HOME/.ssh" ]; then
            print_message "Securing .ssh directory to 700..."
            chmod 700 "$HOME/.ssh"
            [ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config"
        fi
    fi
}

apply_security_hardening() {
    print_message "Starting Workstation Security Hardening..."

    # 1. Update and install workstation security tools
    if confirm_step "Security Tools (unattended-upgrades, usbguard, firejail)"; then
        print_message "Installing security tools..."
        sudo apt-get update
        sudo apt-get install -y unattended-upgrades usbguard firejail
        print_message "Enabling automatic security updates..."
        sudo dpkg-reconfigure -plow unattended-upgrades
    fi

    # 3. Kernel Hardening (sysctl)
    if confirm_step "Kernel Security Parameters (sysctl)"; then
        print_message "Applying kernel security parameters..."
        cat <<EOF | sudo tee /etc/sysctl.d/99-hardening.conf
# Network hardening
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.default.log_martians=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_timestamps=0

# Kernel & Process Hardening
kernel.randomize_va_space=2
kernel.kptr_restrict=2
kernel.perf_event_paranoid=3
kernel.unprivileged_bpf_disabled=1
kernel.yama.ptrace_scope=1
EOF
        sudo sysctl -p /etc/sysctl.d/99-hardening.conf
    fi

    # 4. SSH Client Hardening
    if confirm_step "SSH Configurations (Client & Server)"; then
        print_message "Hardening SSH client configuration..."
        if [ -f /etc/ssh/ssh_config ]; then
            sudo sed -i 's/^\s*#\?HashKnownHosts.*/    HashKnownHosts yes/' /etc/ssh/ssh_config
            sudo sed -i 's/^\s*#\?StrictHostKeyChecking.*/    StrictHostKeyChecking ask/' /etc/ssh/ssh_config
        fi
        
        # Also harden SSH server if it exists
        if [ -f /etc/ssh/sshd_config ]; then
            print_message "Hardening SSH server (sshd) configuration..."
            sudo sed -i 's/^\s*#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
            sudo sed -i 's/^\s*#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
            sudo systemctl restart ssh 2>/dev/null || true
        fi
    fi

    # 5. Shared Memory Protection
    if ! grep -q "/dev/shm" /etc/fstab; then
        if confirm_step "Shared Memory Protection (/etc/fstab)"; then
            print_message "Adding /dev/shm security flags to /etc/fstab..."
            echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" | sudo tee -a /etc/fstab
        fi
    fi

    # 6. Restrictive Umask
    if confirm_step "Restrictive System Umask (027)"; then
        print_message "Setting restrictive system umask (027)..."
        sudo sed -i 's/^UMASK.*/UMASK 027/' /etc/login.defs
        if ! grep -q "umask 027" /etc/profile; then
            echo "umask 027" | sudo tee -a /etc/profile
        fi
    fi

    # 7. Disable unused network protocols
    if confirm_step "Disable unused network protocols (DCCP, SCTP, RDS, TIPC)"; then
        print_message "Disabling unused network protocols..."
        cat <<EOF | sudo tee /etc/modprobe.d/hardening.conf
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
EOF
    fi

    # 8. Setup Firewall
    setup_firewall

    # 9. Extra workstation gaps
    harden_bluetooth
    harden_gnome_security
    harden_directory_permissions

    print_success "Workstation security hardening applied successfully!"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    apply_security_hardening
fi
