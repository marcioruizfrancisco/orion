# DockerBase

Infraestrutura base compartilhada do Orion.

A DockerBase fornece serviços de infraestrutura utilizados por múltiplas Stacks do Orion.

Seu objetivo é disponibilizar uma base comum, estável e padronizada para as aplicações, evitando que cada Stack precise instalar e gerenciar seus próprios serviços de infraestrutura.

---

# Serviços disponíveis

Atualmente a DockerBase possui:

## PostgreSQL

Banco de dados relacional utilizado pelas aplicações do Orion.

Container:

```
orion-postgres
```

---

## Redis

Serviço de cache, sessões e filas utilizado pelas aplicações do Orion.

Container:

```
orion-redis
```

---

# Arquitetura

A DockerBase utiliza:

* Rede Docker compartilhada;
* Configuração centralizada no `.env`;
* Armazenamento persistente dentro do diretório `storage` do Orion.

Estrutura esperada:

```
orion/

├── docker/
│   └── dockerbase/
│       └── docker-compose.dockerbase.yml
│
├── storage/
│   ├── postgres/
│   └── redis/
│
└── .env
```

---

# Rede

Todas as Stacks do Orion utilizam a rede:

```
orion-network
```

A rede é criada externamente e compartilhada entre os serviços.

Isso permite que novas aplicações possam utilizar a infraestrutura existente sem criar redes próprias.

---

# Persistência de dados

O Orion não utiliza volumes Docker gerenciados para dados críticos.

Os dados persistentes ficam armazenados dentro do diretório:

```
storage/
```

Exemplo:

```
storage/postgres
storage/redis
```

Essa abordagem permite:

* backup simplificado;
* migração entre máquinas;
* reinstalação do Docker sem perda de dados;
* maior controle sobre os arquivos persistentes.

---

# Configuração

Todas as configurações são definidas no arquivo:

```
.env
```

Exemplos de variáveis utilizadas:

```env
POSTGRES_IMAGE=
POSTGRES_CONTAINER_NAME=
POSTGRES_DATA_PATH=

REDIS_IMAGE=
REDIS_CONTAINER_NAME=
REDIS_DATA_PATH=
```

Nenhuma informação sensível deve ser armazenada diretamente no arquivo:

```
docker-compose.dockerbase.yml
```

---

# Instalação

Antes de iniciar a DockerBase, certifique-se que:

* Docker está instalado;
* Docker Compose está disponível;
* arquivo `.env` foi configurado;
* rede `orion-network` existe.

Para iniciar:

```bash
docker compose -f docker-compose.dockerbase.yml up -d
```

---

# Verificação

Verificar containers:

```bash
docker ps
```

Resultado esperado:

```
orion-postgres
orion-redis
```

---

Verificar rede:

```bash
docker network ls
```

Resultado esperado:

```
orion-network
```

---

# Testes realizados

## PostgreSQL

Validado:

* criação do container;
* conexão com banco;
* armazenamento persistente;
* reinicialização do container;
* preservação dos dados.

Resultado:

```
OK
```

---

## Redis

Validado:

* criação do container;
* funcionamento do serviço;
* persistência via AOF;
* reinicialização do container;
* recuperação dos dados.

Resultado:

```
OK
```

---

# Manutenção

Parar a Stack:

```bash
docker compose -f docker-compose.dockerbase.yml down
```

Iniciar novamente:

```bash
docker compose -f docker-compose.dockerbase.yml up -d
```

Os dados armazenados em `storage` permanecem preservados.

---

# Decisões arquiteturais

## Uma Stack = Uma responsabilidade

A DockerBase contém apenas serviços de infraestrutura compartilhados.

Novas aplicações devem criar suas próprias Stacks.

---

## O Docker não é dono dos dados

O Docker executa os serviços.

O Orion mantém os dados.

---

## Configuração centralizada

Todas as Stacks utilizam o arquivo `.env` principal do Orion.

---

# Próximas evoluções

Possíveis serviços futuros poderão ser avaliados para inclusão na DockerBase quando forem utilizados por múltiplas Stacks.

Exemplos:

* RabbitMQ;
* serviços de armazenamento;
* outros componentes compartilhados.

A inclusão de novos serviços deve sempre respeitar o princípio:

> Um serviço pertence à DockerBase quando sua utilização é compartilhada por múltiplas Stacks do Orion.

