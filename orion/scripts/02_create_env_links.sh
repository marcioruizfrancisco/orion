#!/bin/bash

# ============================================================
# Orion Project
#
# Script:
#   02_create_env_links.sh
#
# Objetivo:
#   Preparar o ambiente de configuração do Orion.
#
# Responsabilidades:
#   - Criar o arquivo .env a partir do .env.example
#     caso ainda não exista.
#   - Localizar automaticamente todas as áreas Docker.
#   - Criar links simbólicos relativos para o .env principal.
#   - Nunca sobrescrever arquivos .env existentes.
#
# ============================================================

set -e

# ============================================================
# Remove o arquivo env ( já que estamos fazendo tudo no env.example )
#
# Uso:
#	./02_create_env_links.sh --reset
# ============================================================

if [ "$1" = "--reset" ]; then
    echo "Modo RESET ativado."
    rm -f "$ORION_HOME/.env"
fi


# ============================================================
# Localizar raiz do Orion
# ============================================================

find_orion_root()
{

    CURRENT_DIR="$(pwd)"

    while [ "$CURRENT_DIR" != "/" ]
    do

        if [ -f "$CURRENT_DIR/.env.example" ]; then

            echo "$CURRENT_DIR"
            return 0

        fi

        CURRENT_DIR="$(dirname "$CURRENT_DIR")"

    done

    return 1

}


ORION_HOME=$(find_orion_root)


if [ -z "$ORION_HOME" ]; then

    echo
    echo "❌ Não foi possível localizar a raiz do Orion."
    echo

    exit 1

fi


cd "$ORION_HOME"


echo
echo "============================================================"
echo " Orion Project"
echo " Preparação da Configuração"
echo "============================================================"
echo

echo "Raiz encontrada:"
echo "$ORION_HOME"

echo


# ============================================================
# Criar .env principal
# ============================================================

if [ -f ".env" ]; then

    echo "✔ Arquivo .env encontrado."

else


    if [ ! -f ".env.example" ]; then

        echo "❌ .env.example não encontrado."

        exit 1

    fi


    cp .env.example .env


    echo "✔ Arquivo .env criado."
    echo
    echo "⚠ Revise o arquivo .env antes de iniciar as Stacks."

fi


echo


# ============================================================
# Procurar arquivos docker-compose
# ============================================================

echo "Procurando ambientes Docker..."
echo


declare -A DOCKER_DIRS


while read -r COMPOSE_FILE
do

    DIR="$(dirname "$COMPOSE_FILE")"

    DOCKER_DIRS["$DIR"]=1


done < <(
    find docker \
        -type f \
        \( -name "docker-compose*.yml" -o -name "docker-compose*.yaml" \) \
        | sort
)



FOUND=0
CREATED=0
EXISTING=0
SKIPPED=0


for DOCKER_DIR in "${!DOCKER_DIRS[@]}"
do


    FOUND=$((FOUND + 1))


    ENV_LINK="$ORION_HOME/$DOCKER_DIR/.env"


    if [ -L "$ENV_LINK" ]; then

        echo "✔ Link existente:"
        echo "  $DOCKER_DIR/.env"

        EXISTING=$((EXISTING + 1))

        continue

    fi



    if [ -e "$ENV_LINK" ]; then

        echo "⚠ Arquivo .env manual encontrado:"
        echo "  $DOCKER_DIR/.env"

        echo "  Nenhuma alteração realizada."

        SKIPPED=$((SKIPPED + 1))

        continue

    fi



    RELATIVE_PATH=$(realpath \
        --relative-to="$ORION_HOME/$DOCKER_DIR" \
        "$ORION_HOME/.env"
    )


    ln -s "$RELATIVE_PATH" "$ENV_LINK"


    echo "✔ Link criado:"
    echo "  $DOCKER_DIR/.env -> $RELATIVE_PATH"


    CREATED=$((CREATED + 1))


done



echo
echo "============================================================"
echo "Resumo"
echo "============================================================"
echo

echo "Ambientes encontrados : $FOUND"
echo "Links criados          : $CREATED"
echo "Links existentes       : $EXISTING"
echo "Ignorados              : $SKIPPED"

echo

echo "============================================================"
echo " Configuração finalizada."
echo "============================================================"
echo
