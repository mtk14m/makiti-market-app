# Guide de Démarrage Rapide

## 1. Installer les dépendances

```bash
cd backend
uv sync --group dev --group test
```

## 2. Configurer l'environnement

```bash
cp env.example .env
```

## 3. Lancer les services

```bash
make docker-up
```

Services attendus :
- PostgreSQL
- Redis
- MinIO
- API backend

Le `Makefile` backend utilise le fichier Compose racine du repo.

## 4. Initialiser la base

```bash
make upgrade
```

## 5. Lancer l'API

```bash
make run
```

## 6. Vérifier

- Swagger UI: `http://localhost:8000/docs`
- Health: `http://localhost:8000/health`

## Endpoints principaux

```bash
GET  /api/v1/health
POST /api/v1/auth/send-otp
POST /api/v1/auth/verify-otp
POST /api/v1/auth/register
POST /api/v1/auth/login
GET  /api/v1/commerce/listings
POST /api/v1/commerce/listings
POST /api/v1/commerce/orders
GET  /api/v1/logistics/boxes
GET  /api/v1/logistics/parcels
GET  /api/v1/logistics/shipments
```

## MinIO

```bash
make setup-minio
make check-minio
```

Le bucket par defaut est `makiti-assets`.
