class CategoriModel {
  final int id;
  final String name;
  final bool isActive;

  CategoriModel({
    required this.id,
    required this.name,
    required this.isActive
  });
  factory CategoriModel.fromJson(Map<String, dynamic> json) {
    return CategoriModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active']?.toString().toLowerCase() == 'true')
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }
}