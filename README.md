# OpsDesk CTF Lab

A vulnerable web application for CTF practice. Part of a multi-VM lab environment.

## Network Topology

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Attacker VM    │────▶│   Git VM        │────▶│   Web VM        │
│  192.168.0.100  │     │  192.168.0.200  │     │  192.168.0.50   │
│                 │     │  (Gitea)        │     │  (OpsDesk App)  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Attack Chain

1. **Git Exposure** (Git VM: 192.168.0.200)
   - Access Gitea repository
   - Find committed credentials in old config files
   - Admin password: `OpsDesk2024!Admin`

2. **Login** (Web VM: 192.168.0.50:5000)
   - Real admin portal on port 5000
   - Vulnerable to SQL injection (alternative path)
   - Use found creds: admin / OpsDesk2024!Admin

3. **Upload Vulnerability** (Foothold)
   - Upload feature has weak extension check
   - **Bypass**: Use double extension like `shell.php.jpg` or `shell.phtml`
   - Files stored in `/uploads/` (web accessible)

4. **Database Access**
   - SQLite DB location: `/var/www/opsdesk/db/opsdesk.db`
   - Contains SSH credentials table

5. **SSH Pivot**
   - Extract creds: opsuser / 0psD3skUs3r!
   - SSH to 192.168.0.50 as opsuser

6. **Flags**
   - User flag: `/home/opsuser/user.txt`
   - Root flag: `/root/root.txt`

## Setup Instructions

### On Web VM (192.168.0.50)

```bash
# Install dependencies
sudo apt update
sudo apt install -y apache2 php php-sqlite3 sqlite3

# Copy files to web directory
sudo cp -r opsdesk /var/www/

# Run setup script
cd /var/www/opsdesk
sudo bash setup.sh

# Create opsuser for SSH pivot
sudo useradd -m -s /bin/bash opsuser
echo 'opsuser:0psD3skUs3r!' | sudo chpasswd
```

### Git VM Setup (Manual - as requested)

Configure Gitea on 192.168.0.200 with:
- A repository containing OpsDesk source code
- Accidentally committed `config.php.bak` with credentials
- Commit history showing: `admin / OpsDesk2024!Admin`

## Vulnerabilities Summary

| Vulnerability | Location | Description |
|--------------|----------|-------------|
| Information Disclosure | Git Repo | Credentials in commit history |
| Weak Upload Validation | /upload.php | Extension bypass via double extension |
| SQL Injection | /adminLogin.php | Unparameterized query (alternative path) |
| Exposed Database | Filesystem | SQLite readable by www-data |
| Hardcoded Creds | Database | SSH credentials stored in DB |

## File Structure

```
ctf-web/
├── opsdesk/
│   ├── config/
│   │   └── opsdesk.conf          # Apache VirtualHost config
│   ├── public/                    # Port 80 - Decoy site
│   │   ├── index.php
│   │   └── adminLogin.php         # Always fails
│   ├── staff/                     # Port 5000 - Real admin
│   │   ├── adminLogin.php   
│   │   ├── dashboard.php
│   │   ├── upload.php             # Upload bypass
│   │   ├── tickets.php
│   │   └── logout.php
│   ├── includes/
│   │   └── db.php                 # DB connection
│   ├── uploads/                   # Web-accessible uploads
│   ├── db/
│   │   ├── schema.sql             # DB schema
│   │   └── seed.sql               # Seed data + SSH creds
│   └── setup.sh                   # Setup script
└── README.md
```

## Hints

<details>
<summary>Upload Bypass Hint</summary>
The upload check uses `pathinfo($filename, PATHINFO_EXTENSION)` which only checks the last extension. Try uploading a file named `shell.php.jpg` or `rev.phtml`.
</details>

<details>
<summary>SQL Injection Hint</summary>
The login query is: `SELECT * FROM users WHERE username = '$username' AND password_hash = '$password'`
Try: `admin'-- `
</details>

## Credentials

| Username | Password | Location |
|----------|----------|----------|
| admin | OpsDesk2024!Admin | Git repo |
| opsuser | 0psD3skUs3r! | SQLite DB (ssh_credentials table) |
