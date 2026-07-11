import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/categorie/providers/categorie_providers.dart';
import 'package:shop_good/features/dashboard/views/widgets/expandablesection.dart';
import 'package:shop_good/features/menu/views/providers/menu_providers.dart';
import 'package:shop_good/features/menu/views/widgets/menu_items.dart';

class MenuList extends ConsumerWidget {
  const MenuList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(realtimeMenuProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return menuAsync.when(
      data: (menus) {
        // Filtrer les menus en fonction de la catégorie sélectionnée
        final filteredMenus = selectedCategory == 'Tout'
            ? menus
            : menus.where((menu) => menu.category == selectedCategory).toList();

        if (filteredMenus.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Aucun menu disponible pour cette catégorie',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ExpandableSection(
          title: selectedCategory == 'Tout' ? "Tout" : selectedCategory,
          itemCount: filteredMenus.length,
          crossAxisCount: 2,
          itemBuilder: (context, index) {
            final menu = filteredMenus[index];
            return MenuItemCard(menu: menu);
          },
        );
      },
      error: (err, stack) => Center(
        child: Text('Erreur lors de l\'initialisation des menus: $err'),
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
