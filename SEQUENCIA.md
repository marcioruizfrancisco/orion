1 - Abra o Terminal
2 - Navegue até o Orion ( orion ) 
2 - comando tree para ver a arvore
4 - Navegue até o diretorio Stacks ( criar alias ) : cd orion/docker/03_stacks
5 - Crie o diretorio da Stack:  mkdir 03_pgadmin
6 - De permissao ao diretorio: chmod 0777 -R 03_pgadmin
7 - Entre no diretorio novo: cd 03_pgadmin
8 - Crie o arquivo docker-compose.yml com base no example: 
cp ../00_example/docker-compose.example.yml  docker-compose.yaml
9 - Altere o arquivo docker : gedit docker-compose.yaml
10 - Se não souber o healthcheck, pergunte para a IA
11 - Altere o texto EXAMPLE por PGADMIN
12 - Leve as variaves para o arquivo env.example: gedit ../../../.env.example

13 - Veja em https://hub.docker.com/ a versao que será usada
14 - Crie o diretorio em "storage" ou "www" conforme for o caso: 
mkdir ../../../storage/pgadmin 
15 - De permissao 0666 no diretorio, confirmar com a IA: chmod 0666 -R ../../../storage/pgadmin
16 - Entrar no diretorio scripts: cd ../../../scripts/
17 - Rodar o script de copiar o env.example: ./02_create_env_links.sh --reset
18 - Rodar o script de criar o banco quando for o caso: ./03_create_database.sh
19 - Checar o UPTIME ( quando estiver pronto)
20 - Subir os container na sequencia

20.1 ir para o diretorio: cd ../docker/02_dockerbase
20.2 subir o docker : docker compose -f docker-compose.dockerbase.yml up -d

20.3 ir para o diretorio: cd ../03_stacks/01_traefik/
20.4 - subir o docker : docker compose -f docker-compose.yml up -d

20.5 - ir para o diretorio: cd ../02_evolution-api/
20.6 - subir o docker : docker compose -f docker-compose.yml up -d

20.7 - ir para o diretorio: cd ../03_pgadmin/
20.8 - subir o docker : docker compose -f docker-compose.yml up -d

20.7 - ir para o diretorio: cd ../04_uptimekuma/
20.8 - subir o docker : docker compose -f docker-compose.yml up -d





 
