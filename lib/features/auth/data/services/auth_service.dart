import 'package:shop_good/features/auth/data/models/auth_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password, {
    required String pseudo,
    required String phone,
  }) async {
    // 1. Inscription dans Supabase Auth
    final res = await supabase.auth.signUp(email: email, password: password);
    
    if (res.user == null) {
      throw Exception('Erreur lors de la création du compte');
    }

    // 2. Création du profil dans la table 'profiles'
    final profile = AuthModels(
      id: res.user!.id,
      pseudo: pseudo,
      phone: phone,
      createdAt: DateTime.now(),
    );

    await supabase.from('profiles').insert(profile.toJson());
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<AuthModels?> getProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return AuthModels.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }
}
