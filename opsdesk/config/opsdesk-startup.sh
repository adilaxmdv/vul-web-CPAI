#!/bin/bash
# OpsDesk Startup Script - Runs on every boot
# Place in /etc/init.d/ or /etc/rc.local or as systemd service

# Fix permissions
chown -R www-data:www-data /var/www/opsdesk
chmod 775 /var/www/opsdesk/uploads
chmod 775 /var/www/opsdesk/db

# Ensure database exists
if [ ! -f /var/www/opsdesk/db/opsdesk.db ]; then
    cd /var/www/opsdesk/db
    sqlite3 opsdesk.db < schema.sql
    sqlite3 opsdesk.db < seed.sql
    chown www-data:www-data opsdesk.db
    chmod 664 opsdesk.db
fi

# Ensure database is writable
chmod 664 /var/www/opsdesk/db/opsdesk.db

# Restart Apache clean
systemctl restart apache2

exit 0
