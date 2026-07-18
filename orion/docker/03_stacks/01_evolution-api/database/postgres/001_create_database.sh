#!/bin/bash

# ============================================================
# Orion Project
#
# Stack:
#   Evolution API
#
# Script:
#   001_create_database.sh
#
# Objetivo:
#   Provisionar automaticamente o usuário e o banco
#   PostgreSQL utilizados pela Evolution API.
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

# echo "Bebug"
# echo "Evolution Database"
# echo "DB: $EVOLUTION_DB_NAME"
# echo "USER: $EVOLUTION_DB_USER"


echo
echo "============================================================"
echo " Evolution API"
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
            rolname = '$EVOLUTION_DB_USER'
    ) THEN

        EXECUTE format(
            'CREATE ROLE %I LOGIN PASSWORD %L',
            '$EVOLUTION_DB_USER',
            '$EVOLUTION_DB_PASSWORD'
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
        '$EVOLUTION_DB_NAME',
        '$EVOLUTION_DB_USER'
    )
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            pg_database
        WHERE
            datname = '$EVOLUTION_DB_NAME'
    )
\gexec

SQL

echo
echo "✔ Provisionamento concluído."
echo
