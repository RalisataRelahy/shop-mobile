import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';
import 'package:shop_good/features/auth/views/login_screen.dart';
import 'package:shop_good/features/auth/views/signup_screen.dart';
import 'package:shop_good/features/orders/views/checkout_orders.dart';
import 'package:shop_good/features/profile/views/edit_profile_screen.dart';
import 'package:shop_good/shared/views/main_layout.dart';
import 'package:shop_good/shared/views/splash_screen.dart';
import 'package:shop_good/shared/providers/app_init_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/onBoardinPage/views/on_boarding_page.dart';
import '../../features/onBoardinPage/views/providers/on_boarding_page_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Écoute les changements d'auth pour rafraîchir le router.
  ref.watch(authStateProvider);

  // Écoute l'état d'initialisation globale de l'app.
  final initState = ref.watch(appInitProvider);

  // Écoute le flag onboarding : dès qu'il passe à true (fin de l'onboarding),
  // le router doit se reconstruire pour ré-évaluer le redirect.
  ref.watch(hasSeenOnboardingProvider);

  return GoRouter(
    initialLocation: '/splashscreen',
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splashscreen';
      final isOnboarding = state.matchedLocation == '/onboarding';

      // 1. Tant que l'init n'est pas terminée -> on force/garde le splash.
      if (initState.isLoading) {
        return isSplash ? null : '/splashscreen';
      }

      // 2. Init terminée : logique auth + onboarding.
      final user = Supabase.instance.client.auth.currentUser;
      final isGuest = ref.read(isGuestModeProvider);
      final hasSeenOnboarding = ref.read(hasSeenOnboardingProvider);

      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // On quitte le splash vers la bonne destination dès que possible.
      if (isSplash) {
        if (!hasSeenOnboarding) return '/onboarding';
        if (user != null) return '/';
        if (isGuest) return '/';
        return '/login';
      }

      // Onboarding pas encore vu -> on y force l'utilisateur en priorité,
      // sauf s'il y est déjà.
      if (!hasSeenOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      // Onboarding déjà vu mais l'utilisateur essaie d'y retourner -> on l'en sort.
      if (hasSeenOnboarding && isOnboarding) {
        if (user != null || isGuest) return '/';
        return '/login';
      }

      // Si pas connecté ET pas invité -> vers login (sauf si on y est déjà)
      if (user == null && !isGuest) {
        return isLoggingIn ? null : '/login';
      }

      // Si connecté OU invité, et qu'on essaie d'aller sur login/signup -> vers accueil
      if ((user != null || isGuest) && isLoggingIn) {
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
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(
          onFinished: () {
            // Le controller met à jour hasSeenOnboardingProvider,
            // ce qui déclenche automatiquement le redirect vers login/home.
            // Pas besoin de context.go() manuel ici.
          },
        ),
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
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
});