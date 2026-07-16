#!/bin/bash

# ============================================================
# Orion Project
#
# Script:
#   02_check_environment.sh
#
# Objetivo:
#   Verificar se o ambiente atual está preparado para
#   executar o Orion.
#
# Descrição:
#   Este script apenas analisa o ambiente.
#   Nenhuma instalação ou alteração será realizada.
#
# Tornar executável:
#   sudo chmod +x 02_check_environment.sh
#
# Execução:
#   ./02_check_environment.sh
#
# Versão:
#   1.0.0
#
# ============================================================


# ============================================================
# Configurações
# ============================================================

ERRORS=0
WARNINGS=0


# ============================================================
# Identifica a raiz do projeto Orion
# ============================================================

ORION_HOME="$(cd "$(dirname "$0")/.." && pwd)"


echo ""
echo "=============================================="
echo " Orion Project"
echo " Verificação do Ambiente"
echo "=============================================="
echo ""

echo "Usuário:"
echo "$(whoami)"

echo ""

echo "Máquina:"
echo "$(hostname)"

echo ""

echo "Projeto:"
echo "$ORION_HOME"

echo ""


# ============================================================
# Sistema Operacional
# ============================================================

echo "----------------------------------------------"
echo "Sistema Operacional"
echo "----------------------------------------------"


if [ -f /etc/os-release ]; then

    source /etc/os-release

    echo "Sistema:"
    echo "$PRETTY_NAME"

    if [[ "$ID" == "ubuntu" ]]; then
        echo "✔ Ubuntu detectado"
    else
        echo "⚠ Sistema diferente de Ubuntu"
        WARNINGS=$((WARNINGS+1))
    fi

else

    echo "❌ Não foi possível identificar o sistema"
    ERRORS=$((ERRORS+1))

fi


echo ""


# ============================================================
# Git
# ============================================================

echo "----------------------------------------------"
echo "Git"
echo "----------------------------------------------"


if command -v git >/dev/null 2>&1; then

    echo "✔ Git instalado"
    git --version

else

    echo "❌ Git não encontrado"
    ERRORS=$((ERRORS+1))

fi


echo ""


# ============================================================
# Docker
# ============================================================

echo "----------------------------------------------"
echo "Docker"
echo "----------------------------------------------"


if command -v docker >/dev/null 2>&1; then

    echo "✔ Docker instalado"
    docker --version

else

    echo "❌ Docker não encontrado"
    ERRORS=$((ERRORS+1))

fi


echo ""


# ============================================================
# Docker Compose
# ============================================================

echo "----------------------------------------------"
echo "Docker Compose"
echo "----------------------------------------------"


if docker compose version >/dev/null 2>&1; then

    echo "✔ Docker Compose instalado"
    docker compose version

else

    echo "❌ Docker Compose não encontrado"
    ERRORS=$((ERRORS+1))

fi


echo ""


# ============================================================
# Permissão Docker
# ============================================================

echo "----------------------------------------------"
echo "Permissão Docker"
echo "----------------------------------------------"


if docker ps >/dev/null 2>&1; then

    echo "✔ Usuário possui acesso ao Docker"

else

    echo "❌ Usuário sem permissão para acessar Docker"
    echo ""
    echo "Execute:"
    echo ""
    echo "sudo usermod -aG docker \$USER"
    echo ""
    echo "Depois faça logout/login."
    
    ERRORS=$((ERRORS+1))

fi


echo ""


# ============================================================
# Recursos da máquina
# ============================================================

echo "----------------------------------------------"
echo "Recursos da Máquina"
echo "----------------------------------------------"


echo "Espaço em disco:"
df -h / | tail -1

echo ""

echo "Memória:"
free -h | grep Mem


echo ""


# ============================================================
# Resultado Final
# ============================================================

echo "=============================================="
echo " Resultado da Verificação"
echo "=============================================="

echo ""
echo "Erros encontrados:"
echo "$ERRORS"

echo "Avisos:"
echo "$WARNINGS"

echo ""


if [ $ERRORS -eq 0 ]; then

    echo "✔ Ambiente pronto para continuar com o Orion"

else

    echo "❌ Existem pendências antes de continuar"

fi


echo ""
echo "=============================================="
echo ""
