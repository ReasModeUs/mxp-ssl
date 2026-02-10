#!/bin/bash

# ==========================================================
# MXP SSL Manager (Marzban - X-UI - PasarGuard)
# Version: 1.0.1
# Copyright (c) 2026 ReasModeUs
# GitHub: https://github.com/ReasModeUs
# ==========================================================

# دستور اجرایی در ترمینال: mxp
COMMAND_NAME="mxp"
SCRIPT_PATH="/usr/local/bin/$COMMAND_NAME"
LOG_FILE="/var/log/mxp-ssl.log"
ACME_SCRIPT="$HOME/.acme.sh/acme.sh"
GITHUB_RAW="https://raw.githubusercontent.com/ReasModeUs/mrz-script/main/mxp-ssl.sh"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

# --- Initial Checks ---
[[ $EUID -ne 0 ]] && echo -e "${RED}Error: Root access required.${NC}" && exit 1

log_info() { echo -e "${GREEN}[INFO] $1${NC}"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"; }
log_err() { echo -e "${RED}[ERROR] $1${NC}"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"; }

# --- Panel Automations ---

deploy_marzban() {
    local domain=$1; local cert=$2; local key=$3
    local HOST_CERT_DIR="/var/lib/marzban/certs"
    mkdir -p "$HOST_CERT_DIR"
    cp "$cert" "$HOST_CERT_DIR/fullchain.pem"
    cp "$key" "$HOST_CERT_DIR/key.pem"
    
    local env_file=""
    for path in "/opt/marzban/.env" "/var/lib/marzban/.env" "/root/marzban/.env"; do
        [[ -f "$path" ]] && env_file="$path" && break
    done

    if [[ -n "$env_file" ]]; then
        sed -i '/UVICORN_SSL_CERTFILE/d' "$env_file"
        sed -i '/UVICORN_SSL_KEYFILE/d' "$env_file"
        printf "\nUVICORN_SSL_CERTFILE=\"/var/lib/marzban/certs/fullchain.pem\"\nUVICORN_SSL_KEYFILE=\"/var/lib/marzban/certs/key.pem\"\n" >> "$env_file"
        cd "$(dirname "$env_file")" && docker compose up -d
        log_info "Marzban auto-configured and restarted."
    fi
}

deploy_pasarguard() {
    local cert=$1; local key=$2
    if command -v pg-cli &> /dev/null; then
        pg-cli settings --ssl-cert "$cert" --ssl-key "$key"
        systemctl restart pasarguard 2>/dev/null
        log_info "PasarGuard auto-configured via pg-cli."
    else
        log_err "pg-cli not found. Certificates saved but not applied."
    fi
}

# --- Core Functions ---

issue_cert() {
    clear
    read -rp "Enter Domain: " domain
    read -rp "Enter Email: " email
    [[ -z "$email" ]] && email="admin@$domain"

    echo -e "\nChoose Your Panel:\n1) Marzban (M)\n2) PasarGuard (P)\n3) X-UI / Sanaei (X)"
    read -rp "Choice: " p_choice

    echo -e "\nChoose Method:\n1) Port 80 (Standard)\n2) Port 443 (ALPN)"
    read -rp "Choice: " m_choice

    "$ACME_SCRIPT" --set-default-ca --server letsencrypt &> /dev/null
    "$ACME_SCRIPT" --register-account -m "$email" &> /dev/null

    local port=$([[ "$m_choice" == "1" ]] && echo "80" || echo "443")
    systemctl stop nginx x-ui 3x-ui marzban pasarguard 2>/dev/null
    fuser -k "$port/tcp" 2>/dev/null
    sleep 1

    local mode_flag=$([[ "$m_choice" == "1" ]] && echo "--standalone" || echo "--alpn")

    log_info "Issuing certificate for $domain..."
    if "$ACME_SCRIPT" --issue -d "$domain" "$mode_flag" --force; then
        local cp="$HOME/.acme.sh/${domain}_ecc/fullchain.cer"
        local kp="$HOME/.acme.sh/${domain}_ecc/${domain}.key"
        
        case $p_choice in
            1) deploy_marzban "$domain" "$cp" "$kp" ;;
            2) deploy_pasarguard "$cp" "$kp" ;;
            *) 
                mkdir -p "/root/certs/$domain"
                cp "$cp" "/root/certs/$domain/public.crt"
                cp "$kp" "/root/certs/$domain/private.key"
                echo -e "${GREEN}Certs saved in /root/certs/$domain/${NC}"
                ;;
        esac
    else
        log_err "SSL issuance failed. Check DNS/Proxy."
    fi
    systemctl start x-ui 3x-ui nginx pasarguard 2>/dev/null
}

update_script() {
    log_info "Checking for updates..."
    curl -Ls "$GITHUB_RAW" -o "$SCRIPT_PATH.tmp"
    if [[ -f "$SCRIPT_PATH.tmp" ]]; then
        mv "$SCRIPT_PATH.tmp" "$SCRIPT_PATH"
        chmod +x "$SCRIPT_PATH"
        log_info "Updated to latest version. Please restart the script."
        exit 0
    else
        log_err "Update failed."
    fi
}

uninstall_script() {
    read -rp "Uninstall MXP-SSL? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        rm -f "$SCRIPT_PATH"
        echo -e "${GREEN}MXP-SSL removed.${NC}"
        exit 0
    fi
}

show_menu() {
    clear
    echo -e "${CYAN}==============================================${NC}"
    echo -e "      MXP SSL Manager  |  v1.0.1"
    echo -e "      [M]arzban - [X]-UI - [P]asarGuard"
    echo -e "${CYAN}==============================================${NC}"
    echo "1) Request New Certificate"
    echo "2) List All Certificates"
    echo "3) Renew All Certificates"
    echo "4) Update Script"
    echo "5) Uninstall Script"
    echo "0) Exit"
    echo -e "${CYAN}==============================================${NC}"
    read -rp "Select Option: " opt
    case $opt in
        1) issue_cert ;;
        2) "$ACME_SCRIPT" --list; read -p "Press Enter..."; show_menu ;;
        3) "$ACME_SCRIPT" --cron --force; read -p "Done. Press Enter..."; show_menu ;;
        4) update_script ;;
        5) uninstall_script ;;
        0) exit 0 ;;
        *) show_menu ;;
    esac
}

# --- Initial Install & Sync ---
apt-get update -qq && apt-get install -y socat lsof curl &>/dev/null
[[ ! -f "$ACME_SCRIPT" ]] && curl -s https://get.acme.sh | sh &>/dev/null

if [[ ! -f "$SCRIPT_PATH" ]] || [[ "$(realpath "$0")" != "$SCRIPT_PATH" ]]; then
    cp "$0" "$SCRIPT_PATH" && chmod +x "$SCRIPT_PATH"
fi

show_menu
