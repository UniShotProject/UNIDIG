#!/bin/bash
set -e  # Exit on error

# Define colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
RESET='\033[0m'

# UNIDIG ASCII Banner
echo -e "${CYAN}"
cat << "EOF"
 ██╗   ██╗███╗   ██╗██╗██████╗ ██╗ ██████╗
 ██║   ██║████╗  ██║██║██╔══██╗██║██╔════╝
 ██║   ██║██╔██╗ ██║██║██║  ██║██║██║  ███╗
 ██║   ██║██║╚██╗██║██║██║  ██║██║██║   ██║
 ╚██████╔╝██║ ╚████║██║██████╔╝██║╚██████╔╝
  ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═════╝ ╚═╝ ╚═════╝
----------------------------------------------------------
                     BY MON3M
----------------------------------------------------------
EOF
echo -e "${RESET}"

echo -e "${BLUE}[*] UNIDIG - Automated Reconnaissance Script${RESET}"
echo -e "${YELLOW}[!] Make sure all required tools are installed.${RESET}"

# Get current working directory
OUTPUT_DIR=$(pwd)

# Default wordlist path
WORDLIST=~/SecLists/Discovery/DNS/subdomains-top1million-110000.txt

# Variables for user-specified file, wordlist, and IP resolution flag
USER_FILE=""
CUSTOM_WORDLIST=""
RESOLVE_IPS=false
DOMAIN=""
DOMAIN_LIST=""

# Parse command-line arguments
while getopts "d:l:f:w:i" opt; do
    case "$opt" in
        d) DOMAIN="$OPTARG" ;;   # Single domain
        l) DOMAIN_LIST="$OPTARG" ;;  # List of domains
        f) USER_FILE="$OPTARG" ;;   # File with subdomains to merge
        w) CUSTOM_WORDLIST="$OPTARG" ;;  # Custom wordlist path
        i) RESOLVE_IPS=true ;;  # Enable IP resolution
        ?) echo -e "${RED}[-] Usage: $0 [-d domain.com] [-l domains.txt] [-f subdomains.txt] [-w custom_wordlist.txt] [-i]${RESET}"
           exit 1 ;;
    esac
done

# Ensure required tools are installed
for tool in subfinder assetfinder amass ffuf python3 httpx dirsearch waybackurls katana anew jq curl dnsx; do
    if ! command -v "$tool" &>/dev/null; then
        echo -e "${RED}[-] Error: $tool is not installed!${RESET}"
        exit 1
    fi
done

# If the user provided a custom wordlist, use it instead of the default
if [[ -n "$CUSTOM_WORDLIST" ]]; then
    WORDLIST="$CUSTOM_WORDLIST"
fi

# Validate input
if [[ -z "$DOMAIN" && -z "$DOMAIN_LIST" ]]; then
    echo -e "${RED}[-] Error: You must provide either a single domain (-d) or a list of domains (-l).${RESET}"
    exit 1
fi

# Prepare domains array
declare -a domains

if [[ -n "$DOMAIN" ]]; then
    domains=("$DOMAIN")
elif [[ -f "$DOMAIN_LIST" ]]; then
    mapfile -t domains < "$DOMAIN_LIST"
else
    echo -e "${RED}[-] Error: Specified domain list file does not exist.${RESET}"
    exit 1
fi

# Ensure wordlist exists
if [[ ! -f "$WORDLIST" ]]; then
    echo -e "${RED}[-] Error: Wordlist not found at $WORDLIST${RESET}"
    exit 1
fi

# Clear output files
> "$OUTPUT_DIR/amass.txt"
> "$OUTPUT_DIR/subfinder.txt"
> "$OUTPUT_DIR/asset.txt"
> "$OUTPUT_DIR/crtsh.txt"
> "$OUTPUT_DIR/dnscan_subs.txt"
> "$OUTPUT_DIR/subdomains.txt"

# Start subdomain enumeration
echo -e "${GREEN}[+] Starting Subdomain Enumeration...${RESET}"

for target in "${domains[@]}"; do
    echo -e "${GREEN}[+] Processing: $target${RESET}"

    echo -e "${GREEN}[+] Running Amass...${RESET}"
    echo "Results for: $target" | tee -a amass.txt
    amass enum -d "$target" | tee -a amass.txt

    echo -e "${GREEN}[+] Running Subfinder...${RESET}"
    subfinder -d "$target" -all -recursive >> "$OUTPUT_DIR/subfinder.txt"

    echo -e "${GREEN}[+] Running Assetfinder...${RESET}"
    assetfinder --subs-only "$target" >> "$OUTPUT_DIR/asset.txt"

    echo -e "${GREEN}[+] Extracting subdomains from crt.sh...${RESET}"
    curl -s "https://crt.sh/?q=%25.$target&output=json" | jq -r '.[].name_value' | sort -u >> "$OUTPUT_DIR/crtsh.txt"
done

# Run dnscan
echo -e "${GREEN}[+] Running dnscan...${RESET}"
python3 ~/tools/dnscan/dnscan.py -l <(printf "%s\n" "${domains[@]}") -w "$WORDLIST" -N -r -t 300 | tee "$OUTPUT_DIR/dnscan.txt"

for domain in "${domains[@]}"; do
    grep -Eo '([a-zA-Z0-9_-]+\.)+[a-zA-Z]+' dnscan.txt | while read sub; do
        if [[ "$sub" == *.$domain ]]; then
            echo "$sub" >> dnscan_subs.txt
        fi
    done
done
echo -e "${GREEN}[✓] dnscan completed!${RESET}"

echo -e "${YELLOW}[!] Merging and Filtering Subdomains...${RESET}"

# Merge all subdomains
cat "$OUTPUT_DIR/amass.txt" \
    "$OUTPUT_DIR/subfinder.txt" \
    "$OUTPUT_DIR/asset.txt" \
    "$OUTPUT_DIR/crtsh.txt" \
    "$OUTPUT_DIR/dnscan_subs.txt" > "$OUTPUT_DIR/all_subdomains_tmp.txt"

# If user provided a subdomains file, merge it as well
if [[ -n "$USER_FILE" && -f "$USER_FILE" ]]; then
    echo -e "${GREEN}[+] Merging user-provided subdomains file: $USER_FILE${RESET}"
    cat "$USER_FILE" >> "$OUTPUT_DIR/all_subdomains_tmp.txt"
fi

# Remove duplicates and filter valid subdomains
sort -u "$OUTPUT_DIR/all_subdomains_tmp.txt" > "$OUTPUT_DIR/all_subdomains.txt"

# Filter subdomains that belong to at least one domain
> "$OUTPUT_DIR/subdomains.txt"
for domain in "${domains[@]}"; do
    grep "\.${domain}$" "$OUTPUT_DIR/all_subdomains.txt" >> "$OUTPUT_DIR/subdomains.txt"
done

sort -u -o "$OUTPUT_DIR/subdomains.txt" "$OUTPUT_DIR/subdomains.txt"

echo -e "${GREEN}[✓] Valid subdomains saved in subdomains.txt${RESET}"

# If -i flag is set, resolve subdomains to IPs
if [ "$RESOLVE_IPS" = true ]; then
    echo -e "${GREEN}[+] Resolving subdomains to IPs using dnsx...${RESET}"
    cat "$OUTPUT_DIR/subdomains.txt" | dnsx -resp-only -o "$OUTPUT_DIR/IPs.txt"
    echo -e "${GREEN}[✓] IP addresses saved in IPs.txt${RESET}"
fi
