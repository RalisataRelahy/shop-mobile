class AuthModels {
  final String id;
  final String pseudo;
  final String phone;
  final String? role;
  final DateTime createdAt;

  AuthModels({
    required this.id,
    required this.pseudo,
    required this.phone,
    this.role = 'client',
    required this.createdAt,
  });

  factory AuthModels.fromJson(Map<String, dynamic> json) {
    return AuthModels(
      id: json['id']?.toString() ?? '',
      pseudo: json['pseudo']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'client',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'].toString())
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pseudo': pseudo,
      'phone': phone,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
