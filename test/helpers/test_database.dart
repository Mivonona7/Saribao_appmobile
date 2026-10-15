import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:saribao/core/di/app_dependencies.dart';
import 'package:saribao/data/database/app_database.dart';

/// Prépare une base SQLite en mémoire et les repositories associés.
///
/// Chaque test repart d'une base vierge : aucun test ne dépend de l'ordre
/// d'exécution, et aucun n'écrit sur le disque.
class TestDatabase {
  TestDatabase._(this.dependencies);

  /// Repositories prêts à l'emploi pour le test.
  final AppDependencies dependencies;

  /// Route la base vers une instance FFI en mémoire et crée le schéma.
  static Future<TestDatabase> create() async {
    sqfliteFfiInit();

    // Referme une éventuelle base ouverte par un test précédent.
    await AppDatabase.instance.close();

    AppDatabase.debugDatabaseFactory = databaseFactoryFfi;
    AppDatabase.debugDatabasePath = inMemoryDatabasePath;

    // L'ouverture crée le schéma via onCreate.
    final AppDependencies dependencies = AppDependencies.create();
    await _touch(dependencies);

    return TestDatabase._(dependencies);
  }

  /// Force l'ouverture effective de la base en exécutant une lecture.
  static Future<void> _touch(AppDependencies dependencies) async {
    await dependencies.stockRepository.getCurrentStock();
  }

  /// Remet la base dans son état de production.
  static Future<void> tearDown() async {
    await AppDatabase.instance.close();
    AppDatabase.debugDatabaseFactory = null;
    AppDatabase.debugDatabasePath = null;
  }
}