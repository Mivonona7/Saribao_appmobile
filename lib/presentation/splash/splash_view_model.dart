import 'package:flutter/foundation.dart';

import '../../../app/bootstrap.dart';

/// États possibles du splash pendant l'initialisation.
enum SplashStatus {
  /// Initialisation en cours : le splash reste affiché.
  initializing,

  /// Initialisation terminée : la vue navigue vers le dashboard.
  ready,

  /// Initialisation en échec : la vue affiche l'erreur avec reprise possible.
  failed,
}

/// ViewModel du splash : exécute l'initialisation puis signale la navigation.
class SplashViewModel extends ChangeNotifier {
  SplashStatus _status = SplashStatus.initializing;
  String? _errorMessage;
  bool _isRunning = false;

  /// État courant du splash.
  SplashStatus get status => _status;

  /// Message d'erreur si l'initialisation a échoué.
  String? get errorMessage => _errorMessage;

  /// `true` tant que le splash doit rester affiché.
  bool get isInitializing => _status == SplashStatus.initializing;

  /// Lance l'initialisation.
  ///
  /// Ignorée si elle est déjà terminée ou si elle est en cours. Après un échec,
  /// l'appel relance l'initialisation.
  Future<void> initialize() async {
    if (_isRunning || _status == SplashStatus.ready) return;

    _isRunning = true;
    _status = SplashStatus.initializing;
    _errorMessage = null;
    notifyListeners();

    try {
      await AppBootstrap.initialize();
      _status = SplashStatus.ready;
    } catch (error) {
      _errorMessage =
          'Impossible de démarrer l\'application. Veuillez réessayer.';
      _status = SplashStatus.failed;
    } finally {
      _isRunning = false;
    }

    notifyListeners();
  }
}