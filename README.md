# MXP SSL Manager (v1.0.4)

![Version](https://img.shields.io/badge/version-1.0.4-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Shell](https://img.shields.io/badge/shell-bash-orange.svg)

**MXP-SSL** is a creative and automated SSL management tool for VPS servers, specifically designed to integrate with:
- **M**arzban
- **X**-UI (Sanaei / 3x-ui)
- **P**asarGuard

---

## 📥 Installation

Run the following command to download and install **MXP**:

```bash
curl -Ls https://raw.githubusercontent.com/ReasModeUs/mrz-script/main/mxp-ssl.sh -o mxp-ssl.sh && chmod +x mxp-ssl.sh && ./mxp-ssl.sh
```
## Once installed, you can simply type mxp anywhere in your terminal to open the manager:
``` mxp ```

## 🚀 Key Features
#### 🌐 Multi-Domain Support (SAN): Issue a single certificate valid for multiple subdomains (e.g., sub1.site.com, sub2.site.com).
#### 🤖 Marzban Auto-Deploy: Automatically updates .env, copies certificates, and restarts the Docker container.
#### 🛡️ PasarGuard Integration: Deploys certificates to /var/lib/pasarguard/certs and restarts the service automatically.
#### ⚡ X-UI / Sanaei Ready: Generates certificates compatible with any X-UI fork.
#### Smart Port Management: Automatically detects and stops conflicting services on ports 80 or 443 during issuance.
#### Revoke & Delete: Easily revoke invalid certificates and clean up files from the menu.

## 📖 How to Use
Run ```mxp```
Choose Mode:
Option 1: Single Domain (Best for simple setups).
Option 2: Multi-Domain (Best for CDN/Reality setups with multiple SNIs).
Enter your domain(s) and email.
Select your panel (Marzban, PasarGuard, or None).
Choose validation method:
Port 80 (Standard): Requires port 80 to be open.
Port 443 (ALPN): Requires port 443 to be open.
wf Certificate Paths
## By default, certificates are saved in:
General: ```/root/certs/<your-domain>/```
Marzban: ```/var/lib/marzban/certs/```
PasarGuard: ```/var/lib/pasarguard/certs/```
## 🔄 Update & Uninstall
You can update the script to the latest version or uninstall it completely directly from the main menu.
