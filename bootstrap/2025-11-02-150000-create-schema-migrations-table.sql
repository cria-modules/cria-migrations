-- ============================================================================
-- Bootstrap Migration: Create schema_migrations Table
-- ============================================================================
-- Version: 2025-11-02-150000
-- Description: Create schema_migrations table for tracking database migrations
-- Author: Platform Engineering Team
-- Date: 2025-11-02
-- Module: core (bootstrap)
-- ============================================================================
--
-- This is a special bootstrap migration that creates the migration tracking
-- system itself. It must be executed before any other migrations can run.
--
-- ============================================================================

-- UP
-- ============================================================================

CREATE TABLE IF NOT EXISTS schema_migrations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  module_name VARCHAR(100) NOT NULL COMMENT 'Module name (e.g., cria/cartellaclinica-zf1)',
  migration_filename VARCHAR(255) NOT NULL COMMENT 'Migration filename',
  migration_version VARCHAR(50) NOT NULL COMMENT 'Migration version from filename timestamp',
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When migration was applied',
  rollback_at TIMESTAMP NULL COMMENT 'When migration was rolled back (if applicable)',
  status ENUM('applied', 'rolled_back') DEFAULT 'applied' COMMENT 'Current status of migration',
  execution_time_ms INT COMMENT 'Execution time in milliseconds',
  INDEX idx_module_version (module_name, migration_version),
  UNIQUE KEY unique_migration (module_name, migration_filename)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tracks applied database migrations per module';

-- Create migration_backups table for tracking backup metadata
CREATE TABLE IF NOT EXISTS migration_backups (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_name VARCHAR(100) NOT NULL COMMENT 'Tenant name',
  database_name VARCHAR(100) NOT NULL COMMENT 'Database name',
  backup_filepath VARCHAR(500) NOT NULL COMMENT 'Full path to backup file',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When backup was created',
  file_size_mb DECIMAL(10,2) COMMENT 'Backup file size in megabytes',
  associated_migration_version VARCHAR(50) COMMENT 'Migration version this backup was created for',
  INDEX idx_tenant_date (tenant_name, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Tracks database backup files created by migration system';

-- DOWN
-- ============================================================================

DROP TABLE IF EXISTS migration_backups;
DROP TABLE IF EXISTS schema_migrations;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
