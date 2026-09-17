<?php
// Load Environment Variables from .env file
function loadEnv($path) {
    if (!file_exists($path)) {
        return;
    }
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        $line = trim($line);
        if (empty($line) || strpos($line, '#') === 0) {
            continue;
        }
        $parts = explode('=', $line, 2);
        if (count($parts) === 2) {
            $key = trim($parts[0]);
            $val = trim($parts[1]);
            // Strip wrapping quotes
            if (preg_match('/^["\'](.*)["\']$/', $val, $matches)) {
                $val = $matches[1];
            }
            if (function_exists('putenv') && getenv($key) === false) {
                putenv("$key=$val");
            }
            if (!isset($_ENV[$key])) {
                $_ENV[$key] = $val;
            }
            if (!isset($_SERVER[$key])) {
                $_SERVER[$key] = $val;
            }
        }
    }
}

function get_env_var($key, $default = '') {
    if (isset($_ENV[$key])) return $_ENV[$key];
    if (isset($_SERVER[$key])) return $_SERVER[$key];
    if (function_exists('getenv')) {
        $val = getenv($key);
        if ($val !== false) return $val;
    }
    return $default;
}

// Load env file from project root
loadEnv(__DIR__ . '/../.env');

// Database Constants
define('DB_HOST', get_env_var('DB_HOST', 'localhost'));
define('DB_USER', get_env_var('DB_USER', 'root')); 
define('DB_PASS', get_env_var('DB_PASS', ''));    
define('DB_NAME', get_env_var('DB_NAME', 'curtiss_erp')); 

// App Root URL - Dynamically determined for local dev (XAMPP) & Plesk production
if (isset($_SERVER['HTTP_HOST'])) {
    $isHttps = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ||
               (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https');
    $protocol = $isHttps ? 'https' : 'http';
    $script = $_SERVER['SCRIPT_NAME'];
    $dir = str_replace('\\', '/', dirname($script));
    if ($dir === '/') {
        $dir = '';
    }
    define('APP_URL', $protocol . '://' . $_SERVER['HTTP_HOST'] . $dir);
} else {
    define('APP_URL', 'https://falcon.trycurtiss.com');
}

// Site Name
define('APP_NAME', 'CURTISS ERP');

// Brevo API Configuration
define('BREVO_API_KEY', get_env_var('BREVO_API_KEY', ''));
