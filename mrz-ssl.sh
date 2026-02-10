#!/bin/bash

# ==========================================================
# MRZ SSL Manager
# Copyright (c) 2026 ReasModeUs
# GitHub: https://github.com/ReasModeUs
# ==========================================================

SCRIPT_PATH="/usr/local/bin/mrz-ssl"
LOG_FILE="/var/log/mrz-ssl.log"
ACME_SCRIPT="$HOME/.acme.sh/acme.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check Root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error: This script must be run as root.${NC}" && exit 1

# --- Helper Functions ---

log_info() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
    echo -e "${GREEN}$msg${NC}"
    echo "$msg" >> "$LOG_FILE"
}

log_warn() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1"
    echo -e "${YELLOW}$msg${NC}"
    echo "$msg" >> "$LOG_FILE"
}

log_err() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1"
    echo -e "${RED}$msg${NC}"
    echo "$msg" >> "$LOG_FILE"
}

install_dependencies() {
    log_info "Checking dependencies..."
    if ! command -v socat &> /dev/null || ! command -v lsof &> /dev/null; then
        apt-get update -qq && apt-get install -y socat lsof curl tar cron &> /dev/null
        log_info "Dependencies installed."
    fi

    if [[ ! -f "$ACME_SCRIPT" ]]; then
        log_info "Installing acme.sh..."
        curl -s https://get.acme.sh | sh &> /dev/null
    fi
}

check_port_80() {
    log_info "Checking Port 80 availability..."
    local conflict_pid
    conflict_pid=$(lsof -t -i:80 -sTCP:LISTEN)

    if [[ -n "$conflict_pid" ]]; then
        local process_name
        process_name=$(ps -p "$conflict_pid" -o comm=)
        log_warn "Port 80 is currently held by process: $process_name (PID: $conflict_pid)"
        
        # Try graceful stop for common servers
        if systemctl is-active --quiet nginx; then
            systemctl stop nginx
            log_info "Stopped Nginx service."
        elif systemctl is-active --quiet apache2; then
            systemctl stop apache2
            log_info "Stopped Apache2 service."
        else
            log_warn "Force killing process $conflict_pid..."
            kill -9 "$conflict_pid"
        fi
        
        # Double check
        sleep 2
        if lsof -t -i:80 -sTCP:LISTEN &> /dev/null; then
            log_err "Failed to free Port 80. Please check logs manually."
            return 1
        fi
    else
        log_info "Port 80 is free."
    fi
    return 0
}

deploy_marzban() {
    local cert=$1
    local key=$2
    local target="/var/lib/marzban/certs"
    
    mkdir -p "$target"
    cp "$cert" "$target/fullchain.pem"
    cp "$key" "$target/key.pem"
    log_info "Certificates deployed to $target"
    
    if command -v docker &> /dev/null; then
        log_info "Restarting Marzban container..."
        docker restart marzban &> /dev/null || log_warn "Marzban container not found/running."
    fi
}

deploy_generic() {
    local cert=$1
    local key=$2
    local target="/root/certs"
    
    mkdir -p "$target"
    cp "$cert" "$target/public.crt"
    cp "$key" "$target/private.key"
    chmod 644 "$target/public.crt"
    chmod 644 "$target/private.key"
    
    echo -e "\n${CYAN}==============================================${NC}"
    echo -e " Certificates saved successfully!"
    echo -e " Public Cert : ${YELLOW}$target/public.crt${NC}"
    echo -e " Private Key : ${YELLOW}$target/private.key${NC}"
    echo -e "${CYAN}==============================================${NC}\n"
    log_info "Certificates saved to $target"
}

issue_cert() {
    local domain=$1
    local panel=$2

    check_port_80 || exit 1
    
    log_info "Issuing certificate for $domain using ZeroSSL..."
    "$ACME_SCRIPT" --register-account -m "admin@$domain" --server zerossl &> /dev/null
    
    if "$ACME_SCRIPT" --issue -d "$domain" --standalone --force; then
        log_info "Certificate issued successfully."
        
        local cert_path="$HOME/.acme.sh/${domain}_ecc/fullchain.cer"
        local key_path="$HOME/.acme.sh/${domain}_ecc/${domain}.key"
        
        case $panel in
            1) deploy_marzban "$cert_path" "$key_path" ;;
            *) deploy_generic "$cert_path" "$key_path" ;;
        esac
        
        # Restart webserver if it was present
        systemctl start nginx 2>/dev/null && log_info "Nginx restarted."
        
    else
        log_err "Failed to issue certificate. Check network or Cloudflare settings."
        exit 1
    fi
}

show_menu() {
    clear
    echo -e "${CYAN}==============================================${NC}"
    echo -e " MRZ SSL Manager - v1.0"
    echo -e " ${YELLOW}https://github.com/ReasModeUs${NC}"
    echo -e "${CYAN}==============================================${NC}"
    echo "1. Request New Certificate"
    echo "2. Renew All Certificates"
    echo "3. Delete/Revoke Certificate"
    echo "4. View Logs"
    echo "5. Exit"
    echo -e "${CYAN}==============================================${NC}"
    read -rp "Select option: " opt

    case $opt in
        1)
            read -rp "Enter Domain: " domain
            [[ -z "$domain" ]] && echo "Domain required." && exit 1
            echo "Select Panel:"
            echo "1) Marzban (Auto-Install)"
            echo "2) Sanaei / PasarGuard"
            echo "3) Other (File Only)"
            read -rp "Choice [1-3]: " p_choice
            issue_cert "$domain" "$p_choice"
            ;;
        2)
            "$ACME_SCRIPT" --cron --force
            log_info "Renewal process completed."
            ;;
        3)
            read -rp "Enter Domain to remove: " domain
            "$ACME_SCRIPT" --remove -d "$domain"
            rm -rf "$HOME/.acme.sh/${domain}_ecc"
            log_info "Certificate for $domain removed."
            ;;
        4)
            cat "$LOG_FILE"
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# --- Main Installation / Execution Logic ---

# Self-Install logic
if [[ ! -f "$SCRIPT_PATH" ]] || [[ "$(realpath "$0")" != "$SCRIPT_PATH" ]]; then
    cp "$0" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    echo -e "${GREEN}Installed 'mrz-ssl' to system.${NC}"
fi

install_dependencies

# Argument Handling
if [[ $# -gt 0 ]]; then
    case $1 in
        new)
            [[ -z $2 ]] && echo "Usage: mrz-ssl new <domain>" && exit 1
            issue_cert "$2" "3" 
            ;;
        renew)
            "$ACME_SCRIPT" --cron --force
            ;;
        logs)
            tail -n 50 "$LOG_FILE"
            ;;
        *)
            echo "Usage: mrz-ssl [new|renew|logs]"
            ;;
    esac
else
    show_menu
fi
