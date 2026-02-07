#!/bin/bash
# Description: Workstation Security Audit Script for Debian-based systems.
# Supported: Debian, Ubuntu, Linux Mint, Pop!_OS, and other derivatives.
# Warning: Designed for standard desktop/laptop installations. 
#          Custom kernels, non-standard partitioning, or heavy container 
#          setups may yield inconsistent results.

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Ensure sbin is in PATH for sysctl and other tools
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin

# Global counters for summary
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNED_CHECKS=0

print_header() {
    echo -e "\n${BOLD}${BLUE}┌─────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
    printf "${BOLD}${BLUE}│${NC} %-87s ${BOLD}${BLUE}│${NC}\n" "$1"
    echo -e "${BOLD}${BLUE}├───────────────────────────────┬──────────┬─────────────┬────────────────────────────────┤${NC}"
    printf "${BOLD}${BLUE}│${NC} %-29s ${BOLD}${BLUE}│${NC} %-8s ${BOLD}${BLUE}│${NC} %-11s ${BOLD}${BLUE}│${NC} %-30s ${BOLD}${BLUE}│${NC}\n" "Security Check" "Status" "Result" "Explanation/Impact"
    echo -e "${BOLD}${BLUE}├───────────────────────────────┼──────────┼─────────────┼────────────────────────────────┤${NC}"
}

print_result() {
    local check="$1"
    local status="$2"
    local detail="$3"
    local explanation="$4"
    
    ((TOTAL_CHECKS++))
    
    case "$status" in
        "PASS")
            ((PASSED_CHECKS++))
            status_color="${GREEN}"
            ;;
        "FAIL")
            ((FAILED_CHECKS++))
            status_color="${RED}"
            ;;
        "WARN")
            ((WARNED_CHECKS++))
            status_color="${YELLOW}"
            ;;
    esac
    
    # We use %b for status_color to avoid it being counted in the padding of the next column
    # The borders are now explicitly colored to match the header/footer
    printf "${BOLD}${BLUE}│${NC} %-29.29s ${BOLD}${BLUE}│${NC} %b%-8s%b ${BOLD}${BLUE}│${NC} %-11.11s ${BOLD}${BLUE}│${NC} %-30.30s ${BOLD}${BLUE}│${NC}\n" "$check" "$status_color" "$status" "$NC" "$detail" "$explanation"
}

print_footer() {
    echo -e "${BOLD}${BLUE}└───────────────────────────────┴──────────┴─────────────┴────────────────────────────────┘${NC}"
}

check_physical_boot() {
    print_header "Physical & Boot Security"
    
    # 1. Disk Encryption (LUKS)
    if lsblk -f | grep -iq "crypto_LUKS"; then
        print_result "LUKS Disk Encryption" "PASS" "Detected" "Protects data if the laptop is lost or stolen."
    else
        print_result "LUKS Disk Encryption" "FAIL" "Not Found" "Data is at risk if physical access is gained."
    fi

    # 2. Secure Boot
    if command -v mokutil >/dev/null 2>&1; then
        local sb_status
        sb_status=$(mokutil --sb-state 2>/dev/null)
        if echo "$sb_status" | grep -iq "enabled"; then
            print_result "Secure Boot" "PASS" "Enabled" "Prevents unauthorized OS/kernel from booting."
        else
            print_result "Secure Boot" "WARN" "Disabled" "Risk of bootkit/rootkit infections at boot."
        fi
    elif command -v bootctl >/dev/null 2>&1; then
        if bootctl status 2>/dev/null | grep -iq "Secure Boot: enabled"; then
            print_result "Secure Boot" "PASS" "Enabled" "Prevents unauthorized OS/kernel from booting."
        else
            print_result "Secure Boot" "WARN" "Disabled" "Risk of bootkit/rootkit infections at boot."
        fi
    else
        print_result "Secure Boot" "WARN" "Unknown" "Could not determine Secure Boot status."
    fi
    
    print_footer
}

check_desktop_security() {
    print_header "Desktop & Workspace Security"
    
    # 1. GNOME Idle Lock
    if command -v gsettings >/dev/null 2>&1; then
        local lock_enabled
        lock_enabled=$(gsettings get org.gnome.desktop.screensaver lock-enabled 2>/dev/null)
        if [ "$lock_enabled" == "true" ]; then
            print_result "GNOME Idle Lock" "PASS" "Enabled" "Automatically locks screen when idle."
        elif [ "$lock_enabled" == "false" ]; then
            print_result "GNOME Idle Lock" "FAIL" "Disabled" "Laptop remains accessible when left unattended."
        fi

        local idle_delay
        idle_delay=$(gsettings get org.gnome.desktop.session idle-delay 2>/dev/null | awk '{print $2}')
        if [[ -n "$idle_delay" && "$idle_delay" != "0" ]]; then
            local mins=$((idle_delay / 60))
            if [ "$mins" -le 15 ]; then
                print_result "Idle Delay" "PASS" "${mins}m" "Reasonable timeout before locking."
            else
                print_result "Idle Delay" "WARN" "${mins}m" "Timeout is a bit long; consider shortening."
            fi
        fi
    fi

    # 2. Sensitive Directory Permissions
    local home_perms
    home_perms=$(stat -c "%a" "$HOME")
    if [ "$home_perms" -le "750" ]; then
        print_result "Home Dir Perms" "PASS" "$home_perms" "Restricts other local users from browsing your data."
    else
        print_result "Home Dir Perms" "WARN" "$home_perms" "Home directory is too open to other local users."
    fi
    
    print_footer
}

check_ssh_client() {
    print_header "SSH Client Security"
    
    local client_configs=("/etc/ssh/ssh_config" "$HOME/.ssh/config")
    local client_config_found=false
    
    # Add directory-based configs
    if [ -d "/etc/ssh/ssh_config.d" ]; then
        mapfile -t dropins < <(find /etc/ssh/ssh_config.d -name "*.conf" -type f)
        client_configs+=("${dropins[@]}")
    fi

    for config in "${client_configs[@]}"; do
        if [ -f "$config" ]; then
            client_config_found=true
            local display_name
            display_name=$(echo "$config" | sed "s|$HOME|~|")
            
            # Check HashKnownHosts
            if grep -Ei "^\s*HashKnownHosts\s+yes" "$config" > /dev/null 2>&1; then
                print_result "Client ($display_name): Hash" "PASS" "Enabled" "Hides target IPs/hostnames in known_hosts file."
            else
                print_result "Client ($display_name): Hash" "WARN" "Disabled" "Known hosts are stored in plain text."
            fi
            
            # Check StrictHostKeyChecking
            if grep -Ei "^\s*StrictHostKeyChecking\s+(yes|ask)" "$config" > /dev/null 2>&1; then
                print_result "Client ($display_name): Keys" "PASS" "Enabled" "Validates host identity before connecting."
            else
                print_result "Client ($display_name): Keys" "WARN" "Disabled" "Vulnerable to machine-in-the-middle attacks."
            fi
        fi
    done

    if [ "$client_config_found" = false ]; then
        print_result "SSH Client Config" "WARN" "None" "No custom client configuration found."
    fi

    if [ -d "$HOME/.ssh" ]; then
        local ssh_dir_perms
        ssh_dir_perms=$(stat -c "%a" "$HOME/.ssh")
        if [ "$ssh_dir_perms" -le "700" ]; then
            print_result "SSH Directory Perms" "PASS" "$ssh_dir_perms" "Required to protect private keys from exposure."
        else
            print_result "SSH Directory Perms" "FAIL" "$ssh_dir_perms" "CRITICAL: Keys are accessible to other users!"
        fi
    fi
    
    print_footer
}

check_hardware_os() {
    print_header "Hardware & OS Hardening"
    
    # 1. Bluetooth status
    if systemctl is-active --quiet bluetooth 2>/dev/null; then
        print_result "Bluetooth Status" "WARN" "Enabled" "Disable if not in use to reduce radio attack surface."
    else
        print_result "Bluetooth Status" "PASS" "Disabled" "Bluetooth radio is safely disabled."
    fi

    # 2. USB Protection
    if systemctl is-active --quiet usbguard 2>/dev/null; then
        print_result "USBGuard" "PASS" "Active" "Protects against malicious HID/storage devices."
    else
        print_result "USBGuard" "WARN" "Inactive" "Consider installing usbguard for physical port security."
    fi

    # 3. Firejail (Application Sandboxing)
    if command -v firejail >/dev/null 2>&1; then
        print_result "Firejail Sandbox" "PASS" "Installed" "Enhances browser/app security via sandboxing."
    else
        print_result "Firejail Sandbox" "WARN" "Missing" "Consider for extra browser & app isolation."
    fi
    
    print_footer
}

check_privileges() {
    print_header "Privilege & Permission Audit"
    
    # Check sudoers for NOPASSWD
    if sudo -n -l 2>/dev/null | grep -q "NOPASSWD: ALL"; then
        print_result "Sudo NOPASSWD" "FAIL" "Enabled (ALL)" "Critical risk: any script can gain root without prompt."
    elif sudo -n -l 2>/dev/null | grep -q "NOPASSWD:"; then
        print_result "Sudo NOPASSWD" "WARN" "Specific deps" "Some commands run without sudo. Risk of breakout."
    else
        print_result "Sudo NOPASSWD" "PASS" "None found" "Requires password for all administrative actions."
    fi

    # World writable files in sensitive areas
    local ww_dirs=("/opt" "/usr/local/bin")
    for dir in "${ww_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local ww_count
            ww_count=$(find "$dir" -maxdepth 2 -type d -perm -0002 2>/dev/null | wc -l)
            if [ "$ww_count" -gt 0 ]; then
                print_result "World Writable $dir" "FAIL" "$ww_count found" "Risk of file injection."
            else
                print_result "World Writable $dir" "PASS" "None" "Permissions restricted."
            fi
        fi
    done
    print_footer
}

check_network() {
    print_header "Network Services Audit"
    
    # Check listening ports
    if command -v ss > /dev/null 2>&1; then
        local listening_count
        listening_count=$(ss -tuln | grep "LISTEN" | grep -v "127.0.0.1" | grep -v "::1" | wc -l)
        if [ "$listening_count" -gt 3 ]; then
            print_result "External Services" "WARN" "$listening_count ports" "Workstations should run minimal network services."
        else
            print_result "External Services" "PASS" "$listening_count ports" "Minimal set of services exposed to network."
        fi
    fi

    if command -v ufw > /dev/null 2>&1 && sudo ufw status 2>/dev/null | grep -q "active"; then
        print_result "UFW Status" "PASS" "Active" "Restricts unsolicited inbound network traffic."
    else
        print_result "UFW Status" "FAIL" "Inactive" "System exposed to all local network traffic."
    fi

    if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
        print_result "Auto-Upgrades" "PASS" "Enabled" "Security patches are applied automatically."
    else
        print_result "Auto-Upgrades" "FAIL" "Missing" "Manual patching prone to being forgotten."
    fi
    print_footer
}

check_sysctl() {
    print_header "Kernel Hardening (sysctl)"
    
    local checks=(
        "net.ipv4.tcp_syncookies=1|TCP SYN Cookies|Protects against SYN flood (DDoS) attacks."
        "kernel.randomize_va_space=2|ASLR Status|Randomizes memory addresses to block buffer overflows."
        "kernel.kptr_restrict=2|Kernel Pointer|Hides kernel addresses from unprivileged users."
        "kernel.perf_event_paranoid=3|Perf Events|Limits performance counter access (mitigates side-channels)."
        "kernel.unprivileged_bpf_disabled=1|Unpriv BPF|Hardens against BPF-based kernel exploits."
        "kernel.yama.ptrace_scope=1|Ptrace Scope|Restricts process debugging/inspection (prevents scraping)."
    )

    for c in "${checks[@]}"; do
        key=${c%%=*}
        rest=${c#*=}
        val=${rest%%|*}
        rest2=${rest#*|}
        name=${rest2%%|*}
        exp=${rest2#*|}
        
        actual=$(sysctl -n "$key" 2>/dev/null)
        
        if [ -z "$actual" ]; then
            print_result "$name" "FAIL" "No Value" "$exp"
        elif [ "$actual" == "$val" ]; then
            print_result "$name" "PASS" "Match ($actual)" "$exp"
        else
            print_result "$name" "FAIL" "Got $actual" "$exp"
        fi
    done
    print_footer
}

print_summary() {
    echo -e "\n${BOLD}${BLUE}╔═════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║                            WORKSTATION SECURITY AUDIT SUMMARY                           ║${NC}"
    echo -e "${BOLD}${BLUE}╠═════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    printf "${BOLD}${BLUE}║${NC} %-87s ${BOLD}${BLUE}║${NC}\n" " Total Checks: $TOTAL_CHECKS"
    printf "${BOLD}${BLUE}║${NC} %b%-87s%b ${BOLD}${BLUE}║${NC}\n" "$GREEN" " Passed:       $PASSED_CHECKS" "$NC"
    printf "${BOLD}${BLUE}║${NC} %b%-87s%b ${BOLD}${BLUE}║${NC}\n" "$RED" " Failed:       $FAILED_CHECKS" "$NC"
    printf "${BOLD}${BLUE}║${NC} %b%-87s%b ${BOLD}${BLUE}║${NC}\n" "$YELLOW" " Warnings:     $WARNED_CHECKS" "$NC"
    echo -e "${BOLD}${BLUE}╚═════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    if [ "$FAILED_CHECKS" -gt 0 ]; then
        echo -e "\n${RED}${BOLD}ATTENTION:${NC} Critical security issues found on this workstation."
    else
        echo -e "\n${GREEN}${BOLD}WELL DONE:${NC} This laptop meets high security standards."
    fi
}

# Main execution
clear
echo -e "${BOLD}${BLUE}Starting Workstation Security Audit...${NC}"

check_physical_boot
check_desktop_security
check_ssh_client
check_hardware_os
check_privileges
check_network
check_sysctl

print_summary
