# Makiti Market - Application Mobile

Application Flutter pour la plateforme Makiti - Courses de marché premium pour l'Afrique de l'Ouest.

## Architecture

- **State Management**: Flutter Bloc
- **Navigation**: GoRouter
- **Design System**: Basé sur les spécifications du design system Makiti

## Structure du Projet

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── constants/
├── data/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   ├── widgets/
│   └── router/
└── utils/
```

## Installation

```bash
flutter pub get
flutter run
```

## Design System

Les couleurs et styles suivent le design system Makiti défini dans `/docs/08-design-system-complet.md` et `/docs/09-specifications-couleurs-exactes.md`.


