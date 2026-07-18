#!/bin/bash

# ============================================================
# Orion Project
#
# Script:
#   03_create_database.sh
#
# Objetivo:
#   Provisionar automaticamente os bancos PostgreSQL das
#   Stacks do Orion.
#
# Responsabilidades:
#   - Carregar o arquivo .env
#   - Localizar as Stacks PostgreSQL
#   - Executar os scripts de provisionamento
#
# ============================================================

set -e

# ============================================================
# Diretório raiz do Orion
# ============================================================

ORION_HOME="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ORION_HOME"

echo
echo "============================================================"
echo " Orion Project"
echo " Provisionamento PostgreSQL"
echo "============================================================"
echo


# ============================================================
# Carregar configurações
# ============================================================

if [ ! -f ".env" ]; then

    echo "❌ Arquivo .env não encontrado."
    echo
    echo "Execute primeiro:"
    echo
    echo "    ./scripts/02_create_env_links.sh"
    echo
    exit 1

fi

source .env

echo "✔ Arquivo .env carregado."
echo

# ============================================================
# Validar Docker
# ============================================================

if ! command -v docker >/dev/null 2>&1; then

    echo "❌ Docker não encontrado."
    exit 1

fi

echo "✔ Docker encontrado."

    
# ============================================================
# Validar infraestrutura
# ============================================================
    
echo "Verificando PostgreSQL..."

if docker ps \
    --format "{{.Names}}" \
    | grep -q "^${POSTGRES_CONTAINER_NAME}$"
then

    echo "✔ PostgreSQL em execução."

else

    echo "❌ Container PostgreSQL não está em execução."
    exit 1

fi

echo



# ============================================================
# Procurar automaticamente as Stacks PostgreSQL
# ============================================================

echo
echo "============================================================"
echo " Procurando Stacks PostgreSQL..."
echo "============================================================"
echo

STACKS_FOUND=0
SCRIPTS_FOUND=0

while read -r POSTGRES_DIR
do

    STACKS_FOUND=$((STACKS_FOUND + 1))

    STACK_NAME="$(basename "$(dirname "$(dirname "$POSTGRES_DIR")")")"

    echo

    printf "📦 %-30s\n" "$STACK_NAME"

    if [ -z "$POSTGRES_USER" ]; then

    	echo "❌ POSTGRES_USER não definido no .env"
	exit 1

    fi
    while read -r SCRIPT
    do

        SCRIPTS_FOUND=$((SCRIPTS_FOUND + 1))

        
        echo "   └── $(basename "$SCRIPT")"
        
        
#        echo "Debug"
	echo "Container PostgreSQL: [$POSTGRES_CONTAINER_NAME]"
	echo "Postgres User : [$POSTGRES_USER]"

	if   docker exec \
	    -u postgres \
	    -e POSTGRES_USER="$POSTGRES_USER" \
	    -e EVOLUTION_DB_NAME="$EVOLUTION_DB_NAME" \
	    -e EVOLUTION_DB_USER="$EVOLUTION_DB_USER" \
	    -e EVOLUTION_DB_PASSWORD="$EVOLUTION_DB_PASSWORD" \
	    -i "$POSTGRES_CONTAINER_NAME" \
	    bash < "$SCRIPT"
	then

	    echo "      ✔ Sucesso"

	else

	    echo "      ❌ Falhou"

	fi

        # Aqui futuramente executaremos:
        #
        # bash "$SCRIPT"
        #

    done < <(
        find "$POSTGRES_DIR" \
            -maxdepth 1 \
            -type f \
            -name "*.sh" \
            | sort
    )

done < <(
    find docker/03_stacks \
        -type d \
        -path "*/database/postgres" \
        | sort
)


# echo
# echo "DEBUG"
# echo "POSTGRES_USER=$POSTGRES_USER"
# echo "EVOLUTION_DB_NAME=$EVOLUTION_DB_NAME"
# echo "EVOLUTION_DB_USER=$EVOLUTION_DB_USER"
# echo "EVOLUTION_DB_PASSWORD=$EVOLUTION_DB_PASSWORD"
# echo

# ============================================================
# Executar provisionamento
# ============================================================

# Para cada Stack encontrada
#
# executar:
#
# 001_*.sh
# 002_*.sh
# 003_*.sh
#
# sempre em ordem

# ============================================================
# Resumo
# ============================================================

# Total de Stacks

# Total de scripts

# Sucessos

# Falhas

echo
echo "============================================================"
echo " Provisionamento concluído."
echo "============================================================"
echo
