#!/bin/bash
# ==============================================================================
# Script d'initialisation des bases de données PostgreSQL
# ==============================================================================

set -e

echo "🔧 Initializing Waterfall databases..."

# Créer les bases de données
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Créer les bases de données si elles n'existent pas
    SELECT 'CREATE DATABASE waterfall_auth'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'waterfall_auth')\gexec

    SELECT 'CREATE DATABASE waterfall_identity'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'waterfall_identity')\gexec

    SELECT 'CREATE DATABASE waterfall_guardian'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'waterfall_guardian')\gexec

    -- Accorder tous les privilèges
    GRANT ALL PRIVILEGES ON DATABASE waterfall_auth TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE waterfall_identity TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE waterfall_guardian TO $POSTGRES_USER;
EOSQL

# Accorder les permissions sur le schéma public pour PostgreSQL 15+
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "waterfall_auth" <<-EOSQL
    GRANT ALL ON SCHEMA public TO $POSTGRES_USER;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "waterfall_identity" <<-EOSQL
    GRANT ALL ON SCHEMA public TO $POSTGRES_USER;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "waterfall_guardian" <<-EOSQL
    GRANT ALL ON SCHEMA public TO $POSTGRES_USER;
EOSQL

echo "✅ Databases initialized successfully!"
