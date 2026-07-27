import 'package:shop_good/shared/models/cart_items.dart';

class ComboModels implements CartProduct{
  final String id;
  final String name;
  final String? description;
  final int price;
  final String imageUrl;
  final bool isActive;

  ComboModels({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.imageUrl,
    required this.isActive,
  });

  factory ComboModels.fromJson(Map<String, dynamic> json) {
    return ComboModels(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active']?.toString().toLowerCase() == 'true' ||
              json['is_active'] == 1 ||
              json['is_active'] == '1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'isActive': isActive,
    };
  }

  @override
  // TODO: implement cartId
  String get cartId => id;

  @override
  // TODO: implement cartImageUrl
  String get cartImageUrl =>imageUrl;

  @override
  // TODO: implement cartName
  String get cartName =>name;

  @override
  // TODO: implement cartPrice
  int get cartPrice =>price;
}
