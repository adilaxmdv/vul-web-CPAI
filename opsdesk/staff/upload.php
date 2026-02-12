<?php
/**
 * OpsDesk Staff - File Upload (VULNERABLE)
 * 
 * VULNERABILITY: Extension check can be bypassed with double extension
 * e.g., shell.php.jpg or shell.pHp (case insensitive on some systems)
 */
require_once '/var/www/opsdesk/includes/db.php';
session_start();

if (!isset($_SESSION['user_id'])) {
    header('Location: /adminLogin.php');
    exit;
}

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['file'])) {
    $file = $_FILES['file'];
    
    if ($file['error'] === UPLOAD_ERR_OK) {
        $filename = basename($file['name']);
        $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
        
        // VULNERABLE: Weak extension check - only checks the last extension
        // Bypass: upload shell.php.jpg or shell.phtml
        $allowed = ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'];
        
        if (in_array($ext, $allowed)) {
            // Save to uploads directory (accessible from web!)
            $uploadPath = '/var/www/opsdesk/uploads/' . $filename;
            
            if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
                // Log to database
                $db = getDB();
                $stmt = $db->prepare("INSERT INTO attachments (original_filename, stored_path, uploaded_by, uploaded_at) VALUES (?, ?, ?, datetime('now'))");
                $stmt->execute([$filename, $uploadPath, $_SESSION['user_id']]);
                
                $webPath = '/uploads/' . $filename;
                $fullUrl = 'http://' . $_SERVER['HTTP_HOST'] . $webPath;
                $message = 'File uploaded successfully: ' . htmlspecialchars($filename) . 
                          '<br><strong>Access URL:</strong> <a href="' . $webPath . '">' . htmlspecialchars($fullUrl) . '</a>';
            } else {
                $error = 'Failed to move uploaded file.';
            }
        } else {
            $error = 'Invalid file type. Allowed: jpg, jpeg, png, gif, pdf, doc, docx';
        }
    } else {
        $error = 'Upload error occurred.';
    }
}

// List uploaded files
$db = getDB();
$files = $db->query("SELECT a.*, u.username FROM attachments a LEFT JOIN users u ON a.uploaded_by = u.id ORDER BY a.uploaded_at DESC LIMIT 10")->fetchAll();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attachments - OpsDesk Staff</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f5f7fa; }
        header { background: #2c3e50; color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        nav { background: #34495e; padding: 0.8rem 2rem; }
        nav a { color: white; text-decoration: none; margin-right: 25px; }
        nav a.active { border-bottom: 2px solid #3498db; }
        .container { max-width: 1200px; margin: 2rem auto; padding: 0 2rem; }
        .card { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 1.5rem; padding: 1.5rem; }
        .success { background: #d4edda; color: #155724; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; }
        .error { background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; }
        .btn { display: inline-block; padding: 10px 20px; background: #3498db; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; }
        input[type="file"] { padding: 10px; border: 1px solid #ddd; border-radius: 4px; margin-right: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; }
        .hint { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; font-size: 0.9rem; }
    </style>
</head>
<body>
    <header>
        <h1>OpsDesk Staff Portal</h1>
        <div>Welcome, <strong><?php echo htmlspecialchars($_SESSION['username']); ?></strong> | <a href="/logout.php" style="color: #3498db;">Logout</a></div>
    </header>
    
    <nav>
        <a href="/dashboard.php">Dashboard</a>
        <a href="/upload.php" class="active">Attachments</a>
        <a href="/tickets.php">Tickets</a>
    </nav>
    
    <div class="container">
        <div class="card">
            <h2>Upload Attachment</h2>
            <div class="hint">
                <strong>Supported formats:</strong> Images (JPG, PNG, GIF), Documents (PDF, DOC, DOCX)
            </div>
            
            <?php if ($message): ?>
                <div class="success"><?php echo $message; ?></div>
            <?php endif; ?>
            <?php if ($error): ?>
                <div class="error"><?php echo $error; ?></div>
            <?php endif; ?>
            
            <form method="POST" enctype="multipart/form-data">
                <input type="file" name="file" required>
                <button type="submit" class="btn">Upload</button>
            </form>
        </div>
        
        <div class="card">
            <h2>Recent Uploads</h2>
            <table>
                <thead>
                    <tr>
                        <th>Filename</th>
                        <th>Uploaded By</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($files as $file): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($file['original_filename']); ?></td>
                        <td><?php echo htmlspecialchars($file['username'] ?? 'Unknown'); ?></td>
                        <td><?php echo $file['uploaded_at']; ?></td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (empty($files)): ?>
                    <tr><td colspan="3" style="text-align: center;">No files uploaded yet</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
