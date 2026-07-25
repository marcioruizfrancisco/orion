# Orion — Stack: Traefik

## Objetivo

Reverse proxy da plataforma Orion. Responsável por:

- Rotear cada stack para seu domínio/subdomínio.
- Emitir e renovar certificados SSL automaticamente via Let's Encrypt.
- Redirecionar todo tráfego HTTP para HTTPS.

## Pré-requisitos antes do primeiro `docker compose up`

1. Criar o diretório de armazenamento e o arquivo de certificados com a
   permissão correta (o Traefik recusa iniciar se o arquivo estiver com
   permissão maior que 600):

   ```bash
   mkdir -p "$TRAEFIK_DATA_PATH"
   touch "$TRAEFIK_DATA_PATH/acme.json"
   chmod 600 "$TRAEFIK_DATA_PATH/acme.json"
   ```

2. Confirmar que a rede externa `${ORION_NETWORK}` já existe (criada pela
   stack `02_dockerbase`).

3. Apontar o DNS do domínio/subdomínio desejado para o IP do servidor
   antes de subir a stack — o desafio HTTP do Let's Encrypt só funciona
   se o domínio já resolver corretamente.

## Como expor outra stack através do Traefik

Como `providers.docker.exposedbydefault=false`, nenhuma stack é exposta
por padrão — isso evita vazar acidentalmente um container que não devia
estar público. Para expor uma stack (ex.: Evolution API), adicionar
labels no serviço dela:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.evolution.rule=Host(`${EVOLUTION_HOSTNAME}`)"
  - "traefik.http.routers.evolution.entrypoints=websecure"
  - "traefik.http.routers.evolution.tls.certresolver=orion-resolver"
```

## Dashboard

Desativado por padrão (`TRAEFIK_DASHBOARD_ENABLED=false`). Se ativar,
recomenda-se colocar autenticação básica via label
(`traefik.http.routers.traefik-dashboard.middlewares=...`) antes de
expor publicamente — o dashboard mostra todas as rotas e serviços
configurados no Traefik.

## Variáveis de ambiente

Ver seção "Traefik" no `.env.example` na raiz do projeto.
