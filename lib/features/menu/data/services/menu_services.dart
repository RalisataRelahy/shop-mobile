// menu_services.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_models.dart';

class MenuServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Récupère la liste complète des plats avec le nom de leur catégorie
  Future<List<MenuModels>> getAllMenu() async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, categories(name)');

      return (response as List).map((json) => MenuModels.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur de lecture : $e');
    }
  }

  // S'abonne aux modifications en temps réel sur la table 'products'
  RealtimeChannel listenToMenuChanges(void Function() onDataChanged) {
    final channel = _supabase.channel('public:products');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all, // Écoute INSERT, UPDATE, DELETE
      schema: 'public',
      table: 'products',
      callback: (payload) {
        // Déclenche la fonction de rappel pour forcer la mise à jour
        onDataChanged();
      },
    ).subscribe();

    return channel; // Retourne le canal pour pouvoir s'en désabonner plus tard
  }
}
