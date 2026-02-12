<?php
/**
 * OpsDesk Staff - Tickets
 */
require_once '/var/www/opsdesk/includes/db.php';
session_start();

if (!isset($_SESSION['user_id'])) {
    header('Location: /adminLogin.php');
    exit;
}

$db = getDB();
$tickets = $db->query("SELECT t.*, u.username as creator FROM tickets t LEFT JOIN users u ON t.created_by = u.id ORDER BY t.created_at DESC LIMIT 20")->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Tickets - OpsDesk Staff</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f5f7fa; }
        header { background: #2c3e50; color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        nav { background: #34495e; padding: 0.8rem 2rem; }
        nav a { color: white; text-decoration: none; margin-right: 25px; }
        nav a.active { border-bottom: 2px solid #3498db; }
        .container { max-width: 1200px; margin: 2rem auto; padding: 0 2rem; }
        .card { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 1.5rem; }
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; }
        .badge { padding: 4px 10px; border-radius: 12px; font-size: 0.75rem; }
        .badge-open { background: #e74c3c; color: white; }
        .badge-pending { background: #f39c12; color: white; }
        .badge-resolved { background: #27ae60; color: white; }
    </style>
</head>
<body>
    <header>
        <h1>OpsDesk Staff Portal</h1>
        <div>Welcome, <strong><?php echo htmlspecialchars($_SESSION['username']); ?></strong> | <a href="/logout.php" style="color: #3498db;">Logout</a></div>
    </header>
    
    <nav>
        <a href="/dashboard.php">Dashboard</a>
        <a href="/upload.php">Attachments</a>
        <a href="/tickets.php" class="active">Tickets</a>
    </nav>
    
    <div class="container">
        <div class="card">
            <h2>Support Tickets</h2>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Created By</th>
                        <th>Status</th>
                        <th>Priority</th>
                        <th>Created</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($tickets as $ticket): ?>
                    <tr>
                        <td>#<?php echo $ticket['id']; ?></td>
                        <td><?php echo htmlspecialchars($ticket['title']); ?></td>
                        <td><?php echo htmlspecialchars($ticket['creator'] ?? 'Unknown'); ?></td>
                        <td><span class="badge badge-<?php echo $ticket['status']; ?>"><?php echo ucfirst($ticket['status']); ?></span></td>
                        <td><?php echo ucfirst($ticket['priority']); ?></td>
                        <td><?php echo $ticket['created_at']; ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
