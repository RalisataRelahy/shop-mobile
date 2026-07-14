class MenuInvariantModels {
  final String id;
  final String name;
  final double price;

  MenuInvariantModels({
    required this.id,
    required this.name,
    required this.price,
  });

  factory MenuInvariantModels.fromJson(Map<String, dynamic> json) {
    return MenuInvariantModels(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Sans nom',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuInvariantModels &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
