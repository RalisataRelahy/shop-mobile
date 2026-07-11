// cart_item_model.dart

import '../../../../shared/models/cart_items.dart';

class CartItemModel {
  final CartProduct item; // Reçoit aussi bien un MenuModels qu'un ComboModel
  final int quantity;

  CartItemModel({
    required this.item,
    required this.quantity,
  });

  int get totalPrice => item.cartPrice * quantity;

  CartItemModel copyWith({CartProduct? item, int? quantity}) {
    return CartItemModel(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}
