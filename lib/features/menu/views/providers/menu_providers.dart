// menu_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/menu_models.dart';
import '../../data/services/menu_services.dart';


// Injection du service
final menuServiceProvider = Provider<MenuServices>((ref) => MenuServices());

// Le Provider principal que l'UI va écouter pour avoir le menu en temps réel
final realtimeMenuProvider = AsyncNotifierProvider<RealtimeMenuNotifier, List<MenuModels>>(() {
  return RealtimeMenuNotifier();
});

class RealtimeMenuNotifier extends AsyncNotifier<List<MenuModels>> {
  late final MenuServices _service;
  RealtimeChannel? _realtimeChannel;

  @override
  FutureOr<List<MenuModels>> build() async {
    _service = ref.watch(menuServiceProvider);

    // Initialisation : On s'abonne au canal temps réel de Supabase
    _realtimeChannel = _service.listenToMenuChanges(() async {
      // Si la BDD change, on récupère silencieusement les nouvelles données avec la jointure
      final updatedData = await _service.getAllMenu();
      state = AsyncValue.data(updatedData); // Met à jour l'UI instantanément
    });

    // Nettoyage automatique : Quand le provider est détruit, on ferme le canal
    ref.onDispose(() {
      if (_realtimeChannel != null) {
        Supabase.instance.client.removeChannel(_realtimeChannel!);
      }
    });

    // Chargement initial des données au démarrage de l'application
    return _service.getAllMenu();
  }
}
