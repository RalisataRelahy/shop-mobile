// cart_product.dart
abstract class CartProduct {
  String get cartId;       // ID unique pour le panier
  String get cartName;     // Nom à afficher
  int get cartPrice;       // Prix unitaire
  String get cartImageUrl; // URL de l'image
}
