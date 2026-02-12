<?php
/**
 * OpsDesk Staff - Real Admin Login (SQLi Fixed)
 */
require_once '/var/www/opsdesk/includes/db.php';
session_start();

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';

    // Input validation (defense in depth)
    if (empty($username) || empty($password)) {
        sleep(1);
        $error = 'Invalid credentials.';
    } else {
        try {
            $db = getDB();
            
            // SECURE: Parameterized query - user input never touches the SQL directly
            $stmt = $db->prepare("
                SELECT id, username, password_hash, role, active 
                FROM users 
                WHERE username = :username AND active = 1
                LIMIT 1
            ");
            
            $stmt->bindParam(':username', $username, PDO::PARAM_STR);
            $stmt->execute();
            
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            // SECURE: Proper password hash verification (assuming passwords stored with password_hash())
            if ($user && password_verify($password, $user['password_hash'])) {
                // Prevent session fixation
                session_regenerate_id(true);
                
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['username'] = $user['username'];
                $_SESSION['role'] = $user['role'];
                
                header('Location: /dashboard.php');
                exit;
            } else {
                sleep(1);
                $error = 'Invalid credentials.'; // Generic message prevents user enumeration
            }
            
        } catch (PDOException $e) {
            // Log internally, don't leak SQL errors to users
            error_log("Authentication error: " . $e->getMessage());
            $error = 'System error. Please try again later.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Staff Login - OpsDesk</title>
    <style>
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .login-container { background: white; padding: 2.5rem; border-radius: 10px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); width: 100%; max-width: 400px; }
        .logo { text-align: center; margin-bottom: 1.5rem; }
        .logo h1 { color: #2c3e50; font-size: 1.8rem; margin: 0; }
        .logo p { color: #7f8c8d; font-size: 0.9rem; margin: 0.5rem 0 0; }
        .form-group { margin-bottom: 1.2rem; }
        label { display: block; margin-bottom: 0.5rem; color: #555; font-weight: 500; }
        input[type="text"], input[type="password"] { width: 100%; padding: 12px; border: 2px solid #e0e0e0; border-radius: 6px; font-size: 14px; box-sizing: border-box; }
        button { width: 100%; padding: 14px; background: #667eea; color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; }
        .error { background: #fee; color: #c33; padding: 12px; border-radius: 6px; margin-bottom: 1rem; text-align: center; border-left: 4px solid #c33; }
        .info { text-align: center; margin-top: 1.5rem; font-size: 12px; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <h1>OpsDesk Staff</h1>
            <p>Internal Operations Portal</p>
        </div>
        <?php if ($error): ?>
            <div class="error"><?php echo htmlspecialchars($error); ?></div>
        <?php endif; ?>
        <form method="POST">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" required autofocus>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required>
            </div>
            <button type="submit">Sign In</button>
        </form>
        <div class="info">
            <p>Authorized personnel only. Server: 192.168.0.50:5000</p>
        </div>
    </div>
</body>
</html>
