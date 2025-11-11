-- Migration: Minimal Seed Data for New Tenants
-- Version: 2025-11-06-000000
-- Module: core
-- Description: Creates essential tables and populates minimal seed data for development
--
-- This migration provides:
-- 1. Admin user table and default admin account (development only)
-- 2. Centro configuration table with tenant information
-- 3. System configuration table with metadata
--
-- Note: This migration is idempotent and safe to run multiple times
-- All INSERT statements use INSERT IGNORE to prevent duplicate key errors

-- UP

-- ==============================================================================
-- 1. ADMIN USER TABLE AND DEFAULT ACCOUNT
-- ==============================================================================

-- Create utenti (users) table if it doesn't exist
-- This table stores system user accounts for authentication
CREATE TABLE IF NOT EXISTS utenti (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique username for login',
    password VARCHAR(255) NOT NULL COMMENT 'Hashed password (SHA256 or bcrypt)',
    firstname VARCHAR(100) COMMENT 'User first name',
    lastname VARCHAR(100) COMMENT 'User last name',
    email VARCHAR(255) COMMENT 'User email address',
    attivo TINYINT(1) DEFAULT 1 COMMENT 'Active status: 1=active, 0=disabled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_attivo (attivo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='User accounts for system authentication';

-- Insert default admin user for development
-- Password: 'admin123' (SHA256 hash)
-- IMPORTANT: Change this password immediately in production!
-- The password hash is: SHA256('admin123')
INSERT IGNORE INTO utenti (username, password, firstname, lastname, email, attivo)
VALUES (
    'admin',
    SHA2('admin123', 256),
    'System',
    'Administrator',
    'admin@example.com',
    1
);

-- ==============================================================================
-- 2. CENTRO CONFIGURATION TABLE
-- ==============================================================================

-- Create centri (centers) table if it doesn't exist
-- This table stores tenant/center information
CREATE TABLE IF NOT EXISTS centri (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL COMMENT 'Center name',
    codice VARCHAR(50) UNIQUE COMMENT 'Center code (unique identifier)',
    indirizzo VARCHAR(255) COMMENT 'Center address',
    citta VARCHAR(100) COMMENT 'City',
    cap VARCHAR(10) COMMENT 'Postal code',
    provincia VARCHAR(2) COMMENT 'Province code',
    telefono VARCHAR(50) COMMENT 'Phone number',
    email VARCHAR(255) COMMENT 'Contact email',
    attivo TINYINT(1) DEFAULT 1 COMMENT 'Active status: 1=active, 0=disabled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_codice (codice),
    INDEX idx_attivo (attivo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tenant/center configuration information';

-- Insert centro record with tenant name
-- This will be populated with actual tenant name during migration execution
-- Note: The {{TENANT_NAME}} placeholder will be replaced by the migration script
INSERT IGNORE INTO centri (nome, codice, attivo)
VALUES (
    '{{TENANT_NAME}}',
    '{{TENANT_NAME}}',
    1
);

-- ==============================================================================
-- 3. SYSTEM CONFIGURATION TABLE
-- ==============================================================================

-- Create system_config table if it doesn't exist
-- This table stores system-wide configuration key-value pairs
CREATE TABLE IF NOT EXISTS system_config (
    config_key VARCHAR(100) PRIMARY KEY COMMENT 'Configuration key (unique)',
    config_value TEXT COMMENT 'Configuration value (any format)',
    description VARCHAR(255) COMMENT 'Configuration description',
    config_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string' COMMENT 'Value type',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='System-wide configuration key-value store';

-- Insert essential system configuration
INSERT IGNORE INTO system_config (config_key, config_value, description, config_type)
VALUES
    ('system.version', '3.0.0', 'CRIA system version', 'string'),
    ('system.environment', 'development', 'Current environment (development/staging/production)', 'string'),
    ('system.initialized_at', NOW(), 'Timestamp when system was initialized', 'string'),
    ('system.database_version', '2025-11-06-000000', 'Current database schema version', 'string'),
    ('tenant.name', '{{TENANT_NAME}}', 'Tenant identifier', 'string');

-- ==============================================================================
-- SEED DATA SUMMARY
-- ==============================================================================
-- Tables created: utenti, centri, system_config
-- Default admin user: username='admin', password='admin123'
-- Centro record: populated with tenant name
-- System config: 5 essential configuration entries
-- ==============================================================================

-- DOWN

-- ==============================================================================
-- ROLLBACK: Remove seed data (but preserve table structure for safety)
-- ==============================================================================

-- Remove default admin user
DELETE FROM utenti WHERE username = 'admin' AND email = 'admin@example.com';

-- Remove centro record (careful: only remove if it matches tenant name placeholder)
-- In production, you may want to preserve this data
-- DELETE FROM centri WHERE codice = '{{TENANT_NAME}}';

-- Remove system configuration entries
DELETE FROM system_config WHERE config_key IN (
    'system.version',
    'system.environment',
    'system.initialized_at',
    'system.database_version',
    'tenant.name'
);

-- Note: We do NOT drop tables during rollback to prevent accidental data loss
-- If you need to completely remove these tables, do it manually:
-- DROP TABLE IF EXISTS utenti;
-- DROP TABLE IF EXISTS centri;
-- DROP TABLE IF EXISTS system_config;
