#!/bin/bash
# Description: Workstation security hardening REVERSAL script.
# Supported: Debian, Ubuntu, Linux Mint, Pop!_OS, and other derivatives.
# Warning: This script reverts security hardening measures. 
#          Ensure you understand the implications before running.

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Function to ask for confirmation
confirm_step() {
    local step_name="$1"
    echo -e "\n${YELLOW}[?]${NC} Reverse $step_name?"
    read -p "    Confirm reversal [y/N]: " response
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

revert_firewall() {
    if ! confirm_step "Reset Firewall (UFW) to defaults"; then return 0; fi
    print_message "Reverting Firewall (UFW) defaults..."
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw --force reset
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw disable
        print_success "Firewall reset and disabled."
    fi
}

revert_hardening() {
    print_message "Starting Security Hardening Reversal..."

    # 1. Uninstall workstation security tools
    if confirm_step "Uninstall Security Tools (usbguard, firejail)"; then
        print_message "Uninstalling security tools..."
        sudo apt-get remove --purge -y usbguard firejail 2>/dev/null || true
        print_message "Resetting unattended-upgrades config..."
        sudo dpkg-reconfigure -plow unattended-upgrades
    fi

    # 2. Kernel Hardening Reversal (sysctl)
    if confirm_step "Remove Kernel Security Parameters (sysctl/modprobe)"; then
        print_message "Removing kernel security parameters..."
        if [ -f /etc/sysctl.d/99-hardening.conf ]; then
            sudo rm /etc/sysctl.d/99-hardening.conf
            sudo sysctl --system
        fi
        if [ -f /etc/modprobe.d/hardening.conf ]; then
            sudo rm /etc/modprobe.d/hardening.conf
        fi
    fi

    # 3. SSH Configuration Restoration
    if confirm_step "Restore SSH Configs to defaults"; then
        print_message "Restoring SSH client configuration to defaults..."
        if [ -f /etc/ssh/ssh_config ]; then
            sudo sed -i 's/^\s*HashKnownHosts.*/#   HashKnownHosts yes/' /etc/ssh/ssh_config
            sudo sed -i 's/^\s*StrictHostKeyChecking.*/#   StrictHostKeyChecking ask/' /etc/ssh/ssh_config
        fi
        
        if [ -f /etc/ssh/sshd_config ]; then
            print_message "Restoring SSH server (sshd) defaults..."
            sudo sed -i 's/^\s*PermitRootLogin.*/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
            sudo sed -i 's/^\s*PasswordAuthentication.*/#PasswordAuthentication yes/' /etc/ssh/sshd_config
            sudo systemctl restart ssh 2>/dev/null || true
        fi
    fi

    # 4. Shared Memory Protection Removal
    if grep -q "/dev/shm" /etc/fstab; then
        if confirm_step "Remove Shared Memory Protection from fstab"; then
            print_message "Removing /dev/shm security flags from /etc/fstab..."
            sudo sed -i '/\/dev\/shm/d' /etc/fstab
        fi
    fi

    # 5. Restore System Umask
    if confirm_step "Restore System Umask to 022"; then
        print_message "Restoring system umask to 022..."
        sudo sed -i 's/^UMASK.*/UMASK 022/' /etc/login.defs
        sudo sed -i '/umask 027/d' /etc/profile
    fi

    # 7. Revert Firewall
    revert_firewall

    print_success "Security hardening reversal complete!"
    print_warning "Review /etc/fstab and SSH configs to ensure no orphaned settings remain."
}

# Run reversal
revert_hardening
