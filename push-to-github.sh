#!/bin/bash
# Push OpsDesk CTF to GitHub
# Usage: ./push-to-github.sh

REPO_URL="https://github.com/adilaxmdv/vuln-web-CPAI.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[*] OpsDesk CTF - GitHub Push Script${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "setup.sh" ] && [ ! -d "opsdesk" ]; then
    echo -e "${RED}[-] Error: Run this script from the ctf-web directory${NC}"
    echo "   (where setup.sh and opsdesk/ folder are located)"
    exit 1
fi

# Get GitHub token securely
echo -n "Enter GitHub Personal Access Token: "
read -s TOKEN
echo ""

if [ -z "$TOKEN" ]; then
    echo -e "${RED}[-] Error: Token cannot be empty${NC}"
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}[*] Installing git...${NC}"
    apt-get update && apt-get install -y git
fi

# Configure git if not already set
if [ -z "$(git config --global user.email 2>/dev/null)" ]; then
    echo -e "${YELLOW}[*] Configuring git...${NC}"
    git config --global user.email "ctf@opsdesk.local"
    git config --global user.name "OpsDesk CTF"
fi

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}[*] Initializing git repository...${NC}"
    git init
fi

# Add remote
echo -e "${YELLOW}[*] Adding remote repository...${NC}"
git remote remove origin 2>/dev/null || true
git remote add origin "https://${TOKEN}@github.com/adilaxmdv/vuln-web-CPAI.git"

# Check what's new
echo -e "${YELLOW}[*] Checking files to commit...${NC}"
git status --short

# Add all files
echo -e "${YELLOW}[*] Adding files...${NC}"
git add .

# Commit
echo ""
read -p "Enter commit message [Initial commit - OpsDesk CTF]: " MSG
MSG=${MSG:-"Initial commit - OpsDesk CTF"}

echo -e "${YELLOW}[*] Committing...${NC}"
git commit -m "$MSG" || echo -e "${YELLOW}[!] Nothing to commit or commit already exists${NC}"

# Push
echo -e "${YELLOW}[*] Pushing to GitHub...${NC}"
if git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null; then
    echo -e "${GREEN}[+] Successfully pushed to GitHub!${NC}"
    echo ""
    echo -e "${GREEN}Repository: ${REPO_URL}${NC}"
else
    echo -e "${RED}[-] Push failed. Trying force push...${NC}"
    read -p "Force push? This will overwrite remote! (y/N): " CONFIRM
    if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
        git push -u origin main --force 2>/dev/null || git push -u origin master --force
        echo -e "${GREEN}[+] Force push complete!${NC}"
    else
        echo -e "${YELLOW}[!] Push cancelled${NC}"
    fi
fi

# Remove token from remote URL (security)
git remote set-url origin "$REPO_URL"

echo ""
echo -e "${GREEN}[+] Done! Token removed from remote URL for security.${NC}"
