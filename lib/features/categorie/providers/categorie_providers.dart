// combo_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shop_good/features/categorie/data/models/categori_model.dart';
import 'package:shop_good/features/categorie/data/services/categorie_services.dart';

// ==========================================
// 1. LES PROVIDERS (Portes d'accès pour l'UI)
// ==========================================

// Fournit l'instance du service Supabase à notre Notifier
final categorieServiceProvider = Provider<CategorieServices>((ref) => CategorieServices());

// Le point d'accès principal pour l'UI pour écouter la liste des combos
final categorieProvider = AsyncNotifierProvider<CategorieNotifier, List<CategoriModel>>(() {
  return CategorieNotifier();
});

// Provider pour la catégorie sélectionnée
final selectedCategoryProvider = StateProvider<String>((ref) => 'Tout');


// ==========================================
// 2. LE NOTIFIER (Gestionnaire de l'état)
// ==========================================

class CategorieNotifier extends AsyncNotifier<List<CategoriModel>> {
  @override
  FutureOr<List<CategoriModel>> build() async {
    final service = ref.watch(categorieServiceProvider);
    return service.getAllCategories();
  }
}
