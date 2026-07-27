// menu_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/combo/data/models/combo_models.dart';
import 'package:shop_good/features/combo/data/services/combo_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



// Injection du service
final comboServiceProvider = Provider<ComboServices>((ref) => ComboServices());

// Le Provider principal que l'UI va écouter pour avoir le menu en temps réel
final realtimeComboProvider = AsyncNotifierProvider<RealtimeComboNotifier, List<ComboModels>>(() {
  return RealtimeComboNotifier();
});

class RealtimeComboNotifier extends AsyncNotifier<List<ComboModels>> {
  late ComboServices _service;
  RealtimeChannel? _realtimeChannel;

  @override
  FutureOr<List<ComboModels>> build() async {
    _service = ref.watch(comboServiceProvider);

    // On s'assure de ne pas avoir de canaux en doublon si build() est ré-exécuté
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
    }

    // Initialisation : On s'abonne au canal temps réel de Supabase
    _realtimeChannel = _service.listenToMenuChanges(() async {
      // Si la BDD change, on récupère les nouvelles données
      final updatedData = await _service.getAllCombo();
      state = AsyncValue.data(updatedData); // Met à jour l'UI instantanément
    });

    // Nettoyage automatique : Quand le provider est détruit définitivement
    ref.onDispose(() {
      if (_realtimeChannel != null) {
        Supabase.instance.client.removeChannel(_realtimeChannel!);
      }
    });

    // Chargement initial des données
    return _service.getAllCombo();
  }
}
