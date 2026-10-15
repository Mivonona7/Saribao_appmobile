import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';

/// État d'un écran qui dépend de données.
///
/// Permet aux vues de traiter explicitement les quatre situations : chargement,
/// succès, liste vide et erreur.
enum ViewStatus { loading, success, empty, error }

/// Base commune des ViewModels.
///
/// Centralise la gestion d'état (`ViewStatus`) et la conversion des
/// exceptions en messages compréhensibles, pour qu'aucun écran ne duplique
/// cette logique.
abstract class BaseViewModel extends ChangeNotifier {
  ViewStatus _status = ViewStatus.loading;
  String? _errorMessage;

  /// État courant de l'écran.
  ViewStatus get status => _status;

  /// Message d'erreur à afficher, en langage courant.
  String? get errorMessage => _errorMessage;

  /// `true` pendant le chargement initial.
  bool get isLoading => _status == ViewStatus.loading;

  /// Passe l'écran en état de chargement.
  @protected
  void setLoading() {
    _status = ViewStatus.loading;
    _errorMessage = null;
    safeNotify();
  }

  /// Passe l'écran en état de succès.
  @protected
  void setSuccess() {
    _status = ViewStatus.success;
    _errorMessage = null;
    safeNotify();
  }

  /// Passe l'écran en état vide.
  @protected
  void setEmpty() {
    _status = ViewStatus.empty;
    _errorMessage = null;
    safeNotify();
  }

  /// Passe l'écran en état d'erreur avec un message utilisateur.
  @protected
  void setError(String message) {
    _status = ViewStatus.error;
    _errorMessage = message;
    safeNotify();
  }

  /// Traduit une exception en message affichable.
  ///
  /// Les erreurs métier portent déjà un message rédigé pour l'utilisateur ;
  /// les autres remontent un texte générique plutôt qu'une trace technique.
  @protected
  String describeError(Object error) {
    if (error is AppException) return error.message;
    return 'Une erreur inattendue est survenue. Veuillez réessayer.';
  }

  /// Exécute [action] en gérant chargement, succès et erreur.
  @protected
  Future<void> guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      setError(describeError(error));
    }
  }

  /// Notifie les vues si le ViewModel est encore attaché.
  @protected
  void safeNotify() {
    if (!hasListeners) return;
    notifyListeners();
  }
}