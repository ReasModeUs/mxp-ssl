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
code
Bash
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
1. Get a Certificate Quickly
code
Bash
mrz-ssl new your-domain.com
2. Check Logs
code
Bash
mrz-ssl logs
3. Uninstall the Tool
code
Bash
mrz-ssl uninstall
📂 Certificate Paths
Based on the panel you choose during installation:
Marzban:
Files are auto-copied to: /var/lib/marzban/certs/
Filenames: fullchain.pem, key.pem
Sanaei / PasarGuard / Others:
Files are saved at: /root/certs/
Public Cert: public.crt
Private Key: private.key
Note: You must copy these paths into your panel settings.
⚠️ Troubleshooting
Q: The script fails to get a certificate.
Make sure your DNS (A Record) points to your server IP.
If you are using Cloudflare, turn OFF the proxy (Orange Cloud) temporarily. It must be DNS Only (Grey Cloud).
Check the logs using option 2 in the menu.
Q: My Webserver (Nginx) stopped working.
The script tries to restart Nginx automatically. If it fails, simply run:
code
Bash
systemctl start nginx
🗑️ Uninstall
If you no longer need this tool, select Option 5 from the menu or run:
code
Bash
rm -f /usr/local/bin/mrz-ssl
Copyright (c) 2024 ReasModeUs
Developed for the community.
code
Code
۶. بعد از اینکه متن بالا را پیست کردید، دکمه سبز **Commit changes** (پایین صفحه سمت راست) را بزنید.

---

### نتیجه چه می‌شود؟
حالا اگر به صفحه اول گیت‌هاب خود برگردید، می‌بینید که پایین صفحه یک راهنمای بسیار شیک، دارای جدول (برای توضیح دکمه‌های ۱، ۲ و...) و دستورات نصب اضافه شده است. این باعث می‌شود پروژه شما کاملاً حرفه‌ای به نظر برسد.
