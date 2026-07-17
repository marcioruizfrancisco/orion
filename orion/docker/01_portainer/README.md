## Cenários de instalação

### Ambiente novo

Utilize esta Stack quando o Orion for instalado em uma máquina sem Portainer.

### Ambiente existente

Não execute esta Stack caso já exista um Portainer administrando o Docker.




# vá até o Diretorio do Portainer

cd /srv/base/orion/

cd docker/portainer/


# Execute o docker-compose

docker compose -f docker-compose.portainer.yml up -d

# Verifique se o container está rodando

docker ps

## Valor esperado
# orion_portainer

# Para acessar

https://localhost:9443



