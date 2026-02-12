#!/bin/bash
# OpsDesk CTF Web Setup Script
# Run on Web VM (192.168.0.50)

set -e

echo "[*] Setting up OpsDesk CTF Web Application..."

# Install dependencies if missing
if ! command -v sqlite3 &> /dev/null; then
    echo "[*] Installing dependencies..."
    apt-get update
    apt-get install -y apache2 php php-sqlite3 sqlite3
fi

# Create opsuser FIRST (before creating their files)
echo "[*] Creating opsuser..."
if ! id "opsuser" &>/dev/null; then
    useradd -m -s /bin/bash opsuser
    echo 'opsuser:0psD3skUs3r!' | chpasswd
    echo "[+] User opsuser created"
else
    echo "[!] User opsuser already exists, updating password..."
    echo 'opsuser:0psD3skUs3r!' | chpasswd
fi

# Create directory structure
echo "[*] Creating directories..."
mkdir -p /var/www/opsdesk/{public,staff,uploads,db,includes,config}

# Create database
echo "[*] Creating SQLite database..."
cd /var/www/opsdesk/db
if [ ! -f opsdesk.db ]; then
    sqlite3 opsdesk.db < schema.sql
    sqlite3 opsdesk.db < seed.sql
    echo "[+] Database created"
else
    echo "[!] Database already exists, skipping"
fi

# Set permissions (web server owns app files)
echo "[*] Setting permissions..."
chown -R www-data:www-data /var/www/opsdesk
chmod 755 /var/www/opsdesk
chmod 775 /var/www/opsdesk/uploads
chmod 775 /var/www/opsdesk/db
chmod 664 /var/www/opsdesk/db/opsdesk.db
find /var/www/opsdesk -type f -name "*.php" -exec chmod 644 {} \;
find /var/www/opsdesk -type f -name "*.sql" -exec chmod 644 {} \;

# Ensure .htaccess exists in uploads for PHP execution vulnerability
if [ ! -f /var/www/opsdesk/uploads/.htaccess ]; then
    echo "# Vulnerable .htaccess - Forces PHP execution" > /var/www/opsdesk/uploads/.htaccess
    echo "<FilesMatch \".*\">" >> /var/www/opsdesk/uploads/.htaccess
    echo "    SetHandler application/x-httpd-php" >> /var/www/opsdesk/uploads/.htaccess
    echo "</FilesMatch>" >> /var/www/opsdesk/uploads/.htaccess
fi
chown www-data:www-data /var/www/opsdesk/uploads/.htaccess
chmod 644 /var/www/opsdesk/uploads/.htaccess

# Configure Apache
echo "[*] Configuring Apache..."
if [ -f /var/www/opsdesk/config/opsdesk.conf ]; then
    cp /var/www/opsdesk/config/opsdesk.conf /etc/apache2/sites-available/
fi

a2ensite opsdesk 2>/dev/null || true
a2dissite 000-default 2>/dev/null || true
a2enmod php* 2>/dev/null || a2enmod php8.1 2>/dev/null || a2enmod php7.4 2>/dev/null || true
a2enmod headers 2>/dev/null || true

# Test Apache config
apache2ctl configtest || true

# Restart Apache
echo "[*] Restarting Apache..."
systemctl restart apache2
systemctl enable apache2

# Create flags
echo "[*] Creating flags..."
echo "CTF{u5er_fl4g_f0r_0psd3sk}" > /home/opsuser/user.txt
chown opsuser:opsuser /home/opsuser/user.txt
chmod 640 /home/opsuser/user.txt

echo "CTF{r00t_pr1v3sc_0psd3sk_d0n3}" > /root/root.txt
chmod 600 /root/root.txt

echo ""
echo "[+] Setup complete!"
echo ""
echo "==================================="
echo "Access points:"
echo "  - Public (decoy):  http://$(hostname -I | awk '{print $1}')/"
echo "  - Staff (real):    http://$(hostname -I | awk '{print $1}'):5000/"
echo ""
echo "Admin Creds: admin / OpsDesk2024!Admin"
echo "SSH Creds:   opsuser / 0psD3skUs3r!"
echo "==================================="
