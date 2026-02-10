# MRZ SSL Manager

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**MRZ SSL Manager** is a powerful, lightweight, and automated Bash script designed to manage SSL certificates for VPS servers. It is specifically optimized for VPN panels such as **Marzban**, **Sanaei**, and **PasarGuard**.

No more manual copying of files or dealing with Port 80 errors. This script handles everything automatically.

---

## 🚀 Features

- **✅ Automated Installation:** Installs `acme.sh` and necessary dependencies automatically.
- **🛡️ Smart Port 80 Handling:** Automatically detects if Port 80 is occupied (by Nginx, Apache, or Xray), frees it temporarily to issue the certificate, and restores it.
- **🤖 Marzban Support:** Automatically places certificates in `/var/lib/marzban/certs` and restarts the container.
- **📂 Universal Support:** Supports Sanaei, PasarGuard, and any other X-UI fork by saving certs to a standard directory.
- **📜 Log System:** Built-in logging system to troubleshoot any errors.
- **🇬🇧 English Interface:** Clean, professional CLI with no confusing text.

---

## 📥 Installation

Copy and run the following command on your server (Root access required):

```bash
bash <(curl -Ls https://raw.githubusercontent.com/ReasModeUs/mrz-script/main/mrz-ssl.sh)
