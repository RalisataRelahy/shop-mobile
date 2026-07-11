// cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/cart/data/models/cart_item_model.dart';
import 'package:shop_good/shared/models/cart_items.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItemModel>>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() => [];

  // --- AJOUTER UN PRODUIT OU UN COMBO ---
  void addItem(CartProduct product) {
    final index = state.indexWhere((element) => element.item.cartId == product.cartId);

    if (index >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) state[i].copyWith(quantity: state[i].quantity + 1) else state[i]
      ];
    } else {
      state = [...state, CartItemModel(item: product, quantity: 1)];
    }
  }

  // --- DIMINUER LA QUANTITÉ ---
  void decreaseItem(CartProduct product) {
    final index = state.indexWhere((element) => element.item.cartId == product.cartId);

    if (index >= 0) {
      if (state[index].quantity > 1) {
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == index) state[i].copyWith(quantity: state[i].quantity - 1) else state[i]
        ];
      } else {
        removeItem(product.cartId);
      }
    }
  }

  void removeItem(String id) {
    state = state.where((element) => element.item.cartId != id).toList();
  }

  void clearCart() => state = [];
}

final cartTotalItemsProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (total, item) => total + item.quantity);
});

// Getters globaux réutilisables inchangés
final cartTotalPriceProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (total, item) => total + item.totalPrice);
});
