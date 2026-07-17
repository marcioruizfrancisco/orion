# Docker

## Objetivo

Este diretório contém todas as **Stacks Docker** que compõem a infraestrutura do projeto Orion.

Cada Stack representa um serviço independente, podendo ser implantado, atualizado, iniciado ou interrompido sem afetar os demais serviços, respeitando apenas suas dependências técnicas.

A administração das Stacks será realizada preferencialmente através do **Portainer**, mantendo também compatibilidade com a execução via Docker Compose pela linha de comando.

---

# Filosofia

O Orion adota os seguintes princípios para sua infraestrutura Docker:

* Uma Stack representa um único serviço ou conjunto lógico de serviços.
* Cada Stack possui seu próprio diretório.
* Cada Stack possui seu próprio `README.md`.
* Cada Stack possui seu próprio arquivo `docker-compose.<stack>.yml`.
* Todas as Stacks compartilham um único arquivo `.env` localizado na raiz da infraestrutura (`/srv/base/.env`).
* Nenhuma Stack deve depender da estrutura interna de outra Stack.

---

# Estrutura

Cada Stack deverá seguir a estrutura abaixo:

```text
<stack>/
├── README.md
├── docker-compose.<stack>.yml
└── (demais arquivos necessários para a Stack)
```

Exemplo:

```text
docker/
├── dockerbase/
│   ├── README.md
│   └── docker-compose.dockerbase.yml
│
├── evolution-go/
│   ├── README.md
│   └── docker-compose.evolution-go.yml
│
├── n8n/
│   ├── README.md
│   └── docker-compose.n8n.yml
│
└── ...
```

---

# Administração

O gerenciamento das Stacks será realizado preferencialmente pelo **Portainer**, permitindo:

* criação de novas Stacks;
* atualização controlada;
* inicialização e parada de serviços;
* visualização de logs;
* monitoramento do ambiente.

Quando necessário, as mesmas Stacks poderão ser executadas utilizando Docker Compose pela linha de comando.

---

# Convenções

## Diretórios

Os diretórios deverão possuir nomes curtos, descritivos e escritos em letras minúsculas.

Exemplos:

* `dockerbase`
* `evolution-go`
* `n8n`
* `calcom`

---

## Docker Compose

O arquivo Compose deverá seguir o padrão:

```text
docker-compose.<stack>.yml
```

Exemplos:

```text
docker-compose.dockerbase.yml
docker-compose.evolution-go.yml
docker-compose.n8n.yml
```

---

## README

Toda Stack deverá possuir seu próprio `README.md`, contendo no mínimo:

* objetivo;
* descrição dos serviços;
* dependências;
* portas utilizadas;
* volumes persistentes;
* instruções de implantação;
* instruções de atualização;
* histórico de alterações relevantes.

---

# Objetivo de longo prazo

O diretório `docker/` deverá permitir que qualquer nova Stack seja adicionada seguindo exatamente o mesmo padrão, mantendo a infraestrutura organizada, previsível e de fácil manutenção.

A consistência da estrutura é considerada mais importante do que a quantidade de serviços disponíveis.

