#!/bin/bash

# ============================================================
# Orion Project
#
# Script:
#   04_generate_secrets.sh
#
# Objetivo:
#   Substituir os valores "troque-..." do .env por segredos
#   aleatórios (senhas de banco, chaves do Rails, chave do n8n...).
#
# Regras:
#   - Só altera chave vazia ou ainda com valor "troque-...".
#     Valor já definido NUNCA é sobrescrito (idempotente).
#   - Nunca imprime os valores gerados.
#   - Rodar ANTES de 03_create_database.sh: as senhas de banco são
#     gravadas no PostgreSQL na hora do provisionamento.
#
# Execução:
#   ./04_generate_secrets.sh
#
# ============================================================

set -e

ORION_HOME="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ORION_HOME/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env não encontrado. Execute primeiro ./02_create_env_links.sh"
    exit 1
fi

echo
echo "============================================================"
echo " Orion Project"
echo " Geração de segredos"
echo "============================================================"
echo

get_value()
{
    grep -E "^$1=" "$ENV_FILE" | tail -n 1 | cut -d= -f2-
}

set_value()
{
    if grep -qE "^$1=" "$ENV_FILE"; then
        sed -i -E "s|^$1=.*|$1=$2|" "$ENV_FILE"
    else
        echo "$1=$2" >> "$ENV_FILE"
    fi
}

needs_value()
{
    local CURRENT
    CURRENT="$(get_value "$1")"
    [ -z "$CURRENT" ] || [[ "$CURRENT" == troque-* ]]
}

GENERATED=0
KEPT=0

# nome_da_variavel:bytes  (o valor final tem 2x esse tamanho em hexadecimal)
SECRETS=(
    "EVOAUTH_SECRET_KEY_BASE:64"
    "EVOCRM_SECRET_KEY_BASE:64"
    "CHATWOOT_SECRET_KEY_BASE:64"
    "CALCOM_NEXTAUTH_SECRET:32"
    "CALCOM_ENCRYPTION_KEY:16"
    "N8N_ENCRYPTION_KEY:32"
    "EVOAUTH_DB_PASSWORD:16"
    "EVOCRM_DB_PASSWORD:16"
    "CHATWOOT_DB_PASSWORD:16"
    "N8N_DB_PASSWORD:16"
    "CALCOM_DB_PASSWORD:16"
)

for ITEM in "${SECRETS[@]}"
do
    NAME="${ITEM%%:*}"
    BYTES="${ITEM##*:}"

    if needs_value "$NAME"; then
        set_value "$NAME" "$(openssl rand -hex "$BYTES")"
        echo "✔ $NAME gerado"
        GENERATED=$((GENERATED + 1))
    else
        echo "· $NAME já definido (mantido)"
        KEPT=$((KEPT + 1))
    fi
done

# O Doorkeeper do evo-auth aceita reutilizar o SECRET_KEY_BASE.
if needs_value "DOORKEEPER_JWT_SECRET_KEY"; then
    set_value "DOORKEEPER_JWT_SECRET_KEY" "$(get_value EVOAUTH_SECRET_KEY_BASE)"
    echo "✔ DOORKEEPER_JWT_SECRET_KEY gerado (igual ao EVOAUTH_SECRET_KEY_BASE)"
    GENERATED=$((GENERATED + 1))
else
    echo "· DOORKEEPER_JWT_SECRET_KEY já definido (mantido)"
    KEPT=$((KEPT + 1))
fi

echo
echo "Gerados: $GENERATED   Mantidos: $KEPT"
echo
