import 'package:shop_good/shared/models/cart_items.dart';

class MenuModels implements CartProduct{
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final String? description;
  final String category; // Contiendra le nom textuel (ex: "Burgers")
  final bool isActive;

  MenuModels({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description = "",
    required this.category,
    required this.isActive,
  });

  factory MenuModels.fromJson(Map<String, dynamic> json) {
    // 1. On récupère l'objet de la table liée 'categories' renvoyé par Supabase
    final categoriesData = json['categories'] as Map<String, dynamic>?;

    return MenuModels(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Sans nom',
      // Conversion sécurisée en int au cas où Supabase renvoie un double ou num
      price: (json['price'] as num?)?.toInt() ?? 0,
      // Attention à la casse de votre colonne en BDD (souvent image_url en Supabase)
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      description: json['description'],

      // 2. On extrait le 'name' de l'objet lié. Si null, on met une valeur de secours.
      category: categoriesData?['name']?.toString() ?? 'Sans catégorie',

      // 3. CORRECTION DU CRASH : Si is_active est NULL en BDD, on force 'false' (ou true)
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      // Lors de l'envoi, vous envoyez généralement l'ID ou le nom selon votre BDD
      'is_active': isActive,
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
  String get cartName => name;

  @override
  // TODO: implement cartPrice
  int get cartPrice => price;
}
