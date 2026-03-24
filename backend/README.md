# Makiti Backend

Backend FastAPI de Makiti pour :
- la marketplace C2C
- la logistique box-to-box
- l'authentification et l'orchestration métier

## Stack

- Python 3.11 ou 3.12
- FastAPI
- PostgreSQL
- Redis
- Alembic
- uv
- Docker / Docker Compose

## Modules backend

- `auth` : identité, OTP, rôles
- `commerce` : listings, commandes marketplace
- `logistics` : boxes, parcels, shipments

## Démarrage rapide

```bash
cd backend
cp env.example .env
uv sync --group dev --group test
make docker-up
make upgrade
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API:
- Swagger: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Commandes utiles

```bash
make run
make test
make lint
make type-check
make upgrade
make migrate msg="create_initial_platform_schema"
make setup-minio
make check-minio
```

## Notes

- Poetry n'est plus utilisé.
- Les anciens modules `products`, `shoppers`, `wallet`, `orders` ont été retirés.
- Les anciennes migrations legacy ont été nettoyées. Il faut maintenant recréer une base Alembic cohérente avec les modèles actuels.
- Le seul fichier Compose à utiliser est [docker-compose.yml](/Volumes/PARTMAC/dev/projects/makiti-market-app/docker-compose.yml) à la racine du repo.
