import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';
import 'package:shop_good/features/auth/views/login_screen.dart';
import 'package:shop_good/features/auth/views/signup_screen.dart';
import 'package:shop_good/features/orders/views/checkout_orders.dart';
import 'package:shop_good/shared/views/main_layout.dart';
import 'package:shop_good/shared/views/splash_screen.dart';
import 'package:shop_good/shared/providers/app_init_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Écoute les changements d'auth pour rafraîchir le router.
  ref.watch(authStateProvider);

  // Écoute l'état d'initialisation globale de l'app.
  // Tant qu'il est en chargement, on reste bloqué sur /splashscreen.
  final initState = ref.watch(appInitProvider);

  return GoRouter(
    initialLocation: '/splashscreen',
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splashscreen';

      // 1. Tant que l'init n'est pas terminée -> on force/garde le splash.
      if (initState.isLoading) {
        return isSplash ? null : '/splashscreen';
      }

      // 2. Init terminée : logique d'auth normale.
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // On quitte le splash vers la bonne destination dès que possible.
      if (isSplash) {
        return user == null ? '/login' : '/';
      }

      if (user == null) {
        return isLoggingIn ? null : '/login';
      }
      if (isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/splashscreen',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutConfigScreen(),
      ),
    ],
  );
});