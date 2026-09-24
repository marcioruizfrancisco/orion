#!/bin/bash

# ============================================================
# Orion Project
#
# Script:
#   06_up_all.sh
#
# Objetivo:
#   Subir o Orion inteiro, na ordem certa, a partir de um .env
#   já criado (02_create_env_links.sh).
#
# Ordem:
#   1. Rede orion-network
#   2. Segredos (04) e diretórios de storage (05)
#   3. DockerBase (PostgreSQL + Redis), aguardando ficar saudável
#   4. Bancos das Stacks (03)
#   5. Stacks de docker/03_stacks, em ordem numérica
#      (00_example fica de fora; o Portainer é independente).
#
# Idempotente: rodar de novo só sobe o que estiver parado.
#
# Execução:
#   ./06_up_all.sh
#
# ============================================================

set -e

ORION_HOME="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="$ORION_HOME/scripts"

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
echo " Subindo o Orion"
echo "============================================================"

echo
echo "1/5  Rede $ORION_NETWORK"
if docker network inspect "$ORION_NETWORK" >/dev/null 2>&1; then
    echo "     ✔ já existe"
else
    docker network create "$ORION_NETWORK" >/dev/null
    echo "     ✔ criada"
fi

echo
echo "2/5  Segredos e storage"
"$SCRIPTS/04_generate_secrets.sh" | grep -E "Gerados"
"$SCRIPTS/05_prepare_storage.sh" >/dev/null
echo "     ✔ storage pronto"

echo
echo "3/5  DockerBase (PostgreSQL + Redis)"
( cd "$ORION_HOME/docker/02_dockerbase" && docker compose -f docker-compose.dockerbase.yml up -d --wait ) 2>&1 | grep -E "Healthy|Running|Started|error" || true

echo
echo "4/5  Bancos de dados das Stacks"
"$SCRIPTS/03_create_database.sh" 2>&1 | grep -E "📦|Falhou" || true

echo
echo "5/5  Stacks"
FAILED=0

for STACK_DIR in "$ORION_HOME"/docker/03_stacks/*/
do
    NAME="$(basename "$STACK_DIR")"

    [ "$NAME" = "00_example" ] && continue

    COMPOSE_FILE="$(find "$STACK_DIR" -maxdepth 1 -type f \( -name 'docker-compose.yml' -o -name 'docker-compose.yaml' \) | head -n 1)"

    [ -z "$COMPOSE_FILE" ] && continue

    printf "     %-28s" "$NAME"

    if ( cd "$STACK_DIR" && docker compose -f "$(basename "$COMPOSE_FILE")" up -d >/dev/null 2>&1 ); then
        echo "✔"
    else
        echo "❌ falhou (rode 'docker compose up -d' nessa pasta para ver o erro)"
        FAILED=$((FAILED + 1))
    fi
done

echo
echo "============================================================"
if [ "$FAILED" -eq 0 ]; then
    echo " ✔ Orion no ar."
else
    echo " ⚠ $FAILED Stack(s) com falha."
fi
echo
echo " Dashboard: http://localhost:$DASHBOARD_PORT"
echo " Obs.: Cal.com e Chatwoot levam alguns minutos no primeiro boot."
echo "============================================================"
echo

[ "$FAILED" -eq 0 ]
