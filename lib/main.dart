import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';

/// Point d'entrée de SARIBAO.
///
/// L'application est 100% offline : aucune initialisation réseau ici.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Les formulaires sont conçus pour le portrait. Cet appel est effectué
  // avant `runApp` et hors du cycle du splash : une réponse lente du canal
  // plateforme ne doit jamais empêcher l'application de démarrer.
  unawaited(
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  );

  runApp(const SaribaoApp());
}