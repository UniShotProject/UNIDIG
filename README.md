# 🧠 UNIDIG - Automated Reconnaissance Script


**UNIDIG** is a powerful and automated reconnaissance script written in Bash, designed to collect subdomains and relevant information for bug bounty and pentesting purposes. It integrates multiple tools, merges results, filters duplicates, and optionally resolves IPs.

---

## 🚀 Features

- Enumerates subdomains using:
  - Amass
  - Subfinder
  - Assetfinder
  - crt.sh
  - dnscan
- Supports custom wordlists
- Merges and deduplicates results automatically
- Optionally resolves subdomains to IPs using `dnsx`
- Supports single or multiple domains
- Can merge external subdomain files
- Clean and organized output

---

## ⚙️ Requirements

Ensure the following tools are installed and accessible in your `$PATH`:

```bash
subfinder assetfinder amass ffuf python3 httpx dirsearch waybackurls katana anew jq curl dnsx
```

Example install (partial):

```bash
sudo apt install -y amass jq curl python3
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/assetfinder@latest
```

> Make sure `dnscan` is cloned and located at:
```bash
~/tools/dnscan/dnscan.py
```

---

## 🧪 Usage

Make the script executable:

```bash
chmod +x unidig.sh
./unidig.sh [options]
```

### ✅ Options:

| Flag | Description |
|------|-------------|
| `-d domain.com` | Target single domain |
| `-l domains.txt` | File containing list of domains |
| `-f subdomains.txt` | File to merge with the results |
| `-w wordlist.txt` | Custom wordlist for dnscan |
| `-i` | Resolve IPs using dnsx |

### 🔁 Examples:

- Scan a single domain:
```bash
./unidig.sh -d example.com
```

- Scan a list of domains and resolve IPs:
```bash
./unidig.sh -l domains.txt -i
```

- Use a custom wordlist:
```bash
./unidig.sh -d example.com -w ~/wordlists/custom.txt
```

- Merge external subdomains file:
```bash
./unidig.sh -d example.com -f old_subs.txt
```

---

## 📁 Output Files

| File | Description |
|------|-------------|
| `subdomains.txt` | Final list of filtered subdomains |
| `IPs.txt` | Resolved IP addresses (if `-i` is used) |
| `amass.txt`, `subfinder.txt`, etc. | Tool-specific raw output |
| `all_subdomains.txt` | All merged subdomains before filtering |

---

## 👨‍💻 Author

Developed by **MON3M**  
Contact: [Mahmed.ismail14@gmail.com](mailto:Mahmed.ismail14@gmail.com)
LinkedIn: https://www.linkedin.com/in/mohamed-abd-el-moneam-162933315?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app

---

## ⚠️ Disclaimer

This tool is intended **for educational and authorized security testing purposes only**. Unauthorized usage is strictly prohibited and the author assumes no responsibility for misuse.
