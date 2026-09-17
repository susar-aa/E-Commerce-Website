-- =========================================================================
-- CURTISS E-COMMERCE & ERP DATABASE SCHEMA UPGRADE SCRIPT
-- Execute these SQL queries on your production database server (e.g. Plesk / online MySQL)
-- =========================================================================

-- 1. Ensure Wholesaler Requests Table Exists
CREATE TABLE IF NOT EXISTS wholesaler_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    business_name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    contact_number VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL,
    email_address VARCHAR(150) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    notes TEXT NULL,
    status ENUM('pending', 'approved', 'declined') DEFAULT 'pending',
    linked_customer_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (linked_customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Ensure E-Commerce Retail Customers Table Exists
CREATE TABLE IF NOT EXISTS ecommerce_retail_customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    username VARCHAR(100) UNIQUE NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NULL,
    address TEXT NULL,
    city VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Ensure Customers table has username and password for Wholesaler B2B login
-- (Note: Supported natively in MariaDB 10.2+ and MySQL 8.0.19+. If using older MySQL, ignore duplicate column warnings if already added)
ALTER TABLE customers ADD COLUMN IF NOT EXISTS username VARCHAR(100) UNIQUE NULL AFTER email;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS password VARCHAR(255) NULL AFTER username;

-- 4. Ensure Sales Orders & Sales Order Items Tables Exist in ERP DB
CREATE TABLE IF NOT EXISTS sales_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    customer_name VARCHAR(150) NOT NULL,
    customer_phone VARCHAR(50) NULL,
    billing_type ENUM('retail', 'wholesale') NOT NULL DEFAULT 'retail',
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    discount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    grand_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    notes TEXT NULL,
    rep_name VARCHAR(100) NULL,
    mca VARCHAR(100) NULL,
    rep_tp VARCHAR(50) NULL,
    po_number VARCHAR(50) NULL,
    order_date DATE NOT NULL,
    due_date DATE NOT NULL,
    payment_term_id INT NULL DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sales_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sales_order_id INT NOT NULL,
    item_id INT NOT NULL,
    variation_option_id INT NULL DEFAULT NULL,
    sku VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    billing_price DECIMAL(10,2) NOT NULL,
    qty INT NOT NULL,
    discount_value DECIMAL(10,2) DEFAULT 0.00,
    discount_type VARCHAR(10) DEFAULT 'Rs',
    total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sales_order_id) REFERENCES sales_orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Ensure company_settings has ecommerce_store_url
ALTER TABLE company_settings ADD COLUMN IF NOT EXISTS ecommerce_store_url VARCHAR(255) NULL DEFAULT '';
