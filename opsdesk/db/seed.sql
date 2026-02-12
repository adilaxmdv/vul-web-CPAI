-- OpsDesk Seed Data for CTF
-- Passwords are hashed with bcrypt for password_verify()

-- Admin user (found in Git repo as 'OpsDesk2024!Admin')
-- Hash generated: password_hash('OpsDesk2024!Admin', PASSWORD_BCRYPT)
INSERT INTO users (username, password_hash, role, active) VALUES 
('admin', '$2b$12$QDtNRKw4swC.TIJ201Guq.ppja0zXfFPT7bxubzGVyclWbPBKq1EW', 'admin', 1);

-- Other staff users (decoys/not needed for main chain)
INSERT INTO users (username, password_hash, role, active) VALUES 
('jsmith', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1),
('mjones', '$2y$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77UdFm', 'user', 1),
('dlee', '$2y$10$q9xv30qDBq4h34P2jF0.luB4ZmC5CHs9UZQxFDDKxK3l7oYQ9m6S', 'user', 0);

-- Sample tickets
INSERT INTO tickets (title, description, status, priority, created_by) VALUES
('Server outage in DC3', 'Critical server experiencing intermittent outages since last night', 'open', 'high', 2),
('Password reset request', 'User cannot access email, needs password reset', 'pending', 'medium', 3),
('VPN configuration issue', 'New employee unable to connect to corporate VPN', 'resolved', 'low', 2),
('Database backup failure', 'Automated backup failed for opsdesk.db - permission denied', 'open', 'high', 1);

-- SSH credentials for pivot (found after foothold)
-- This allows pivot to the 'opsuser' account
INSERT INTO ssh_credentials (hostname, username, password, description) VALUES
('192.168.0.50', 'opsuser', '0psD3skUs3r!', 'Local system account for maintenance');
