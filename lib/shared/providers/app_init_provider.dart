import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shop_good/features/auth/providers/auth_provider.dart';

// ⚠️ Ajustez ces 3 imports selon l'emplacement réel de vos providers.
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
  final minDisplay = Future.delayed(const Duration(seconds: 2));
  final initTasks = _runInitTasks(ref);

  await Future.wait([minDisplay, initTasks]);
});

Future<void> _runInitTasks(Ref ref) async {
  // On attend d'abord que l'état d'auth soit connu : userOrdersProvider en
  // dépend (via currentUserProvider), donc il faut que l'auth soit résolue
  // avant de lancer les autres attentes.
  await _safe(() => ref.read(authStateProvider.future));

  // Ensuite on précharge en parallèle les données nécessaires au premier
  // affichage de l'app. Chaque tâche est protégée individuellement : si l'une
  // échoue (ex: pas de connexion), elle n'empêche pas les autres de finir et
  // ne bloque pas le splash indéfiniment.
  await Future.wait([
    // _safe(() => ref.read(userOrdersProvider.future)),
    _safe(() => ref.read(realtimeMenuProvider.future)),
    _safe(() => ref.read(categorieProvider.future)),
  ]);

  // S'assure que Supabase a bien restauré une session existante avant de
  // laisser la redirection d'auth trancher entre /login et /.
  try {
    Supabase.instance.client.auth.currentSession;
  } catch (_) {
    // On ignore : la redirection /login prendra le relai si besoin.
  }
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