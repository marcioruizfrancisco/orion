#!/bin/bash

# ============================================================
# Orion Project
#
# Stack:
#   Evolution CRM
#
# Script:
#   001_create_database.sh
#
# Objetivo:
#   Provisionar automaticamente o usuário e o banco
#   PostgreSQL utilizados pelo Evolution CRM (evocrm).
#
# Responsabilidades:
#   - Criar o usuário PostgreSQL caso não exista.
#   - Criar o banco de dados caso não exista.
#   - Definir o usuário como proprietário do banco.
#
# Observações:
#   - Todas as configurações são obtidas do arquivo .env.
#   - Este script deve ser idempotente.
#   - Este script NÃO executa docker.
#
# ============================================================

set -eu

echo
echo "============================================================"
echo " Evolution CRM"
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

    IF NOT EXISTS (
        SELECT
            1
        FROM
            pg_roles
        WHERE
            rolname = '$EVOCRM_DB_USER'
    ) THEN

        EXECUTE format(
            'CREATE ROLE %I LOGIN PASSWORD %L',
            '$EVOCRM_DB_USER',
            '$EVOCRM_DB_PASSWORD'
        );

        RAISE NOTICE 'Usuário criado.';

    ELSE

        RAISE NOTICE 'Usuário já existe.';

    END IF;

END
\$do\$;


SELECT
    format(
        'CREATE DATABASE %I OWNER %I',
        '$EVOCRM_DB_NAME',
        '$EVOCRM_DB_USER'
    )
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            pg_database
        WHERE
            datname = '$EVOCRM_DB_NAME'
    )
\gexec

SQL

# pg_stat_statements não é uma extensão "trusted": só superusuário pode
# criá-la. O schema.rb do evocrm tenta habilitá-la durante db:prepare,
# rodando como o usuário da aplicação (sem esse privilégio), então
# precisa ser pré-criada aqui.
psql \
    -U "$POSTGRES_USER" \
    -d "$EVOCRM_DB_NAME" \
    -v ON_ERROR_STOP=1 \
    -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"

echo
echo "✔ Provisionamento concluído."
echo
