import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Textes français de l'interface.
///
/// SARIBAO est 100% hors ligne : aucune génération de code ni aucun paquet de
/// localisation n'est nécessaire. Les chaînes vivent dans un dictionnaire
/// statique et [AppStrings.of] conserve le français pour toute locale inconnue.
@immutable
class AppStrings {
  /// Textes français, langue de référence.
  static const AppStrings french = AppStrings._('fr');

  /// `LocalizationsDelegate` à déclarer dans `MaterialApp`.
  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  /// Seule locale prise en charge.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
  ];

  /// Code de langue de ce jeu de textes.
  final String languageCode;

  const AppStrings._(this.languageCode);

  /// Jeu de textes correspondant à [locale], avec repli sur le français.
  static AppStrings of(Locale locale) {
    return french;
  }

  /// Jeu de textes du contexte, avec repli sur le français.
  ///
  /// Le repli évite une exception dans un `Widget` testé hors `MaterialApp` :
  /// un texte doit toujours exister.
  static AppStrings ofContext(BuildContext context) {
    final AppStrings? strings = Localizations.of<AppStrings>(
      context,
      AppStrings,
    );
    return strings ?? french;
  }

  /// Texte associé à [key], dans la langue courante.
  ///
  /// Une clé absente renvoie la clé elle-même : le défaut visible dans
  /// l'interface est alors « navigation.stock » plutôt qu'une chaîne vide,
  /// ce qui rend le problème immédiatement identifiable.
  String t(String key) => _values[key] ?? _fr[key] ?? key;

  /// Devise affichée après les montants.
  String get currencySuffix => t('common.currency');

  /// Champ [key] avec [value] interpolé.
  ///
  /// ```dart
  /// s.withArgs('common.sacsCount', {'count': '82'}); // '82 sacs'
  /// ```
  String withArgs(String key, Map<String, String> args) {
    String result = t(key);
    for (final MapEntry<String, String> entry in args.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  /// Dictionnaire de la langue courante.
  Map<String, String> get _values => _fr;

  /// Texte associé à [key] dans la langue active, sans `BuildContext`.
  static String lookup(String key) => french.t(key);

  /// Variante de [lookup] avec interpolation, pour les ViewModels.
  static String lookupWithArgs(String key, Map<String, String> args) =>
      french.withArgs(key, args);

  /// Textes français, langue de référence.
  static const Map<String, String> _fr = <String, String>{
    // Génériques
    'common.appName': 'SARIBAO',
    'common.tagline': 'Gestion de vente de charbon',
    'common.cancel': 'Annuler',
    'common.confirm': 'Confirmer',
    'common.delete': 'Supprimer',
    'common.edit': 'Modifier',
    'common.save': 'Enregistrer',
    'common.close': 'Fermer',
    'common.retry': 'Réessayer',
    'common.loading': 'Chargement...',
    'common.loadingData': 'Chargement de vos données...',
    'common.optional': 'Facultatif',
    'common.required': 'Obligatoire',
    'common.sacs': 'sacs',
    'common.sac': 'sac',
    'common.currency': 'Ar',
    'common.sacsCount': '{count} sacs',
    'common.none': 'Aucun',
    'common.search': 'Rechercher',
    'common.total': 'Total',
    'common.subtotal': 'Sous-total',
    'common.quantity': 'Quantité',
    'common.unitPrice': 'Prix unitaire',
    'common.date': 'Date',
    'common.all': 'Tous',
    'common.actions': 'Actions',
    'common.back': 'Retour',

    // Navigation
    'nav.home': 'Accueil',
    'nav.stock': 'Stock',
    'nav.sales': 'Ventes',
    'nav.clients': 'Clients',
    'nav.reports': 'Rapports',
    'nav.arrivals': 'Arrivages',
    'nav.settings': 'Paramètres',
    'nav.about': 'À propos',
    'nav.dashboard': 'Tableau de bord',

    // Accueil
    'home.greeting': 'Bonjour',
    'home.stockAvailable': 'STOCK DISPONIBLE',
    'home.salesToday': 'Ventes du jour',
    'home.revenueToday': "Chiffre d'affaires du jour",
    'home.creditsToCollect': 'CRÉDITS À RÉCUPÉRER',
    'home.newSale': 'Nouvelle vente',
    'home.newArrival': 'Nouvel arrivage',
    'home.recentSales': 'Dernières ventes',
    'home.recentSalesSubtitle': 'Vos ventes les plus récentes',
    'home.noSales': 'Aucune vente',
    'home.noSalesMessage':
        'Enregistrez votre premier arrivage puis votre première vente pour '
        'voir votre activité ici.',
    'home.loadError': 'Impossible de charger le tableau de bord.',

    // Stock
    'stock.current': 'Stock actuel',
    'stock.movements': 'Mouvements de stock',
    'stock.noMovements': 'Aucun mouvement',
    'stock.noMovementsMessage':
        'Les entrées et les sorties de charbon apparaîtront ici.',
    'stock.arrival': 'Arrivage',
    'stock.sale': 'Vente',
    'stock.correction': 'Correction',
    'stock.normal': 'Stock normal',
    'stock.low': 'Stock bas',
    'stock.outOfStock': 'Rupture de stock',
    'stock.remaining': 'Restant',

    // Arrivage
    'arrival.new': 'Nouvel arrivage',
    'arrival.quantity': 'Nombre de sacs',
    'arrival.purchasePrice': "Prix d'achat par sac",
    'arrival.supplier': 'Fournisseur',
    'arrival.supplierHint': 'Ex : Vendor Mahaleo',
    'arrival.totalToPay': 'Total à payer',
    'arrival.stockAfter': 'Stock après',

    // Vente
    'sale.new': 'Nouvelle vente',
    'sale.quantity': 'Nombre de sacs',
    'sale.unitPrice': 'Prix de vente par sac',
    'sale.client': 'Client',
    'sale.searchClient': 'Rechercher un client',
    'sale.searchHint': 'Tapez un nom',
    'sale.counterClient': 'Client comptoir',
    'sale.paymentMode': 'Mode de paiement',
    'sale.paid': 'Payé',
    'sale.partial': 'Partiel',
    'sale.credit': 'Crédit',
    'sale.amountPaid': 'Montant payé',
    'sale.remaining': 'Reste à payer',
    'sale.note': 'Note',
    'sale.noteHint': 'Facultatif',
    'sale.total': 'Total de la vente',
    'sale.stockAfter': 'Stock après la vente',
    'sale.detail': 'Détail de la vente',
    'sale.paymentStatus': 'Statut du paiement',
    'sale.payments': 'Paiements',
    'sale.addPayment': 'Enregistrer un paiement',
    'sale.noSales': 'Aucune vente',
    'sale.noSalesMessage':
        'Vos ventes enregistrées apparaîtront ici, de la plus récente à la '
        'plus ancienne.',
    'sale.counterSale': 'Vente comptoir',
    'sale.itemsCount': '{count} article(s)',
    'sale.stockInsufficient': 'Stock insuffisant',
    'sale.history': 'Historique des ventes',

    // Clients
    'client.new': 'Nouveau client',
    'client.name': 'Nom complet',
    'client.nameHint': 'Ex : Aminata Traoré',
    'client.phone': 'Téléphone',
    'client.phoneHint': 'Ex : 034 12 345 67',
    'client.address': 'Adresse',
    'client.addressHint': 'Quartier, ville',
    'client.searchHint': 'Rechercher un client',
    'client.detail': 'Fiche client',
    'client.totalPurchases': 'Total des achats',
    'client.totalPaid': 'Total réglé',
    'client.credit': 'Crédit restant',
    'client.sales': 'Ventes',
    'client.payments': 'Paiements',
    'client.noSales': 'Aucune vente',
    'client.noPayments': 'Aucun paiement',
    'client.addPayment': 'Ajouter un paiement',
    'client.paymentAmount': 'Montant du paiement',
    'client.noClients': 'Aucun client',
    'client.noClientsMessage':
        'Créez vos clients pour suivre leurs ventes et leurs crédits.',
    'client.list': 'Liste des clients',
    'client.nameRequired': 'Le nom du client est obligatoire.',
    'client.deleteConfirmTitle': 'Supprimer ce client ?',
    'client.deleteConfirmMessage':
        'Cette action est définitive. Les ventes déjà enregistrées ne sont pas '
        'supprimées, mais le client ne pourra plus être utilisé.',
    'client.deleteBlocked': 'Impossible de supprimer un client qui a des ventes.',

    // Rapports
    'reports.title': 'Rapports',
    'reports.period': 'Période',
    'reports.periodSubtitle': 'Choisissez la période à analyser',
    'reports.today': "Aujourd'hui",
    'reports.week': 'Cette semaine',
    'reports.month': 'Ce mois',
    'reports.all': 'Tout',
    'reports.revenue': 'Chiffre d\'affaires',
    'reports.purchases': 'Achats',
    'reports.margin': 'Marge',
    'reports.outstanding': 'Crédits en cours',
    'reports.unitsSold': 'Sacs vendus',
    'reports.topClients': 'Meilleurs clients',
    'reports.noData': 'Aucune donnée sur cette période.',

    // Réglages
    'settings.title': 'Paramètres',
    'settings.appearance': 'Apparence',
    'settings.appearanceSubtitle': 'Thème clair, sombre ou automatique',
    'settings.themeLight': 'Clair',
    'settings.themeDark': 'Sombre',
    'settings.themeSystem': 'Automatique',
    'settings.about': 'À propos',
    'settings.aboutSubtitle': 'Version et développeur',
    'settings.offline': 'Application 100% hors ligne',
    'settings.offlineMessage':
        'Toutes vos données sont enregistrées uniquement sur cet appareil. '
        'Aucune connexion Internet n\'est utilisée.',

    // À propos
    'about.title': 'À propos',
    'about.appName': 'SARIBAO',
    'about.tagline': 'Gestion de vente de charbon',
    'about.version': 'Version',
    'about.developer': 'Développé par',
    'about.developerName': 'Andry RAMANANTSOA',
    'about.developerRole': 'Développeur de l\'application',
    'about.photoAlt': 'Portrait du développeur',
    'about.platform': 'Plateforme',
    'about.builtWith': 'Réalisé avec Flutter et SQLite, sans connexion Internet.',
    'about.rights': 'Tous droits réservés.',
    'about.licence': 'Application privée, usage commercial.',

    // Erreurs
    'error.generic': 'Une erreur est survenue.',
    'error.networkImpossible': 'Aucune connexion n\'est nécessaire : l\'application fonctionne hors ligne.',
    'error.insufficientStock': 'Stock insuffisant pour cette quantité.',
    'error.invalidQuantity': 'Le nombre de sacs doit être supérieur à 0.',
    'error.invalidPrice': 'Le prix doit être supérieur à 0.',
    'error.invalidAmount': 'Le montant payé ne peut pas dépasser le total.',
    'error.needClient': 'Choisissez un client pour enregistrer un paiement.',

    // Libellés restés en dur dans les formulaires et les écrans de détail
    'common.loadingProfile': 'Chargement du profil...',
    'common.checkFields': 'Vérifiez les champs en rouge.',
    'common.noneYet': 'Rien à afficher pour le moment.',
    'home.todaysSalesCard': 'Ventes du jour',
    'home.todaysRevenueCard': 'CA du jour',
    'arrival.quantityTitle': 'Combien de sacs sont arrivés ?',
    'arrival.quantitySubtitle': 'Ces sacs seront ajoutés à votre stock.',
    'arrival.quantityLabel': 'Nombre exact de sacs',
    'arrival.supplierOptional': 'Fournisseur (facultatif)',
    'arrival.save': "Enregistrer l'arrivage",
    'arrival.none': 'Aucun arrivage',
    'arrival.loadError': 'Impossible de charger les arrivages.',
    'stock.loadError': 'Impossible de charger le stock.',
    'stock.unitsInStock': '{count} sacs en stock',
    'sale.confirmTitle': 'Confirmer la vente ?',
    'sale.finish': 'Terminer',
    'sale.paidNow': 'Montant payé maintenant',
    'sale.totalLabel': 'Total',
    'sale.validate': 'Valider la vente',
    'sale.changeClient': 'Changer de client',
    'sale.paymentsList': 'Règlements de cette vente',
    'sale.noPaymentsMessage':
        "Aucun paiement n'a encore été enregistré.",
    'sale.loadError': 'Impossible de charger la vente.',
    'sale.paymentFor': 'Paiement {label}',
    'client.salesHistory': 'Historique des ventes',
    'client.paymentsHistory': 'Historique des paiements',
    'client.noSalesMessage':
        "Ce client n'a pas encore acheté de charbon.",
    'client.noPaymentsMessage':
        "Aucun règlement n'a encore été enregistré.",
    'client.add': 'Ajouter un client',
    'client.phoneOptional': 'Téléphone (facultatif)',
    'client.addressOptional': 'Adresse (facultatif)',
    'client.paymentMaximum': 'Maximum : {max}',
    'client.paymentInvalidAmount': 'Saisissez un montant supérieur à 0.',
    'client.loadError': 'Impossible de charger ce client.',
    'client.loadErrorList': 'Impossible de charger les clients.',
    'splash.logoLabel': 'Logo SARIBAO',
    'splash.loadError': "Impossible de démarrer l'application.",
    'reports.loadError': 'Impossible de calculer les rapports.',
    'sales.loadError': 'Impossible de charger les ventes.',
  };

}

/// Résout [AppStrings] et rien d'autre : `MaterialApp` garde ses propres
/// délégués par défaut, seul notre dictionnaire est ajouté.
class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppStrings.supportedLocales.any(
        (Locale supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture<AppStrings>(AppStrings.of(locale));
  }

  @override
  bool shouldReload(covariant _AppStringsDelegate old) => false;
}

/// Accès court aux textes du contexte courant.
extension AppStringsContext on BuildContext {
  /// Textes de l'interface dans la langue active.
  AppStrings get strings => AppStrings.ofContext(this);

  /// Texte associé à [key] dans la langue active.
  String t(String key) => strings.t(key);
}
