#!/bin/bash

# ============================================================
# Orion Project
#
# Stack:
#   Chatwoot
#
# Script:
#   001_create_database.sh
#
# Objetivo:
#   Provisionar o usuário e o banco PostgreSQL do Chatwoot.
#
# Observações:
#   - Configurações vindas do .env (repassado pelo 03_create_database.sh).
#   - Idempotente: pode rodar quantas vezes precisar.
#   - Este script NÃO executa docker.
#
# ============================================================

set -eu

echo
echo "============================================================"
echo " Chatwoot"
echo " Provisionando banco PostgreSQL..."
echo "============================================================"
echo

psql \
    -U "$POSTGRES_USER" \
    -v ON_ERROR_STOP=1 \
<<SQL

DO
\$do\$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$CHATWOOT_DB_USER') THEN

        EXECUTE format(
            'CREATE ROLE %I LOGIN PASSWORD %L',
            '$CHATWOOT_DB_USER',
            '$CHATWOOT_DB_PASSWORD'
        );

        RAISE NOTICE 'Usuário criado.';

    ELSE

        RAISE NOTICE 'Usuário já existe.';

    END IF;

END
\$do\$;

SELECT
    format('CREATE DATABASE %I OWNER %I', '$CHATWOOT_DB_NAME', '$CHATWOOT_DB_USER')
WHERE
    NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = '$CHATWOOT_DB_NAME')
\gexec

SQL

# Extensões que a aplicação exige. Várias não são "trusted" e só
# superusuário pode criá-las — como as migrations rodam com o usuário
# da aplicação, elas precisam existir antes.
for EXTENSION in pg_stat_statements pg_trgm pgcrypto hstore vector
do
    psql \
        -U "$POSTGRES_USER" \
        -d "$CHATWOOT_DB_NAME" \
        -v ON_ERROR_STOP=1 \
        -c "CREATE EXTENSION IF NOT EXISTS \"$EXTENSION\";"
done

echo
echo "✔ Provisionamento concluído."
echo
