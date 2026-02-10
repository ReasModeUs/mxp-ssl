# MRZ SSL Manager (v2.1)

A professional SSL management tool for VPS, optimized for VPN panels.

## 📥 Installation

Run the following command to download and start the manager:

```bash
curl -Ls https://raw.githubusercontent.com/ReasModeUs/mrz-script/main/mrz-ssl.sh -o mrz-ssl.sh && chmod +x mrz-ssl.sh && ./mrz-ssl.sh
```
Once installed, you can simply run it anytime by typing:
```
mrz-ssl
```
## 🚀 Features
Dual Port Support: Choose between Port 80 or Port 443 (TLS-ALPN) for validation.
Auto-Kill: Automatically stops Nginx, X-UI, or Marzban to free up ports during issuance.
Marzban Integration: Auto-copies certs and restarts the container.
Multi-Domain: Saves certs in separate folders for multiple domains.

## 🛡️ Firewall Setup
Make sure your server's firewall allows incoming traffic on ports 80 and 443:
```
ufw allow 80/tcp
ufw allow 443/tcp
ufw reload
```
