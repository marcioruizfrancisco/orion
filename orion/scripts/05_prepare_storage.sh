#!/bin/bash

# ============================================================
# Orion Project
#
# Script:
#   05_prepare_storage.sh
#
# Objetivo:
#   Criar os diretórios de dados (storage/) das Stacks ANTES do
#   primeiro "docker compose up".
#
# Por quê:
#   Se o diretório não existir, o Docker o cria como root. Vários
#   apps rodam com usuário comum dentro do container (n8n, pgAdmin,
#   Chatwoot...) e não conseguem escrever ali. Criar antes, com
#   permissão aberta, evita o erro "Permission denied".
#
#   PostgreSQL e Redis ficam de fora: as imagens deles ajustam o
#   próprio diretório.
#
# Execução:
#   ./05_prepare_storage.sh
#
# ============================================================

set -e

ORION_HOME="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -f "$ORION_HOME/.env" ]; then
    echo "❌ .env não encontrado. Execute primeiro ./02_create_env_links.sh"
    exit 1
fi

set -a
source "$ORION_HOME/.env"
set +a

echo
echo "============================================================"
echo " Orion Project"
echo " Preparação do storage"
echo "============================================================"
echo

DIRECTORIES=(
    "$EVOLUTION_DATA_PATH"
    "$PGADMIN_DATA_PATH"
    "$UPTIMEKUMA_DATA_PATH"
    "$EVOAUTH_STORAGE_PATH"
    "$EVOCRM_STORAGE_PATH"
    "$CHATWOOT_STORAGE_PATH"
    "$N8N_DATA_PATH"
    "$MAILPIT_DATA_PATH"
)

for DIR in "${DIRECTORIES[@]}"
do
    mkdir -p "$DIR"

    if [ -O "$DIR" ]; then
        chmod 0777 "$DIR"
        echo "✔ $DIR"
    else
        echo "· $DIR (já existe, dono diferente; mantido)"
    fi
done

echo
