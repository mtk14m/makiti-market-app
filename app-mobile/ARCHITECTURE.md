# Architecture de l'Application Makiti

## Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── app.dart                     # Configuration de l'application et providers
│
├── core/                        # Code partagé et configuration
│   └── theme/
│       ├── app_colors.dart      # Palette de couleurs du design system
│       ├── app_text_styles.dart # Styles de texte
│       └── app_theme.dart       # Configuration du thème Material
│
├── domain/                      # Logique métier (Clean Architecture)
│   └── entities/
│       ├── product.dart         # Entité Produit
│       └── cart_item.dart      # Entité Article du panier
│
└── presentation/               # Couche de présentation
    ├── bloc/                   # Gestion d'état avec Bloc
    │   ├── cart/               # Bloc pour le panier
    │   ├── products/           # Bloc pour les produits
    │   └── navigation/         # Bloc pour la navigation
    │
    ├── pages/                  # Écrans de l'application
    │   ├── main_navigation_page.dart  # Page principale avec navigation
    │   ├── home_page.dart      # Page d'accueil
    │   ├── shop_page.dart      # Page boutique
    │   ├── cart_page.dart      # Page panier
    │   └── account_page.dart   # Page compte
    │
    └── widgets/                # Composants réutilisables
        ├── product_card.dart   # Carte produit
        ├── cart_item_widget.dart
        ├── category_chip.dart
        ├── promotion_card.dart
        └── bottom_nav_bar.dart
```

## Gestion d'État avec Bloc

L'application utilise **Flutter Bloc** pour la gestion d'état. Chaque fonctionnalité a son propre bloc :

### CartBloc
- Gère l'état du panier
- Événements : `AddToCart`, `RemoveFromCart`, `UpdateQuantity`, `ClearCart`
- États : `CartInitial`, `CartEmpty`, `CartLoaded`

### ProductsBloc
- Gère le catalogue de produits
- Événements : `LoadProducts`, `FilterProducts`, `SearchProducts`
- États : `ProductsInitial`, `ProductsLoading`, `ProductsLoaded`, `ProductsError`

### NavigationBloc
- Gère la navigation entre les pages principales
- Événements : `NavigateToHome`, `NavigateToShop`, `NavigateToCart`, `NavigateToAccount`
- États : `NavigationHome`, `NavigationShop`, `NavigationCart`, `NavigationAccount`

## Design System

Les couleurs et styles suivent le design system Makiti :

- **Vert clair** (`#4CAF50`) : Boutons CTA, navigation active
- **Vert foncé** (`#2E7D32`) : Cartes promotionnelles
- **Jaune** (`#FFC107`) : Accents, badges
- **Gris foncé** (`#212121`) : Texte principal
- **Gris clair** (`#757575`) : Texte secondaire

> ⚠️ **Note** : Les couleurs sont des valeurs approximatives. Elles doivent être validées avec les maquettes exactes selon `/docs/09-specifications-couleurs-exactes.md`

## Prochaines Étapes

### Pour connecter au backend :

1. **Créer les repositories** dans `data/repositories/`
2. **Créer les modèles de données** dans `data/models/` (DTOs)
3. **Ajouter les services API** pour communiquer avec le backend
4. **Mettre à jour les blocs** pour utiliser les repositories au lieu des données mock
5. **Ajouter la gestion d'erreurs** et les états de chargement

### Fonctionnalités à implémenter :

- [ ] Authentification (login/register)
- [ ] Recherche de produits
- [ ] Filtres avancés
- [ ] Détails produit
- [ ] Checkout et paiement
- [ ] Suivi de commande
- [ ] Profil utilisateur
- [ ] Historique des commandes

## Commandes Utiles

```bash
# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run

# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Générer les fichiers (si utilisation de code generation)
flutter pub run build_runner build
```


