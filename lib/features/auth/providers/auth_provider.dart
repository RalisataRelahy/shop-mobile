import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shop_good/features/auth/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/auth_models.dart';

// Provider pour le service d'authentification
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Provider pour le mode invité
final isGuestModeProvider = StateProvider<bool>((ref) => false);

// Écoute les changements d'état d'authentification
final authStateProvider = StreamProvider<AuthState>((ref) {
  final stream = Supabase.instance.client.auth.onAuthStateChange;
  // Si l'utilisateur se connecte, on désactive le mode invité
  stream.listen((event) {
    if (event.session != null) {
      ref.read(isGuestModeProvider.notifier).state = false;
    }
  });
  return stream;
});

// Récupère l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

final userProfileProvider = FutureProvider<AuthModels?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(authServiceProvider).getProfile(user.id);
});

// Contrôleur pour gérer les actions d'authentification (login, signup) et leur état (chargement, erreur)
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  late final AuthService _authService;

  @override
  Future<void> build() async {
    _authService = ref.watch(authServiceProvider);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.login(email, password));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String pseudo,
    required String phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.signUp(
          email,
          password,
          pseudo: pseudo,
          phone: phone,
        ));
    state=await AsyncValue.guard(() => _authService.login(email, password));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.signOut());
  }

  Future<void> deleteMyAccount() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.deleteAccount());
  }
  Future<void> updateProfile({
    required String pseudo,
    required String phone,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authService.updateProfile(
        userId: user.id,
        pseudo: pseudo,
        phone: phone,
      );
      // Rafraîchir les données du profil
      ref.invalidate(userProfileProvider);
    });
  }
}
