#!/bin/sh
# Executado pelo entrypoint do nginx antes de subir o servidor.
#
#  1. Copia o site (montado somente-leitura em /site) para a pasta pública.
#  2. Preenche o services.json com as portas/URLs/containers do .env.
#  3. Gera a configuração do nginx com uma rota /probe/<id> para cada
#     serviço que tem "probe" no JSON. Quem responde ao navegador é o
#     nginx (por dentro da rede Docker): não depende de CORS, de
#     certificado HTTPS nem de porta exposta no host.
set -e

cp -r /site/. /usr/share/nginx/html/
envsubst < /site/services.template.json > /usr/share/nginx/html/services.json
rm -f /usr/share/nginx/html/services.template.json

{
cat <<'CONF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    # DNS interno do Docker; resolve o nome do container a cada verificação,
    # então o nginx sobe mesmo com serviços ainda parados.
    resolver 127.0.0.11 valid=5s ipv6=off;

    location / {
        try_files $uri $uri/ =404;
    }

    location = /services.json {
        add_header Cache-Control "no-store";
    }

CONF

awk '
    /"id"/    { id = $2; gsub(/[",]/, "", id) }
    /"probe"/ { url = $2; gsub(/[",]/, "", url); print id, url }
' /usr/share/nginx/html/services.json | while read -r ID URL
do
    cat <<CONF
    location = /probe/$ID {
        set \$probe_target "$URL";
        proxy_pass \$probe_target;
        proxy_connect_timeout 2s;
        proxy_read_timeout 3s;
        proxy_intercept_errors off;
        access_log off;
        add_header Cache-Control "no-store";
    }

CONF
done

echo "}"
} > /etc/nginx/conf.d/default.conf

echo "[orion-dashboard] services.json e rotas /probe gerados."
