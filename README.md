# UNIDIG

UNIDIG is a powerful and automated reconnaissance script written in Bash, designed to collect subdomains and relevant information for bug bounty and pentesting purposes. It integrates multiple tools, merges results, filters duplicates, and optionally resolves IPs.

🚀 Features:
1. Enumerates subdomains using:
     a. Amass
   
     b. Subfinder
   
     c. Assetfinder
   
     d. crt.sh
   
     e. dnscan
   
3.  Supports custom wordlists
4.  Merges and deduplicates results automatically
5.  Optionally resolves subdomains to IPs using dnsx
6.  Supports single or multiple domains
7.  Can merge external subdomain files
8.  Clean and organized output

 ⚙️ Requirements:
 Ensure the following tools are installed and accessible in your $PATH:
 
 subfinder assetfinder amass ffuf python3 httpx dirsearch waybackurls katana anew jq curl dnsx

Make sure dnscan is cloned and located at ~/tools/dnscan/dnscan.py or edit the script with it's location

  🧪 Usage:
  
  chmod +x unidig.sh
  
./unidig.sh [options]

✅ Options:
Flag ------------------------------- Description

-d domain.com ---------------------- Target single domain

-l domains.txt --------------------- File containing list of domains

-f subdomains.txt ------------------ File to merge with the results

-w wordlist.txt -------------------- Custom wordlist for dnscan

-i	Resolve IPs -------------------- using dnsx

📁 Output Files:

File ------------------------------- Description

subdomains.txt ------------------------------- Final list of filtered subdomains

IPs.txt ------------------------------- Resolved IP addresses (if -i is used)

amass.txt, subfinder.txt, etc. ------------------------------- Tool-specific raw output

all_subdomains.txt ------------------------------- All merged subdomains before filtering


👨‍💻 Author

Developed by MON3M

Contact: Mahmed.ismail14@gmail.com 

LinkedIn: https://www.linkedin.com/in/mohamed-abd-el-moneam-162933315?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app
