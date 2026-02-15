# Instructions de Configuration

## Problème avec Python 3.14

Le package `asyncpg` n'est pas encore compatible avec Python 3.14 car il utilise des API internes de Python qui ont changé. 

**Solution : Utiliser Python 3.11 ou 3.12**

## Configuration de la version Python

### Option 1 : Utiliser pyenv (Recommandé)

```bash
# Installer Python 3.12
pyenv install 3.12.0

# Définir la version locale pour le projet
cd backend
pyenv local 3.12.0

# Vérifier la version
python --version  # Devrait afficher Python 3.12.0
```

### Option 2 : Utiliser Poetry avec une version spécifique

```bash
# Si vous avez Python 3.12 installé
poetry env use python3.12

# Puis installer les dépendances
poetry install
```

### Option 3 : Utiliser un environnement virtuel manuel

```bash
# Créer un environnement virtuel avec Python 3.12
python3.12 -m venv .venv

# Activer l'environnement
source .venv/bin/activate  # Sur macOS/Linux
# ou
.venv\Scripts\activate  # Sur Windows

# Installer Poetry dans cet environnement
pip install poetry

# Installer les dépendances
poetry install
```

## Vérification

Après avoir configuré Python 3.11 ou 3.12, vous pouvez vérifier :

```bash
python --version  # Doit afficher 3.11.x ou 3.12.x
poetry env info   # Affiche l'environnement Poetry actuel
```

## Installation des dépendances

Une fois la bonne version de Python configurée :

```bash
poetry install
```

Cela devrait maintenant fonctionner sans erreur avec `asyncpg`.


