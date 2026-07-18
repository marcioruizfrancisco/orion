# 03_create_database.sh

## Objetivo

Provisionar automaticamente os bancos de dados PostgreSQL utilizados pelas Stacks do Orion.

O objetivo deste script é eliminar completamente a necessidade de acessar manualmente o PostgreSQL para criar bancos, usuários e permissões.

Cada Stack é responsável pelos seus próprios scripts SQL, enquanto o Orion é responsável apenas por localizá-los e executá-los.

---

## Estrutura esperada

Toda Stack que utilizar PostgreSQL deverá possuir a seguinte estrutura:

03_stacks/

└── nome-da-stack/

    └── database/

        └── postgres/

            ├── 001_create_database.sql

            └── README.md

---

## Funcionamento

O script irá:

1. Verificar se o DockerBase está disponível.
2. Localizar automaticamente todas as Stacks que possuam scripts PostgreSQL.
3. Executar os scripts na ordem numérica.
4. Informar o resultado da execução.
5. Permitir múltiplas execuções sem causar erros (scripts idempotentes).

---

## O que o script NÃO faz

O script não:

- cria containers;
- inicia serviços Docker;
- altera configurações do PostgreSQL;
- conhece detalhes das aplicações.

Toda regra específica permanece dentro da própria Stack.

---

## Como executar

sudo ./03_create_database.sh

---

## Requisitos

- DockerBase iniciado.
- Container PostgreSQL em execução.
- Arquivo .env configurado.
- Scripts SQL presentes na Stack.

---

## Filosofia

Cada Stack é dona dos seus próprios recursos.

O Orion apenas automatiza sua criação.
