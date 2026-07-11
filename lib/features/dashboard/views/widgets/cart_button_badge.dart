import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/cart/providers/cart_provider.dart';
import 'package:shop_good/features/cart/views/cart_screen.dart';

class CartButtonWithBadge extends ConsumerWidget {
  const CartButtonWithBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Écoute dynamique du nombre total d'articles dans le panier
    final totalItems = ref.watch(cartTotalItemsProvider);

    return Badge.count(
      count: totalItems,
      // 2. Configuration visuelle de la pastille
      backgroundColor: const Color(0xFFFF0000),
      // 3. Masquer automatiquement la pastille si le panier est vide (0 article)
      isLabelVisible: totalItems > 0,

      // Positionnement du badge par rapport à l'icône
      alignment: const Alignment(0.7, -0.6),

      // 4. L'élément principal (l'icône sur laquelle le badge va se superposer)
      child: IconButton(
        icon: const Icon(Icons.shopping_cart_outlined, size: 28),
        onPressed: () {
          // Ouvre votre pop-up de panier au clic
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const CartBottomSheet(),
          );
        },
      ),
    );
  }
}
