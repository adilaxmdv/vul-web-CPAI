#!/bin/bash
# Push OpsDesk CTF to GitHub (main branch)
# Repository: https://github.com/adilaxmdv/vul-web-CPA

REPO_URL="https://github.com/adilaxmdv/vul-web-CPA.git"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[*] OpsDesk CTF - GitHub Push Script${NC}"
echo -e "${YELLOW}[*] Target: github.com/adilaxmdv/vul-web-CPA${NC}"
echo ""

# Check directory
if [ ! -f "setup.sh" ] && [ ! -d "opsdesk" ]; then
    echo -e "${RED}[-] Error: Run this script from the ctf-web directory${NC}"
    exit 1
fi

# Get token securely
echo -n "Enter GitHub Personal Access Token: "
read -s TOKEN
echo ""

if [ -z "$TOKEN" ]; then
    echo -e "${RED}[-] Error: Token cannot be empty${NC}"
    exit 1
fi

# Install git if needed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}[*] Installing git...${NC}"
    apt-get update && apt-get install -y git
fi

# Configure git
git config --global user.email "ctf@opsdesk.local" 2>/dev/null || true
git config --global user.name "OpsDesk CTF" 2>/dev/null || true

# Initialize git
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}[*] Initializing git repository...${NC}"
    git init
fi

# Ensure main branch
echo -e "${YELLOW}[*] Setting up main branch...${NC}"
git checkout -b main 2>/dev/null || git checkout main 2>/dev/null || git branch -M main

# Add remote (remove old if exists)
echo -e "${YELLOW}[*] Configuring remote...${NC}"
git remote remove origin 2>/dev/null || true
git remote add origin "https://${TOKEN}@github.com/adilaxmdv/vul-web-CPA.git"

# Add files
echo -e "${YELLOW}[*] Adding files to git...${NC}"
git add .

# Show status
echo -e "${YELLOW}[*] Files to be committed:${NC}"
git status --short

echo ""
read -p "Enter commit message [Initial commit - OpsDesk CTF]: " MSG
MSG=${MSG:-"Initial commit - OpsDesk CTF"}

echo -e "${YELLOW}[*] Creating commit...${NC}"
git commit -m "$MSG" || echo -e "${YELLOW}[!] Nothing new to commit or already committed${NC}"

# Push to main
echo -e "${YELLOW}[*] Pushing to main branch on GitHub...${NC}"
if git push -u origin main; then
    echo -e "${GREEN}[+] Successfully pushed to main branch!${NC}"
else
    echo -e "${YELLOW}[!] Regular push failed, trying force push...${NC}"
    read -p "Force push to main? This overwrites remote! (y/N): " CONFIRM
    if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
        if git push -u origin main --force; then
            echo -e "${GREEN}[+] Force pushed successfully!${NC}"
        else
            echo -e "${RED}[-] Push failed completely${NC}"
        fi
    else
        echo -e "${YELLOW}[!] Push cancelled by user${NC}"
    fi
fi

# Remove token from remote for security
git remote set-url origin "$REPO_URL"

echo ""
echo -e "${GREEN}[+] Done! Repository: ${REPO_URL}${NC}"
echo -e "${GREEN}[+] Token removed from remote URL for security${NC}"
