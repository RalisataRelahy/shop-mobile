import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/onBoardinPage/views/providers/on_boarding_page_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shop_good/features/auth/providers/auth_provider.dart';

// Ajustez ces 3 imports selon l'emplacement réel de vos providers.
import 'package:shop_good/features/orders/providers/order_provider.dart';
import '../../features/categorie/providers/categorie_providers.dart';
import '../../features/menu/views/providers/menu_providers.dart';

/// ---------------------------------------------------------------------------
/// À placer dans lib/shared/providers/app_init_provider.dart
/// ---------------------------------------------------------------------------
///
/// Ce provider représente l'état d'initialisation global de l'application.
/// Tant qu'il est en `isLoading`, le router garde l'utilisateur sur /splashscreen.
///
/// Il garantit deux choses en parallèle (Future.wait) :
///  1. Un affichage MINIMUM de 2 secondes du splash (évite le flash trop rapide)
///  2. Que le vrai travail d'initialisation soit terminé (auth, commandes,
///     menu, catégories...)
///
/// Si l'init réelle prend plus de 2s, le splash reste affiché jusqu'à ce
/// qu'elle se termine (le splash continue simplement de tourner).
final appInitProvider = FutureProvider<void>((ref) async {
  debugPrint('>>> appInitProvider: START');
  
  // Délai minimum de 2s pour que l'animation du splash soit visible
  final minDisplay = Future.delayed(const Duration(seconds: 2));

  // Exécution des tâches d'initialisation avec un timeout de sécurité
  final initTasks = _runInitTasks(ref).timeout(
    const Duration(seconds: 10),
    onTimeout: () => debugPrint('>>> appInitProvider: TIMEOUT REACHED'),
  );

  // Chargement de l'onboarding
  try {
    final hasSeenOnBoarding = await OnboardingController.loadOnboardingSeen();
    ref.read(hasSeenOnboardingProvider.notifier).state = hasSeenOnBoarding;
  } catch (e) {
    debugPrint('>>> appInitProvider: Onboarding error: $e');
  }

  await Future.wait([minDisplay, initTasks]);
  debugPrint('>>> appInitProvider: DONE');
});

Future<void> _runInitTasks(Ref ref) async {
  debugPrint('>>> initTasks: Starting...');

  // 1. Attente de l'état d'auth
  // On utilise un timeout court ici car l'auth doit être quasi instantanée
  await _safe(() => ref.read(authStateProvider.future).timeout(const Duration(seconds: 3)));
  debugPrint('>>> initTasks: Auth resolved');

  // 2. Préchargement des données
  await Future.wait([
    _safe(() => ref.read(profileCompletedProvider.future).timeout(const Duration(seconds: 5))),
    _safe(() => ref.read(realtimeMenuProvider.future).timeout(const Duration(seconds: 5))),
    _safe(() => ref.read(categorieProvider.future).timeout(const Duration(seconds: 5))),
  ]);
  debugPrint('>>> initTasks: Data preloaded');

  // S'assure que Supabase a bien restauré une session existante
  try {
    Supabase.instance.client.auth.currentSession;
  } catch (_) {}
}

/// Exécute une tâche d'initialisation en avalant son erreur éventuelle.
/// Chaque provider (StreamProvider / AsyncNotifierProvider) garde ensuite
/// son propre état d'erreur pour que l'UI puisse l'afficher (retry, etc.) ;
/// on ne veut juste pas qu'un provider en échec bloque tout le splash.
Future<void> _safe(Future Function() task) async {
  try {
    await task();
  } catch (_) {
    // Erreur avalée volontairement.
  }
}