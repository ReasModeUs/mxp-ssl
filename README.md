# MRZ SSL Manager

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**MRZ SSL Manager** is a powerful, lightweight, and automated Bash script designed to manage SSL certificates for VPS servers. It is specifically optimized for VPN panels such as **Marzban**, **Sanaei**, and **PasarGuard**.

No more manual copying of files or dealing with Port 80 errors. This script handles everything automatically.

---

## 📥 Installation

Copy and run the following command on your server (Root access required):

```bash
bash <(curl -Ls https://raw.githubusercontent.com/ReasModeUs/mrz-script/main/mrz-ssl.sh)

After installation, the script will launch automatically. For future use, simply type:

```bash
mrz-ssl

📖 How to Use (Menu)
When you run mrz-ssl, you will see the following interactive menu:
Option	Description
1) Get New Certificate	Generates an SSL certificate for your domain/subdomain.
2) View Logs	Displays the last 20 lines of the operation log for troubleshooting.
3) Renew All	Forces a renewal check for all your domains.
4) Delete Certificate	Removes the certificate and key for a specific domain.
5) Uninstall Script	Completely removes MRZ-SSL from your system.
0) Exit	Exits the script.

⚡ Quick Commands (CLI)
You can also use the script without entering the menu by using arguments:
mrz-ssl new your-domain.com
mrz-ssl logs
