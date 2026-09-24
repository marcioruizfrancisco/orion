# Orion — Mapa das Stacks

Ponto de partida: **http://localhost:8088** (Dashboard). Ele lista todos os
serviços e mostra quais estão no ar.

Portas, imagens e URLs ficam no `.env` (fonte única de configuração).

## Stacks

| Stack | Serviço | Endereço local | Primeiro acesso |
|---|---|---|---|
| `01_traefik` | Proxy reverso + HTTPS | 80 / 443 | — |
| `02_evolution-api` | API de WhatsApp | http://localhost:9080/manager | chave `EVOLUTION_API_KEY` |
| `03_pgadmin` | Admin do PostgreSQL | http://localhost:5050 | `PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD` |
| `04_uptimekuma` | Monitoramento | http://localhost:3001 | cria o admin na 1ª visita |
| `05_evolution-crm-auth` | Autenticação do CRM (API) | http://localhost:3010 | — |
| `06_evolution-crm` | CRM (API + worker) | http://localhost:3011 | — |
| `07_chatwoot` | Atendimento omnichannel | http://localhost:3020 | cria o super admin na 1ª visita |
| `08_n8n` | Automação de fluxos | http://localhost:5678 | cria o dono na 1ª visita |
| `09_calcom` | Agendamento | http://localhost:3030 | cria o admin na 1ª visita |
| `10_mailpit` | E-mail (SMTP + caixa + API) | http://localhost:8025 | — |
| `11_stripe` | Stripe (mock + webhooks) | http://localhost:12111 | ver abaixo |
| `12_dashboard` | Dashboard | http://localhost:8088 | — |

O Portainer (`docker/01_portainer`) é independente e não sobe pelo `06_up_all.sh`.

## E-mail

Todas as Stacks enviam pelo mesmo SMTP (`SMTP_*` no `.env`), por padrão o
Mailpit. **Nada sai para a internet**: todo e-mail aparece em
http://localhost:8025.

Enviar e-mail pela API:

```bash
curl -X POST http://localhost:8025/api/v1/send \
  -H 'Content-Type: application/json' \
  -d '{"From":{"Email":"no-reply@orion.local"},"To":[{"Email":"cliente@example.com"}],"Subject":"Olá","Text":"Mensagem"}'
```

Para enviar e-mail de verdade (produção), aponte `SMTP_HOST`, `SMTP_PORT`,
`SMTP_USER`, `SMTP_PASSWORD` e `MAIL_FROM_ADDRESS` para um provedor
(Amazon SES, Resend, Brevo, Mailgun...) e recrie as Stacks.

## Stripe

O Stripe é um serviço em nuvem; não existe "instalar o Stripe". A Stack traz:

- **stripe-mock** — API falsa em `http://localhost:12111`. Use qualquer chave
  `sk_test_...`. Serve para desenvolver sem conta e sem internet.
- **stripe-cli** — encaminha webhooks reais (modo teste) para o n8n. Precisa de
  uma chave de **teste** em `STRIPE_SECRET_KEY`
  (https://dashboard.stripe.com/test/apikeys):

  ```bash
  cd orion/docker/03_stacks/11_stripe
  docker compose --profile cli up -d
  docker logs orion-stripe-cli     # mostra o whsec_... do webhook
  ```

  No n8n, crie um workflow com o nó *Webhook* no caminho `stripe`
  (`STRIPE_WEBHOOK_FORWARD_URL` aponta para `/webhook/stripe`).

O Cal.com usa as mesmas variáveis `STRIPE_*` para o app de pagamentos.

## Ir para um servidor

1. `ORION_DOMAIN` com o domínio real e DNS apontando para o servidor.
2. `CHATWOOT_PUBLIC_URL`, `N8N_PUBLIC_URL`, `CALCOM_PUBLIC_URL` para
   `https://<hostname>` (Chatwoot, n8n e Cal.com gravam essa URL em e-mails,
   webhooks e login) e `N8N_SECURE_COOKIE=true`.
3. `TRAEFIK_ACME_EMAIL` real e SMTP de verdade.
4. Recrie as Stacks (`./06_up_all.sh`).

## Incluir um serviço novo no Dashboard

Edite `orion/www/dashboard/services.template.json` (nome, descrição, `url`;
`id` + `probe` para o indicador de status). Se usar variável nova, liste-a em
`environment` no `docker-compose.yml` da Stack `12_dashboard` e recrie o
container.
