<?php
/**
 * OpsDesk Staff - Dashboard
 */
require_once '/var/www/opsdesk/includes/db.php';
session_start();

if (!isset($_SESSION['user_id'])) {
    header('Location: /adminLogin.php');
    exit;
}

$db = getDB();
$user = $db->query("SELECT * FROM users WHERE id = " . $_SESSION['user_id'])->fetch();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - OpsDesk Staff</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f5f7fa; }
        header { background: #2c3e50; color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        nav { background: #34495e; padding: 0.8rem 2rem; }
        nav a { color: white; text-decoration: none; margin-right: 25px; }
        nav a.active { border-bottom: 2px solid #3498db; }
        .container { max-width: 1200px; margin: 2rem auto; padding: 0 2rem; }
        .card { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 1.5rem; padding: 1.5rem; }
        .btn { display: inline-block; padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; }
        .alert { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <header>
        <h1>OpsDesk Staff Portal</h1>
        <div>Welcome, <strong><?php echo htmlspecialchars($user['username']); ?></strong> | <a href="/logout.php" style="color: #3498db;">Logout</a></div>
    </header>
    
    <nav>
        <a href="/dashboard.php" class="active">Dashboard</a>
        <a href="/upload.php">Attachments</a>
        <a href="/tickets.php">Tickets</a>
    </nav>
    
    <div class="container">
        <div class="alert">
            <strong>Notice:</strong> New file attachment feature is now available. Use the Attachments page to upload support documents.
        </div>
        
        <div class="card">
            <h2>Welcome to OpsDesk Staff Portal</h2>
            <p>This is the internal operations dashboard. Use the navigation above to access different features.</p>
            <p style="margin-top: 1rem;">
                <a href="/upload.php" class="btn">Upload Attachment</a>
            </p>
        </div>
        
        <div class="card">
            <h3>System Information</h3>
            <p>Server: 192.168.0.50</p>
            <p>Database: SQLite</p>
            <p>Version: 1.2.0</p>
        </div>
    </div>
</body>
</html>
