// cart_product.dart
abstract class CartProduct {
  String get cartId;       // ID unique pour le panier (incluant le variant si nécessaire)
  String get cartName;     // Nom à afficher (incluant le variant)
  String get cartImageUrl; // URL de l'image
  int get cartPrice;       // Prix du produit
}
