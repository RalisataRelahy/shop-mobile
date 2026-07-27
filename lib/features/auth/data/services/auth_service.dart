import 'package:flutter/foundation.dart';
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
  Future<void> loginWithGoogle() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.shopgood://login-callback/',
    );
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
  Future<void> deleteAccount() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }
    final response = await Supabase.instance.client.functions.invoke(
      'delete-account',
    );
    if (response.status == 200) {
      await Supabase.instance.client.auth.signOut();
      print("Compte supprimé");
    } else {
      print("Erreur suppression compte");
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String pseudo,
    required String phone,
  }) async {
    try {
      await supabase
          .from('profiles')
          .update({
            'pseudo': pseudo,
            'phone': phone,

          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

}
