import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_good/features/cart/providers/cart_provider.dart';
import 'package:shop_good/app/theme/app_colors.dart';


class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Mon Panier',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (cartItems.isNotEmpty)
                      Text(
                        'Nombre d\'articles ${cartItems.length}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                  ],
                ),

                if (cartItems.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.errorRed),
                    label: const Text('Vider', style: TextStyle(color: AppColors.errorRed)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: cartItems.isEmpty
                ? const Center(
              child: Text('Votre panier est vide', style: TextStyle(fontSize: 16, color: AppColors.mediumGrey)),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cartItem.item.cartImageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 30),
                    ),
                  ),
                  title: Text(cartItem.item.cartName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${cartItem.item.cartPrice} Ar x ${cartItem.quantity}= ${cartItem.item.cartPrice * cartItem.quantity} Ar'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryGreen),
                        onPressed: () => ref.read(cartProvider.notifier).decreaseItem(cartItem.item),
                      ),
                      Text('${cartItem.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
                        onPressed: () => ref.read(cartProvider.notifier).addItem(cartItem.item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundOffWhite,
                border: Border(top: BorderSide(color: AppColors.lightGrey)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('$totalPrice Ar', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Fermer le panier
                          context.push('/checkout');
                        },
                        child: const Text('Passer la commande', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
