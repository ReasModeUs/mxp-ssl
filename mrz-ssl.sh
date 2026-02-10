#!/bin/bash

# ==========================================================
# MRZ SSL Manager - v3.0 (Official Marzban Docs Edition)
# Copyright (c) 2026 ReasModeUs
# GitHub: https://github.com/ReasModeUs
# ==========================================================

SCRIPT_PATH="/usr/local/bin/mrz-ssl"
LOG_FILE="/var/log/mrz-ssl.log"
ACME_SCRIPT="$HOME/.acme.sh/acme.sh"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

[[ $EUID -ne 0 ]] && echo -e "${RED}Error: Root access required.${NC}" && exit 1

log_info() { echo -e "${GREEN}[INFO] $1${NC}"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"; }

deploy_marzban_official() {
    local domain=$1; local cert=$2; local key=$3
    
    # 1. Official paths from Marzban docs
    local HOST_CERT_DIR="/var/lib/marzban/certs"
    mkdir -p "$HOST_CERT_DIR"
    
    cp "$cert" "$HOST_CERT_DIR/fullchain.pem"
    cp "$key" "$HOST_CERT_DIR/key.pem"
    
    # 2. Finding the .env file (Checking common install locations)
    local env_file=""
    for path in "/opt/marzban/.env" "/var/lib/marzban/.env" "/root/marzban/.env"; do
        if [[ -f "$path" ]]; then env_file="$path"; break; fi
    done

    if [[ -n "$env_file" ]]; then
        log_info "Updating .env at $env_file"
        
        # Remove existing SSL variables to prevent duplication
        sed -i '/UVICORN_SSL_CERTFILE/d' "$env_file"
        sed -i '/UVICORN_SSL_KEYFILE/d' "$env_file"
        
        # Add variables according to official examples
        echo "UVICORN_SSL_CERTFILE=\"/var/lib/marzban/certs/fullchain.pem\"" >> "$env_file"
        echo "UVICORN_SSL_KEYFILE=\"/var/lib/marzban/certs/key.pem\"" >> "$env_file"
        
        # 3. Restarting Marzban
        log_info "Restarting Marzban via Docker Compose..."
        cd "$(dirname "$env_file")" && docker compose up -d
        echo -e "${GREEN}Marzban is now configured with SSL (Official Method).${NC}"
    else
        echo -e "${YELLOW}Warning: .env file not found. Certs copied to $HOST_CERT_DIR. Please update your .env manually.${NC}"
    fi
}

issue_cert() {
    clear
    read -rp "Enter Domain: " domain
    read -rp "Enter Email: " email
    [[ -z "$email" ]] && email="admin@$domain"

    echo -e "Select Panel:\n1) Marzban (Auto-deploy)\n2) Sanaei/Other (Manual Path)"
    read -rp "Choice: " p_choice

    # Switch to Let's Encrypt and release ports
    "$ACME_SCRIPT" --set-default-ca --server letsencrypt &> /dev/null
    "$ACME_SCRIPT" --register-account -m "$email" &> /dev/null
    
    # Freeing Port 80
    systemctl stop nginx x-ui 3x-ui marzban 2>/dev/null
    fuser -k 80/tcp 2>/dev/null
    sleep 1

    log_info "Requesting SSL for $domain..."
    if "$ACME_SCRIPT" --issue -d "$domain" --standalone --force; then
        local cp="$HOME/.acme.sh/${domain}_ecc/fullchain.cer"
        local kp="$HOME/.acme.sh/${domain}_ecc/${domain}.key"
        
        if [[ "$p_choice" == "1" ]]; then
            deploy_marzban_official "$domain" "$cp" "$kp"
        else
            mkdir -p "/root/certs/$domain"
            cp "$cp" "/root/certs/$domain/public.crt"
            cp "$kp" "/root/certs/$domain/private.key"
            echo -e "${GREEN}Success! Paths for your panel:${NC}"
            echo -e "Public Cert: /root/certs/$domain/public.crt"
            echo -e "Private Key: /root/certs/$domain/private.key"
        fi
    else
        echo -e "${RED}SSL issue failed. Ensure Cloudflare Proxy is OFF.${NC}"
    fi
    systemctl start x-ui 3x-ui nginx 2>/dev/null
}

show_menu() {
    clear
    echo -e "${CYAN}MRZ SSL Manager v3.0 (Official Support)${NC}"
    echo "1) Get New SSL Certificate"
    echo "2) List All Certificates"
    echo "0) Exit"
    read -rp "Option: " opt
    case $opt in
        1) issue_cert ;;
        2) "$ACME_SCRIPT" --list; read -p "Press Enter..."; show_menu ;;
        0) exit 0 ;;
        *) show_menu ;;
    esac
}

# Auto-update Script to System
install_deps() {
    apt-get update -qq && apt-get install -y socat lsof curl &>/dev/null
    [[ ! -f "$ACME_SCRIPT" ]] && curl -s https://get.acme.sh | sh &>/dev/null
    [[ ! -f "$SCRIPT_PATH" ]] && cp "$0" "$SCRIPT_PATH" && chmod +x "$SCRIPT_PATH"
}

install_deps
show_menu
