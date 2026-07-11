import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/categorie/data/models/categori_model.dart';
import 'package:shop_good/features/categorie/providers/categorie_providers.dart';
import 'package:shop_good/app/theme/app_colors.dart';

class CategoriesList extends ConsumerWidget {
  const CategoriesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comboAsync = ref.watch(categorieProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return comboAsync.when(
      data: (categories) {
        final List<CategoriModel> activeCategories = [
          CategoriModel(id: 0, name: 'Tout', isActive: true),
          ...categories.where((c) => c.isActive),
        ];

        return SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: activeCategories.length,
            itemBuilder: (context, index) {
              final category = activeCategories[index];
              final isSelected = selectedCategory == category.name;

              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = category.name;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGreen : AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected ? AppColors.surfaceWhite : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      error: (err, stack) => Center(child: Text('erreur: $err')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
