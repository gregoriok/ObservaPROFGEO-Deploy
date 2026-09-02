# ObservaPROFGEO - Deploy

Docker Compose e scripts para rodar o projeto ObservaPROFGEO completo.

## Pre-requisitos

- [Docker](https://docs.docker.com/get-docker/) e Docker Compose instalados
- [Git](https://git-scm.com/)

## Como rodar

1. Clone este repositorio:

```bash
git clone https://github.com/gregoriok/ObservaPROFGEO-Deploy.git
cd ObservaPROFGEO-Deploy
```

2. Suba os containers (o Docker vai clonar e buildar os repos automaticamente):

```bash
docker compose up -d --build
```

3. (Primeira vez) Configure o GeoServer:

```bash
bash scripts/setup_unidade_padrao.sh
bash scripts/setup_geoserver.sh
```

## Servicos

| Servico    | URL                          |
|------------|------------------------------|
| Frontend   | http://localhost              |
| Backend    | http://localhost:8000         |
| API Docs   | http://localhost:8000/docs    |
| GeoServer  | http://localhost:8080         |
| MapStore   | http://localhost:8081         |
| PostgreSQL | localhost:5433               |

## Comandos uteis

```bash
# Parar tudo
docker compose down

# Rebuild do frontend
docker compose build frontend && docker compose up -d frontend

# Rebuild do backend
docker compose build backend && docker compose up -d backend

# Ver logs
docker compose logs -f backend
```
