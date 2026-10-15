import '../data/database/app_database.dart';

/// Initialisation de l'application avant l'affichage du dashboard.
///
/// Point d'extension unique : la Phase 2 ajoutera ici l'ouverture de la base
/// SQLite et la lecture des paramètres. Aucune attente de durée fixe n'est
/// appliquée — le splash reste affiché le temps strictement nécessaire.
///
/// Rien ici ne doit dépendre d'un canal plateforme susceptible de ne jamais
/// répondre : le splash doit toujours atteindre l'état `ready`.
abstract final class AppBootstrap {
  static bool _isInitialized = false;

  /// Lance l'initialisation. Ne doit jamais bloquer plus de quelques
  /// centaines de millisecondes hors accès disque.
  ///
  /// L'ouverture de la base est idempotente : un appel après le premier ne
  /// recommence rien.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Ouvre (et crée au besoin) le schéma SQLite local.
      await AppDatabase.instance.database;
      _isInitialized = true;
    } catch (error) {
      // La base reste inutilisable : on remonte l'erreur pour que le splash
      // affiche un message clair plutôt qu'un écran vide.
      rethrow;
    }
  }

  /// Oublie l'initialisation effectuée. Réservé aux tests, qui doivent
  /// pouvoir relancer le splash sur une base neuve.
  static void resetForTest() {
    _isInitialized = false;
  }
}