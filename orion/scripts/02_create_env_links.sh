#!/bin/bash

# ============================================================
# Orion Project
#
# Script:
#   02_create_env_links.sh
#
# Objetivo:
#   Inicializar o ambiente de configuração do Orion.
#
# Responsabilidades:
#   - Criar o arquivo .env a partir do .env.example
#     caso ainda não exista.
#   - Criar automaticamente os links simbólicos para todas
#     as Stacks Docker do Orion.
#   - Nunca sobrescrever um arquivo .env existente.
#
# Execução:
#   ./02_create_env_links.sh
#
# Tornar executável:
#   sudo chmod +x 02_create_env_links.sh
#
# ============================================================

set -e

# ============================================================
# Diretório raiz do Orion
# ============================================================

ORION_HOME="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ORION_HOME"

SCRIPT_NAME="$(basename "$0")"

echo
echo "============================================================"
echo " Orion Project"
echo " Inicialização do Ambiente"
echo " "
echo " Copiando arquivo de configuração para as Stacks..."
echo "============================================================"
echo

# ============================================================
# Verificação do arquivo .env
# ============================================================

if [ -f ".env" ]; then

    echo "✔ Arquivo .env encontrado."

else

    echo "⚠ Arquivo .env não encontrado."

    if [ ! -f ".env.example" ]; then

        echo
        echo "❌ Arquivo .env.example não encontrado."
        echo
        echo "Não é possível inicializar o ambiente."
        exit 1

    fi

    cp .env.example .env

    echo "✔ Arquivo .env criado a partir do .env.example."
    echo
    echo "ATENÇÃO:"
    echo "Revise o arquivo .env antes de iniciar as Stacks."
    echo

fi

# ============================================================
# Procura automaticamente todas as Stacks Docker
# ============================================================

echo
echo "Procurando arquivos Docker Compose..."
echo

STACKS_FOUND=0
STACKS_CONFIGURED=0

while read -r COMPOSE_FILE
do

    STACKS_FOUND=$((STACKS_FOUND + 1))

    STACK_DIR="$(dirname "$COMPOSE_FILE")"

    ln -sfn ../../.env "$STACK_DIR/.env"

    if [ -L "$STACK_DIR/.env" ]; then

        echo "✔ $STACK_DIR"

        STACKS_CONFIGURED=$((STACKS_CONFIGURED + 1))

    else

        echo "❌ Falha ao criar link em:"
        echo "   $STACK_DIR"

    fi

done < <(
    find docker -type f \
        \( -name "docker-compose*.yml" -o -name "docker-compose*.yaml" \) \
        | sort
)

echo
echo "============================================================"
echo "Resumo"
echo "============================================================"
echo

echo "Stacks encontradas : $STACKS_FOUND"
echo "Stacks configuradas: $STACKS_CONFIGURED"

if [ "$STACKS_FOUND" -eq 0 ]; then

    echo
    echo "⚠ Nenhuma Stack Docker encontrada."

fi

echo
echo "============================================================"
echo " Ambiente preparado."
echo "============================================================"
echo
