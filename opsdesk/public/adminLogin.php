<?php
/**
 * OpsDesk Public - Decoy Admin Login (Always Fails)
 */
session_start();
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    sleep(1);
    $error = 'Invalid credentials. This login attempt has been logged and monitored.';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Login - OpsDesk</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .login-container { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); width: 100%; max-width: 400px; }
        h1 { text-align: center; color: #2c3e50; margin-bottom: 1.5rem; }
        .form-group { margin-bottom: 1rem; }
        label { display: block; margin-bottom: 0.5rem; color: #555; }
        input[type="text"], input[type="password"] { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
        button { width: 100%; padding: 12px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .error { background: #e74c3c; color: white; padding: 10px; border-radius: 4px; margin-bottom: 1rem; text-align: center; }
        .monitored { text-align: center; margin-top: 1rem; font-size: 12px; color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="login-container">
        <h1>OpsDesk Admin</h1>
        <?php if ($error): ?>
            <div class="error"><?php echo htmlspecialchars($error); ?></div>
        <?php endif; ?>
        <form method="POST">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required>
            </div>
            <button type="submit">Login</button>
        </form>
        <div class="monitored">
            <p>&#128274; Secure Area - All access attempts are monitored and logged.</p>
        </div>
    </div>
</body>
</html>
