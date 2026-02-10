# MRZ SSL Manager

![Version](https://img.shields.io/badge/version-2.1-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**MRZ SSL Manager** is an automated SSL management tool. **Version 2.1** now supports Port 443 (TLS-ALPN) for environments where Port 80 is restricted.

---

## 🚀 Features
- **New: Port 443 (TLS-ALPN) Support** (Use if Port 80 is blocked).
- **Auto-Detection:** Detects and stops conflicting services on Port 80 or 443.
- **Marzban Integration:** Auto-installs to `/var/lib/marzban/certs`.
- **Easy CLI:** Simply type `mrz-ssl` to manage everything.

---

## 📥 Installation

```bash
bash <(curl -Ls https://raw.githubusercontent.com/ReasModeUs/mrz-script/main/mrz-ssl.sh)
