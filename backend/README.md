# Makiti Market Backend

Backend API pour l'application Makiti Market, construit avec FastAPI en architecture modular monolith.

## 🏗️ Architecture

- **Framework**: FastAPI
- **Architecture**: Modular Monolith
- **Base de données**: PostgreSQL
- **Cache**: Redis
- **Queue**: RQ (Redis Queue)
- **ORM**: SQLAlchemy (async)
- **Migrations**: Alembic
- **Gestion des dépendances**: Poetry

## 📋 Prérequis

- Python 3.11 ou 3.12 (⚠️ Python 3.14 n'est pas supporté à cause d'asyncpg)
- Poetry
- Docker & Docker Compose
- PostgreSQL 16+ (via Docker)
- Redis 7+ (via Docker)

> **Note importante** : Ce projet nécessite Python 3.11 ou 3.12. Python 3.14 n'est pas compatible avec `asyncpg`. Voir [SETUP.md](SETUP.md) pour les instructions de configuration.

## 🚀 Installation

### 1. Installer Poetry

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

### 2. Installer les dépendances

```bash
cd backend
poetry install
```

### 3. Configuration

Copier le fichier `env.example` vers `.env` et ajuster les variables :

```bash
cp env.example .env
```

### 4. Démarrer les services Docker

```bash
make docker-up
# ou
docker-compose up -d
```

### 5. Exécuter les migrations

```bash
make upgrade
# ou
poetry run alembic upgrade head
```

### 6. Démarrer le serveur de développement

```bash
make run
# ou
poetry run uvicorn app.main:app --reload
```

L'API sera disponible sur `http://localhost:8000`

- Documentation Swagger: `http://localhost:8000/docs`
- Documentation ReDoc: `http://localhost:8000/redoc`

## 📁 Structure du Projet

```
backend/
├── app/
│   ├── api/              # Routes API
│   │   └── v1/
│   │       ├── endpoints/ # Endpoints par domaine
│   │       └── router.py  # Routeur principal
│   ├── core/             # Configuration centrale
│   │   ├── config.py     # Settings
│   │   ├── database.py   # DB configuration
│   │   ├── redis.py      # Redis configuration
│   │   ├── queue.py      # Queue management
│   │   └── logging.py    # Logging configuration
│   ├── modules/          # Modules métier (modular monolith)
│   │   ├── auth/         # Authentification
│   │   ├── products/     # Produits
│   │   ├── orders/       # Commandes
│   │   ├── shoppers/     # Shoppers
│   │   ├── wallet/       # Portefeuilles
│   │   └── notifications/# Notifications
│   └── main.py           # Point d'entrée FastAPI
├── alembic/              # Migrations de base de données
├── tests/                # Tests
├── docker-compose.yml     # Services Docker
├── Dockerfile            # Image Docker
├── pyproject.toml        # Configuration Poetry
└── Makefile              # Commandes utiles
```

## 🛠️ Commandes Utiles

### Développement

```bash
make run              # Démarrer le serveur
make format           # Formater le code
make lint             # Linter le code
make type-check       # Vérifier les types
make test             # Exécuter les tests
make test-cov         # Tests avec couverture
```

### Base de données

```bash
make migrate          # Créer une migration (msg="description")
make upgrade          # Appliquer les migrations
make downgrade        # Rollback dernière migration
```

### Docker

```bash
make docker-up        # Démarrer les conteneurs
make docker-down      # Arrêter les conteneurs
make docker-logs      # Voir les logs
```

### Queue Workers

```bash
make worker           # Démarrer un worker RQ
```

## 🧪 Tests

```bash
# Tous les tests
poetry run pytest

# Avec couverture
poetry run pytest --cov=app --cov-report=html

# Tests spécifiques
poetry run pytest tests/test_products.py
```

## 📝 Linting et Formatage

Le projet utilise plusieurs outils pour maintenir la qualité du code :

- **Black**: Formatage automatique
- **Ruff**: Linting rapide (remplace flake8, isort, etc.)
- **MyPy**: Vérification de types statique

```bash
# Formater
make format

# Linter
make lint

# Type checking
make type-check

# Tout en une fois
make format && make lint && make type-check
```

### Pre-commit Hooks

Installer les hooks pre-commit :

```bash
poetry run pre-commit install
```

## 🔐 Variables d'Environnement

Principales variables à configurer dans `.env` :

- `DATABASE_URL`: URL de connexion PostgreSQL
- `REDIS_URL`: URL de connexion Redis
- `SECRET_KEY`: Clé secrète pour JWT (générer une clé sécurisée)
- `CORS_ORIGINS`: Origines autorisées pour CORS
- `ENVIRONMENT`: `development`, `staging`, `production`

## 📦 Dépendances Principales

- **FastAPI**: Framework web moderne
- **SQLAlchemy**: ORM asynchrone
- **Alembic**: Migrations
- **Pydantic**: Validation de données
- **Redis**: Cache et queue
- **RQ**: Redis Queue pour les tâches asynchrones
- **Structlog**: Logging structuré
- **Python-JOSE**: JWT tokens

## 🐳 Docker

### Développement Local

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f api

# Arrêter
docker-compose down
```

### Build de l'Image

```bash
docker build -t makiti-market-api .
```

## 🔄 Queue System (RQ)

Le projet utilise RQ (Redis Queue) pour les tâches asynchrones.

### Ajouter un Job

```python
from app.core.queue import queue_manager

# Enqueue un job
queue_manager.enqueue("default", my_function, arg1, arg2, kwarg1=value1)
```

### Worker

Démarrer un worker pour traiter les jobs :

```bash
make worker
# ou
poetry run rq worker --url redis://localhost:6379/0
```

## 📚 Documentation API

La documentation interactive est disponible via Swagger UI :

- **Swagger**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🏗️ Architecture Modular Monolith

Le projet suit une architecture modular monolith où chaque module est indépendant :

- Chaque module a ses propres modèles, services, et routes
- Les modules communiquent via des interfaces définies
- Facile à extraire en microservices si nécessaire

## 🚀 Déploiement

### Production

1. Configurer les variables d'environnement
2. Build l'image Docker
3. Configurer la base de données
4. Exécuter les migrations
5. Démarrer les services

### Variables d'Environnement Production

- `ENVIRONMENT=production`
- `DEBUG=false`
- `SECRET_KEY`: Clé secrète forte
- `DATABASE_URL`: URL de production
- `REDIS_URL`: URL Redis de production

## 📖 Ressources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)
- [RQ Documentation](https://python-rq.org/)
- [Poetry Documentation](https://python-poetry.org/docs/)

## 🤝 Contribution

1. Créer une branche pour votre fonctionnalité
2. Faire les modifications
3. Exécuter les tests et le linting
4. Créer une pull request

## 📄 Licence

Propriétaire - Makiti Market

