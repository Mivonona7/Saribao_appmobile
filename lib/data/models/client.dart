/// Client de l'application.
///
/// Le téléphone et l'adresse sont optionnels.
class Client {
  const Client({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  /// Identifiant local, `null` avant insertion.
  final int? id;

  /// Nom du client (obligatoire).
  final String name;

  /// Numéro de téléphone (facultatif).
  final String? phone;

  /// Adresse (facultative).
  final String? address;

  /// Date de création.
  final DateTime? createdAt;

  /// Date de dernière modification.
  final DateTime? updatedAt;

  /// Copie avec les champs fournis modifiés.
  Client copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Client(id: $id, name: $name)';
}