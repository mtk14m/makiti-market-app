# Guide de Démarrage Rapide - Backend

## 🚀 Démarrage Complet

### 1. Installer les dépendances

```bash
cd backend
poetry install
```

### 2. Configurer l'environnement

```bash
cp env.example .env
# Éditer .env si nécessaire (les valeurs par défaut fonctionnent pour le développement)
```

### 3. Démarrer tous les services Docker

```bash
make docker-up
# ou
docker-compose up -d
```

Cela démarre :
- ✅ PostgreSQL (port 5432)
- ✅ Redis (port 6379)
- ✅ MinIO (port 9000 - API, port 9001 - Console)
- ✅ API Backend (port 8000)

### 4. Accéder à MinIO Console

Ouvrir dans le navigateur : http://localhost:9001

- **Username** : `minioadmin` (par défaut)
- **Password** : `minioadmin123` (par défaut)

### 5. Créer la migration et initialiser la base de données

```bash
# Créer la migration pour la table products
make migrate msg="create_products_table"

# Appliquer la migration
make upgrade
```

### 6. Seed les produits

```bash
make seed
# ou
poetry run python scripts/seed_products.py
```

Cela ajoute 15 produits du marché ouest-africain avec :
- Prix en FCFA
- Catégories : Légumes, Fruits, Viande, Poisson, Épicerie
- Fourchettes de prix (P_min, P_target, P_max)
- URLs d'images Unsplash (temporaires)

### 7. Télécharger et uploader les images dans MinIO

```bash
make download-images
# ou
poetry run python scripts/download_and_upload_images.py
```

Ce script :
- Télécharge les images depuis Unsplash
- Les optimise (JPEG, qualité 85%)
- Les upload dans MinIO
- Met à jour les URLs des produits dans la base de données

### 8. Démarrer le serveur API

```bash
make run
# ou
poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 9. Tester les endpoints

#### Documentation interactive
- **Swagger UI** : http://localhost:8000/docs
- **ReDoc** : http://localhost:8000/redoc

#### Endpoints disponibles

```bash
# Liste des produits (avec pagination et filtres)
GET http://localhost:8000/api/v1/products?page=1&page_size=20

# Filtrer par catégorie
GET http://localhost:8000/api/v1/products?category=Légumes

# Rechercher
GET http://localhost:8000/api/v1/products?search=tomates

# Détail d'un produit
GET http://localhost:8000/api/v1/products/prod-001

# Liste des catégories
GET http://localhost:8000/api/v1/products/categories/list

# Health check
GET http://localhost:8000/health
```

#### Exemples avec curl

```bash
# Liste des produits
curl http://localhost:8000/api/v1/products

# Produits par catégorie
curl "http://localhost:8000/api/v1/products?category=Fruits"

# Recherche
curl "http://localhost:8000/api/v1/products?search=mangue"

# Catégories disponibles
curl http://localhost:8000/api/v1/products/categories/list
```

## 📦 Produits Seedés

Le script seed ajoute 15 produits répartis en 5 catégories :

- **Légumes** : Tomates, Oignons, Pommes de terre, Gombo, Aubergines, Piments, Ail, Gingembre
- **Fruits** : Mangues, Bananes plantain, Ananas
- **Viande** : Poulet frais
- **Poisson** : Poisson frais
- **Épicerie** : Riz local, Huile de palme

Tous les prix sont en FCFA avec des fourchettes de négociation définies.

## 🔧 Commandes Utiles

```bash
# Voir les logs Docker
make docker-logs

# Arrêter les services
make docker-down

# Recréer la base (⚠️ supprime les données)
make docker-down
docker volume rm backend_postgres_data
make docker-up
make upgrade
make seed
```

## 📝 Prochaines Étapes

1. ✅ Module Products créé et testé
2. ⏭️ Module Auth (authentification JWT)
3. ⏭️ Module Orders (commandes)
4. ⏭️ Module Shoppers (performance, notation)
5. ⏭️ Module Wallet (portefeuilles)

## 🐛 Dépannage

### MinIO ne démarre pas
```bash
docker-compose logs minio
```

### Base de données non accessible
```bash
docker-compose ps  # Vérifier que postgres est "healthy"
docker-compose logs postgres
```

### Migration échoue
```bash
# Vérifier la connexion
poetry run python -c "from app.core.config import settings; print(settings.DATABASE_URL)"
```

