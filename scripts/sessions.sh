#!/usr/bin/env bash
# Description: Session & Access Security Auditor (Aggregated Summary Engine)
# Supported: Debian 13 (Trixie), Ubuntu, Rocky Linux, CentOS
# Integration: Aggregates logs to show totals per user rather than raw lines.

# Color codes matching your ecosystem
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'

# Ensure sbin is in PATH for tracking tools
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNED_CHECKS=0

print_header() {
    echo -e "\n${BOLD}${BLUE}┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
    printf "${BOLD}${BLUE}│${NC} %-101s ${BOLD}${BLUE}│${NC}\n" "$1"
    echo -e "${BOLD}${BLUE}├────────────────────────────────────────┬──────────┬─────────────┬─────────────────────────────────────┤${NC}"
    printf "${BOLD}${BLUE}│${NC} %-38s ${BOLD}${BLUE}│${NC} %-8s ${BOLD}${BLUE}│${NC} %-11s ${BOLD}${BLUE}│${NC} %-35s ${BOLD}${BLUE}│${NC}\n" "Security Metric / Target" "Status" "Volume" "Aggregated Finding / Impact"
    echo -e "${BOLD}${BLUE}├────────────────────────────────────────┼──────────┼─────────────┼─────────────────────────────────────┤${NC}"
}

print_result() {
    local check="$1"
    local status="$2"
    local detail="$3"
    local explanation="$4"
    
    ((TOTAL_CHECKS++))
    
    case "$status" in
        "PASS") ((PASSED_CHECKS++)); status_color="${GREEN}" ;;
        "FAIL") ((FAILED_CHECKS++)); status_color="${RED}" ;;
        "WARN") ((WARNED_CHECKS++)); status_color="${YELLOW}" ;;
    esac
    
    printf "${BOLD}${BLUE}│${NC} %-38.38s ${BOLD}${BLUE}│${NC} %b%-8s%b ${BOLD}${BLUE}│${NC} %-11.11s ${BOLD}${BLUE}│${NC} %-35.35s ${BOLD}${BLUE}│${NC}\n" "$check" "$status_color" "$status" "$NC" "$detail" "$explanation"
}

print_footer() {
    echo -e "${BOLD}${BLUE}└────────────────────────────────────────┴──────────┴─────────────┴─────────────────────────────────────┘${NC}"
}

audit_system_access() {
    print_header "Authentication & Interactive Sessions Summary"

    # 1. Determine Log Engine and collect history (last 500 entries for broader statistical relevance)
    local raw_logs
    if command -v journalctl >/dev/null 2>&1; then
        raw_logs=$(sudo journalctl SYSLOG_FACILITY=4 SYSLOG_FACILITY=10 -n 500 --no-pager 2>/dev/null)
    elif [ -f /var/log/secure ]; then
        raw_logs=$(sudo tail -n 500 /var/log/secure)
    elif [ -f /var/log/auth.log ]; then
        raw_logs=$(sudo tail -n 500 /var/log/auth.log)
    else
        print_result "Log Subsystem Availability" "FAIL" "Missing" "Could not locate tracking subsystems."
        print_footer
        return
    fi

    # 2. Process metrics via internal text parsing arrays
    # Track Failed Logins per user
    mapfile -t fail_users < <(echo "$raw_logs" | grep -E "authentication failure|password check failed" | grep -oE "user=[a-zA-Z0-9_-]+" | cut -d= -f2 | sort | uniq -c)
    
    # Track Successful Sessions per user
    mapfile -t success_users < <(echo "$raw_logs" | grep "session opened" | grep -oE "user [a-zA-Z0-9_-]+" | cut -d' ' -f2 | sort | uniq -c)
    
    # Track Aborted/Timed out conversations
    local total_aborted
    total_aborted=$(echo "$raw_logs" | grep -c "conversation failed")

    # Track Root escalations specifically via sudo
    local total_sudo_attempts
    total_sudo_attempts=$(echo "$raw_logs" | grep -c "COMMAND=")

    # 3. Output Findings metrics logically

    # Evaluate Successful Logins
    if [ ${#success_users[@]} -eq 0 ]; then
        print_result "Active User Sessions" "WARN" "0 Users" "No active user connections logged recently."
    else
        for u_entry in "${success_users[@]}"; do
            local count
            count=$(echo "$u_entry" | awk '{print $1}')
            local user
            user=$(echo "$u_entry" | awk '{print $2}')
            print_result "Successful Logins ($user)" "PASS" "${count} events" "Valid active terminal interactions."
        done
    fi

    # Evaluate Failed Authentication attempts
    if [ ${#fail_users[@]} -eq 0 ]; then
        print_result "Brute Force / Typo Detection" "PASS" "0 Failures" "No credential validation errors found."
    else
        for f_entry in "${fail_users[@]}"; do
            local count
            count=$(echo "$f_entry" | awk '{print $1}')
            local user
            user=$(echo "$f_entry" | awk '{print $2}')
            
            if [ "$count" -gt 10 ]; then
                print_result "Failed Logins ($user)" "FAIL" "${count} events" "High volume! Potential brute-force attack."
            else
                print_result "Failed Logins ($user)" "WARN" "${count} events" "Low volume. Likely normal typos."
            fi
        done
    fi

    # Evaluate Password Timeouts / Ctrl+C Dropouts
    if [ "$total_aborted" -gt 0 ]; then
        print_result "Aborted Prompt Challenges" "WARN" "${total_aborted} events" "Password prompts timed out or canceled."
    else
        print_result "Aborted Prompt Challenges" "PASS" "0 events" "No canceled authentication prompts."
    fi

    # Evaluate Sudo Footprint activity
    if [ "$total_sudo_attempts" -gt 50 ]; then
        print_result "Privileged Executions (Sudo)" "WARN" "${total_sudo_attempts} cmds" "High execution rate. Review script automation."
    else
        print_result "Privileged Executions (Sudo)" "PASS" "${total_sudo_attempts} cmds" "Normal rate of administrative execution."
    fi

    print_footer
}

print_summary() {
    local total=$TOTAL_CHECKS
    local passed=$PASSED_CHECKS
    local percent=0
    if [ "$total" -gt 0 ]; then
        percent=$(( (passed * 100) / total ))
    fi

    local bar_width=20
    local filled=$(( (percent * bar_width) / 100 ))
    local empty=$(( bar_width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    echo -e "\n  ${MAGENTA}⚡ ${BOLD}ACCESS INTEGRITY SCORE${NC}  ${CYAN}[${bar}]${NC} ${WHITE}${percent}%${NC}"
    echo -e "  ${BLUE}─────────────────────────────────────────────────────────────${NC}"
    printf "  ${GREEN}✔ OPTIMAL  ${NC} %-3s  ${RED}✘ CRITICAL ${NC} %-3s  ${YELLOW}⚠ WARNINGS ${NC} %-3s\n" "$PASSED_CHECKS" "$FAILED_CHECKS" "$WARNED_CHECKS"
    echo -e "  ${BLUE}─────────────────────────────────────────────────────────────${NC}"
    echo -e "  ${WHITE}${BOLD}Source:${NC} ${BLUE}Psiloc Session Auditing Engine${NC}"
    
    if [ "$FAILED_CHECKS" -gt 0 ]; then
        echo -e "\n  ${RED}${BOLD}SECURITY ALERT:${NC} Significant authentication anomalies found. Investigate high volume targets."
    elif [ "$WARNED_CHECKS" -gt 0 ]; then
        echo -e "\n  ${YELLOW}${BOLD}SECURITY STATUS:${NC} Normal workstation activity metrics detected. Keep monitoring."
    else
        echo -e "\n  ${GREEN}${BOLD}SECURITY STATUS:${NC} Ideal state. No authentication discrepancies found."
    fi
}

# Main execution loop
clear
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}${BOLD}✘ ERROR:${NC} Access logs require root privileges. Please run with ${BOLD}sudo${NC}."
  exit 1
fi

echo -e "${BOLD}${BLUE}Starting Infrastructure Access Summary Audit...${NC}"
audit_system_access
print_summary