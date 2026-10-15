import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_migrations.dart';
import 'database_tables.dart';

/// Accès unique à la base SQLite locale.
///
/// Ouverte une seule fois au démarrage (voir `AppBootstrap`). Toutes les
/// opérations écrites passent par [transaction] pour rester atomiques.
class AppDatabase {
  AppDatabase._();

  /// Instance unique.
  static final AppDatabase instance = AppDatabase._();

  /// Version courante du schéma.
  static const int _schemaVersion = 1;

  /// Nom du fichier de base sur le disque.
  static const String _fileName = 'saribao.db';

  Database? _db;

  /// Permet aux tests de router la base vers une instance FFI en mémoire.
  /// `null` en production : la base est alors ouverte sur le disque.
  static DatabaseFactory? debugDatabaseFactory;

  /// Chemin de base forcé (tests). `null` en production.
  static String? debugDatabasePath;

  /// Base ouverte, ou ouverture paresseuse si nécessaire.
  Future<Database> get database async {
    final Database? existing = _db;
    if (existing != null && existing.isOpen) return existing;
    return _open();
  }

  /// Ouvre la base sur le chemin par défaut de l'application.
  Future<Database> _open() async {
    final DatabaseFactory factory = debugDatabaseFactory ?? databaseFactory;
    final String path = debugDatabasePath ??
        p.join(await getDatabasesPath(), _fileName);
    return _openAt(factory, path);
  }

  /// Ouvre la base à un chemin donné. Utilisé aussi par les tests.
  Future<Database> _openAt(DatabaseFactory factory, String path) async {
    final Database db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _schemaVersion,
        onConfigure: (Database db) async {
          // Les clés étrangères doivent être activées explicitement sur SQLite.
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (Database db, int version) async {
          await DatabaseMigrations.createV1(db);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          // Aucune migration en V1 : le schéma est créé directement en
          // onCreate. Les futures versions ajoutent ici leurs alterations.
        },
      ),
    );
    _db = db;
    return db;
  }

  /// Exécute [action] dans une transaction : commit si succès, rollback sinon.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final Database db = await database;
    return db.transaction<T>(action);
  }

  /// Ferme la base. Utilisé par les tests et lors de l'arrêt de l'application.
  Future<void> close() async {
    final Database? db = _db;
    _db = null;
    if (db != null && db.isOpen) await db.close();
  }

  /// Supprime toutes les données métier. Réservé aux tests et à la restauration
  /// d'une sauvegarde : à n'appeler qu'après confirmation utilisateur.
  Future<void> deleteAllData() async {
    await transaction((Transaction txn) async {
      for (final String table in <String>[
        DbTables.payments,
        DbTables.saleItems,
        DbTables.sales,
        DbTables.arrivals,
        DbTables.stockMovements,
        DbTables.clients,
        DbTables.settings,
      ]) {
        await txn.delete(table);
      }
    });
  }
}