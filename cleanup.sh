#!/bin/bash
# CTF Machine Cleanup Script
# Removes all setup artifacts, logs, and sensitive data before deploying
# Run this before snapshotting the CTF VM

set -e

echo "=========================================="
echo "  OpsDesk CTF - Machine Cleanup Tool"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root (sudo)"
    exit 1
fi

echo "Step 1/10: Clearing shell history..."
# Clear root history
> /root/.bash_history
> /root/.zsh_history 2>/dev/null || true
> /root/.viminfo 2>/dev/null || true
history -c 2>/dev/null || true

# Clear opsuser history
if [ -f /home/opsuser/.bash_history ]; then
    > /home/opsuser/.bash_history
fi
if [ -f /home/opsuser/.zsh_history ]; then
    > /home/opsuser/.zsh_history
fi
history -c 2>/dev/null || true
log_info "Shell histories cleared"

echo ""
echo "Step 2/10: Clearing Apache logs..."
> /var/log/apache2/access.log 2>/dev/null || true
> /var/log/apache2/error.log 2>/dev/null || true
> /var/log/apache2/other_vhosts_access.log 2>/dev/null || true
> /var/log/apache2/opsdesk-access.log 2>/dev/null || true
> /var/log/apache2/opsdesk-error.log 2>/dev/null || true
> /var/log/apache2/opsdesk-staff-error.log 2>/dev/null || true
> /var/log/apache2/opsdesk-staff-access.log 2>/dev/null || true
log_info "Apache logs cleared"

echo ""
echo "Step 3/10: Clearing system logs..."
> /var/log/syslog 2>/dev/null || true
> /var/log/auth.log 2>/dev/null || true
> /var/log/kern.log 2>/dev/null || true
> /var/log/dmesg 2>/dev/null || true
> /var/log/dpkg.log 2>/dev/null || true
> /var/log/alternatives.log 2>/dev/null || true
> /var/log/cloud-init.log 2>/dev/null || true
> /var/log/cloud-init-output.log 2>/dev/null || true
# Clear rotated logs
rm -f /var/log/*.gz 2>/dev/null || true
rm -f /var/log/apache2/*.gz 2>/dev/null || true
rm -f /var/log/apt/*.gz 2>/dev/null || true
log_info "System logs cleared"

echo ""
echo "Step 4/10: Clearing temporary files..."
rm -rf /tmp/* 2>/dev/null || true
rm -rf /var/tmp/* 2>/dev/null || true
rm -rf /root/.cache/* 2>/dev/null || true
rm -rf /home/opsuser/.cache/* 2>/dev/null || true
# Clear any uploaded test files from uploads folder
rm -f /var/www/opsdesk/uploads/*.jpeg 2>/dev/null || true
rm -f /var/www/opsdesk/uploads/*.jpg 2>/dev/null || true
rm -f /var/www/opsdesk/uploads/*.png 2>/dev/null || true
rm -f /var/www/opsdesk/uploads/*.gif 2>/dev/null || true
rm -f /var/www/opsdesk/uploads/*.php 2>/dev/null || true
log_info "Temporary files cleared"

echo ""
echo "Step 5/10: Removing SSH host keys (will regenerate on boot)..."
rm -f /etc/ssh/ssh_host_* 2>/dev/null || true
log_info "SSH host keys removed (will be regenerated on next boot)"

echo ""
echo "Step 6/10: Clearing command history from memory..."
unset HISTFILE
export HISTSIZE=0
export HISTFILESIZE=0
log_info "History environment variables set"

echo ""
echo "Step 7/10: Removing sensitive configuration files..."
# Remove any backup files
find /var/www/opsdesk -name "*.bak" -delete 2>/dev/null || true
find /var/www/opsdesk -name "*.backup" -delete 2>/dev/null || true
find /var/www/opsdesk -name "*~" -delete 2>/dev/null || true
find /etc -name "*.bak" -delete 2>/dev/null || true
# Remove setup scripts from web directory
rm -f /var/www/opsdesk/setup.sh 2>/dev/null || true
log_info "Sensitive files removed"

echo ""
echo "Step 8/10: Resetting database to clean state..."
# Remove the database file (will be recreated by setup if needed)
rm -f /var/www/opsdesk/db/opsdesk.db 2>/dev/null || true
# Recreate fresh database
cd /var/www/opsdesk/db
if [ -f schema.sql ] && [ -f seed.sql ]; then
    sqlite3 opsdesk.db < schema.sql
    sqlite3 opsdesk.db < seed.sql
    chown www-data:www-data opsdesk.db
    chmod 664 opsdesk.db
    log_info "Database reset to clean state"
else
    log_warn "Schema/seed files not found, skipping database reset"
fi

echo ""
echo "Step 9/10: Setting proper permissions..."
chown -R www-data:www-data /var/www/opsdesk
chmod 755 /var/www/opsdesk
chmod 775 /var/www/opsdesk/uploads
chmod 775 /var/www/opsdesk/db
chmod 644 /var/www/opsdesk/uploads/.htaccess
# Ensure flags have correct permissions
if [ -f /home/opsuser/user.txt ]; then
    chown opsuser:opsuser /home/opsuser/user.txt
    chmod 640 /home/opsuser/user.txt
fi
if [ -f /root/root.txt ]; then
    chmod 600 /root/root.txt
fi
log_info "Permissions set"

echo ""
echo "Step 10/10: Final cleanup..."
# Sync to ensure all writes are complete
sync
# Clear swap (if any)
swapoff -a 2>/dev/null || true
swapon -a 2>/dev/null || true
log_info "Final sync complete"

echo ""
echo "=========================================="
echo "  Cleanup Complete!"
echo "=========================================="
echo ""
echo "The following has been cleared:"
echo "  ✓ Shell histories (root, opsuser)"
echo "  ✓ Apache logs"
echo "  ✓ System logs"
echo "  ✓ Temporary files"
echo "  ✓ SSH host keys (will regenerate)"
echo "  ✓ Uploaded test files"
echo "  ✓ Database reset to clean state"
echo ""
echo "Next steps:"
echo "  1. Review the system for any remaining artifacts"
echo "  2. Take a snapshot/image of the VM"
echo "  3. Deploy for CTF"
echo ""
echo "  WARNING: This script cleared sensitive data."
echo "  Make sure you've pushed all changes to GitHub!"
echo ""
