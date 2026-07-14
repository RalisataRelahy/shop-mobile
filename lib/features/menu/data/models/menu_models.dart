import 'package:shop_good/features/menu/data/models/menu_invariant_models.dart';
import 'package:shop_good/shared/models/cart_items.dart';

class MenuModels implements CartProduct{
  final String id;
  final String name;
  final String imageUrl;
  final String? description;
  final String category; // Contiendra le nom textuel (ex: "Burgers")
  final bool isActive;
  List<MenuInvariantModels> variants;

  MenuModels({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description = "",
    required this.category,
    required this.variants,
    required this.isActive,
  });

  factory MenuModels.fromJson(Map<String, dynamic> json) {
    // 1. On récupère l'objet de la table liée 'categories' renvoyé par Supabase
    final categoriesData = json['categories'] as Map<String, dynamic>?;

    return MenuModels(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Sans nom',
      // Conversion sécurisée en int au cas où Supabase renvoie un double ou num
      // Attention à la casse de votre colonne en BDD (souvent image_url en Supabase)
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      description: json['description'],

      // 2. On extrait le 'name' de l'objet lié. Si null, on met une valeur de secours.
      category: categoriesData?['name']?.toString() ?? 'Sans catégorie',
      variants: (json['product_variants'] as List?)
              ?.map((e) => MenuInvariantModels.fromJson(e))
              .toList() ??
          [],
      // 3. CORRECTION DU CRASH : Si is_active est NULL en BDD, on force 'false' (ou true)
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      // Lors de l'envoi, vous envoyez généralement l'ID ou le nom selon votre BDD
      'is_active': isActive,
    };
  }

  @override
  String get cartId => id;

  @override
  String get cartImageUrl => imageUrl;

  @override
  String get cartName => name;

  @override
  int get cartPrice => variants.isNotEmpty ? variants.first.price.toInt() : 0;
}

class MenuVariantCartItem implements CartProduct {
  final MenuModels menu;
  final MenuInvariantModels variant;

  MenuVariantCartItem({required this.menu, required this.variant});

  @override
  String get cartId => "${menu.id}_${variant.id}";

  @override
  String get cartImageUrl => menu.imageUrl;

  @override
  String get cartName => "${menu.name} (${variant.name})";

  @override
  int get cartPrice => variant.price.toInt();
}
