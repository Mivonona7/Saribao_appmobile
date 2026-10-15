<div align="center">
  <img src="assets/logos/charbon.png" alt="Logo SARIBAO" width="180">

  # SARIBAO

  **Application mobile de gestion de vente de charbon**
</div>

SARIBAO aide les commerçants à suivre leur stock de charbon, leurs ventes,
leurs clients et les paiements, depuis leur téléphone Android.

## Fonctionnalités

- Tableau de bord avec stock, ventes et chiffre d'affaires.
- Enregistrement des arrivages et suivi des mouvements de stock.
- Gestion des ventes, des clients et des paiements, y compris les ventes à
  crédit.
- Rapports d'activité.
- Thème clair, sombre ou automatique.
- Interface en français et fonctionnement hors ligne : les données sont
  conservées localement sur l'appareil.
- Icône et écrans de démarrage personnalisés SARIBAO.

## Technologies

- Flutter et Dart
- SQLite avec `sqflite`
- Provider pour la gestion d'état

## Prérequis

- Flutter stable et Dart (versions définies dans `pubspec.yaml`).
- Android Studio ou le SDK Android pour compiler l'application Android.

## Installation et lancement

À la racine du projet :

```bash
flutter pub get
flutter run
```

## Tests et analyse

```bash
flutter analyze
flutter test
```

## Compiler l'APK Android

```bash
flutter build apk --release
```

L'APK généré se trouve ici :

```text
build/app/outputs/flutter-apk/app-release.apk
```
