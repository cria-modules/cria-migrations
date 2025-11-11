# CRIA Migrations

Database migrations and seed data for the CRIA healthcare management platform.

## Overview

This package contains:
- **Bootstrap migrations**: Initial database schema setup (schema_migrations table)
- **Seed data**: Minimal seed data for development (admin user, centro config, system settings)
- **Production seed data**: Optional production-like data for testing

## Installation

Via Composer:

```json
{
  "repositories": [
    {
      "type": "vcs",
      "url": "https://github.com/cria-modules/cria-migrations"
    }
  ],
  "require": {
    "cria/cria-migrations": "^1.0"
  }
}
```

Run: `composer install`

## Directory Structure

```
cria-migrations/
├── bootstrap/          # Bootstrap migrations (schema_migrations table)
│   └── 2025-11-02-150000-create-schema-migrations-table.sql
├── seeds/             # Seed data for development
│   ├── 2025-11-06-000000-minimal-seed-data.sql
│   ├── 2025-11-07-000000-base-production-data.sql
│   └── 2025-11-07-000001-centro-production-data.sql
└── README.md
```

## Usage

### Bootstrap Database

The bootstrap migration creates the `schema_migrations` table used to track applied migrations:

```bash
mysql -u user -p database < vendor/cria/cria-migrations/bootstrap/2025-11-02-150000-create-schema-migrations-table.sql
```

### Apply Minimal Seed Data

For development tenants:

```bash
# Replace {{TENANT_NAME}} with actual tenant identifier
sed 's/{{TENANT_NAME}}/mytenant/g' vendor/cria/cria-migrations/seeds/2025-11-06-000000-minimal-seed-data.sql | mysql -u user -p database
```

This creates:
- **Admin user**: username=`admin`, password=`admin123` (⚠️ change in production!)
- **Centro record**: Basic tenant configuration
- **System config**: Essential system settings

### Apply Production Seed Data

For testing with realistic data:

```bash
mysql -u user -p database < vendor/cria/cria-migrations/seeds/2025-11-07-000000-base-production-data.sql
mysql -u user -p database < vendor/cria/cria-migrations/seeds/2025-11-07-000001-centro-production-data.sql
```

## Migration Runner

CRIA tenants use the automated migration runner available at:
- `bin/bootstrap-tenant-db.php` - Bootstrap database
- `bin/migrate.php` - Run pending migrations

These scripts automatically discover and apply migrations from this package.

## Security Notes

⚠️ **Development Only**
- Default admin credentials (`admin`/`admin123`) are for development only
- **MUST be changed** in production environments
- Use strong passwords and enable 2FA for production

## License

Proprietary - CRIA Healthcare Management System

## Version

1.0.0 - Initial release
