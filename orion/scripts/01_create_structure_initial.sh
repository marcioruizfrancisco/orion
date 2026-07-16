#!/bin/bash

# ============================================================
# Orion Project
#
# Script:
#   01_create_structure_initial.sh
#
# Tornar executável:
# sudo chmod +x 01_create_structure_initial.sh
#
# Objetivo:
#   Criar a estrutura inicial de diretórios do projeto Orion.
#
# Descrição:
#   Este script deve ser executado a partir do diretório
#   scripts do projeto Orion.
#
#   Ele cria os diretórios base da estrutura do projeto e
#   arquivos .gitkeep para manter diretórios vazios versionados.
#
# Execução:
#   ./01_create_structure_initial.sh
#
# Versão:
#   1.0.0
#
# ============================================================


# ============================================================
# Identifica a raiz do projeto Orion
# ============================================================

ORION_HOME="$(cd "$(dirname "$0")/.." && pwd)"


echo ""
echo "=============================================="
echo " Orion - Criando estrutura inicial"
echo "=============================================="
echo ""

echo "Diretório raiz:"
echo "$ORION_HOME"

echo ""


# ============================================================
# Criação dos diretórios principais
# ============================================================

DIRECTORIES=(
    "docker"
    "docs"
    "logs"
    "storage"
    "workspace"
)


echo "Criando diretórios..."

for DIR in "${DIRECTORIES[@]}"
do
    mkdir -p "$ORION_HOME/$DIR"
    echo " ✔ $DIR"
done


echo ""


# ============================================================
# Criação dos arquivos .gitkeep
# ============================================================

GITKEEP_FILES=(
    "logs/.gitkeep"
    "storage/.gitkeep"
    "workspace/.gitkeep"
)


echo "Criando arquivos .gitkeep..."

for FILE in "${GITKEEP_FILES[@]}"
do
    touch "$ORION_HOME/$FILE"
    echo " ✔ $FILE"
done


echo ""

echo "=============================================="
echo " Estrutura Orion criada com sucesso"
echo "=============================================="
echo ""
