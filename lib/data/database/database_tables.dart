/// Noms des tables et colonnes SQLite.
///
/// Regroupés ici pour que le schéma soit lisible d'un seul endroit. Aucune
/// chaîne SQL n'est écrite ailleurs que dans les data sources.
abstract final class DbTables {
  /// Clients.
  static const String clients = 'clients';

  /// Ventes de sacs de charbon.
  static const String sales = 'sales';

  /// Lignes de vente (prévu pour evolution, 1 ligne = 1 sac).
  static const String saleItems = 'sale_items';

  /// Arrivages de charbon.
  static const String arrivals = 'arrivals';

  /// Paiements reçus des clients.
  static const String payments = 'payments';

  /// Mouvements de stock (toujours liés à une vente ou un arrivage).
  static const String stockMovements = 'stock_movements';

  /// Paramètres clé/valeur de l'application.
  static const String settings = 'settings';
}

/// Noms des colonnes, par table.
abstract final class DbColumns {
  // Communes à toutes les tables
  static const String id = 'id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // clients
  static const String name = 'name';
  static const String phone = 'phone';
  static const String address = 'address';

  // sales
  static const String clientId = 'client_id';
  static const String quantity = 'quantity';
  static const String unitPrice = 'unit_price';
  static const String totalAmount = 'total_amount';
  static const String paidAmount = 'paid_amount';
  static const String creditAmount = 'credit_amount';
  static const String paymentStatus = 'payment_status';
  static const String saleId = 'sale_id';
  static const String amount = 'amount';
  static const String note = 'note';

  // arrivals
  static const String purchasePricePerBag = 'purchase_price_per_bag';
  static const String totalPurchaseAmount = 'total_purchase_amount';
  static const String supplier = 'supplier';

  // stock_movements
  static const String movementType = 'movement_type';
  static const String referenceType = 'reference_type';
  static const String referenceId = 'reference_id';
  static const String label = 'label';
  static const String stockAfter = 'stock_after';

  // settings
  static const String key = 'key';
  static const String value = 'value';
}

/// Statuts possibles d'une vente.
abstract final class PaymentStatus {
  /// Vente intégralement payée à la vente.
  static const String paid = 'PAID';

  /// Vente partiellement payée : le reste est dû.
  static const String partial = 'PARTIAL';

  /// Vente entièrement à crédit.
  static const String credit = 'CREDIT';

  /// Libellé lisible d'un statut.
  static String label(String status) {
    switch (status) {
      case paid:
        return 'Payé';
      case partial:
        return 'Partiel';
      case credit:
        return 'Crédit';
      default:
        return status;
    }
  }
}

/// Types de mouvement de stock.
abstract final class MovementType {
  /// Ajout de sacs (arrivage).
  static const String arrival = 'ARRIVAL';

  /// Retrait de sacs (vente).
  static const String sale = 'SALE';

  /// Correction manuelle (autorisée explicitement).
  static const String correction = 'CORRECTION';
}