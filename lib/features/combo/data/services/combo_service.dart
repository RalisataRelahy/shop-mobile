// menu_services.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/combo_models.dart';

class ComboServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ComboModels>> getAllCombo() async {
    try {
      final response = await _supabase
          .from('combos')
          .select('*');

      return (response as List)
          .map((json) => ComboModels.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur de lecture : $e');
    }
  }

  // S'abonne aux modifications en temps réel sur la table 'products'
  RealtimeChannel listenToMenuChanges(void Function() onDataChanged) {
    final channel = _supabase.channel('public:combos');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all, // Écoute INSERT, UPDATE, DELETE
      schema: 'public',
      table: 'combos',
      callback: (payload) {
        // Déclenche la fonction de rappel pour forcer la mise à jour
        onDataChanged();
      },
    ).subscribe();

    return channel; // Retourne le canal pour pouvoir s'en désabonner plus tard
  }
}
