import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shop_good/features/auth/providers/auth_provider.dart';
import 'package:shop_good/features/auth/views/login_screen.dart';
import 'package:shop_good/features/auth/views/signup_screen.dart';
import 'package:shop_good/features/orders/views/checkout_orders.dart';
import 'package:shop_good/features/profile/views/edit_profile_screen.dart';

import 'package:shop_good/shared/views/main_layout.dart';
import 'package:shop_good/shared/views/splash_screen.dart';
import 'package:shop_good/shared/providers/app_init_provider.dart';

import '../../features/onBoardinPage/views/on_boarding_page.dart';
import '../../features/onBoardinPage/views/providers/on_boarding_page_providers.dart';

import '../../features/profile/views/complete_your_profil_screen.dart';

// =======================================================
// Notifier pour forcer GoRouter à refaire redirect()
// =======================================================

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });

    ref.listen(profileCompletedProvider, (_, __) {
      notifyListeners();
    });

    ref.listen(appInitProvider, (_, __) {
      notifyListeners();
    });

    ref.listen(hasSeenOnboardingProvider, (_, __) {
      notifyListeners();
    });

    ref.listen(isGuestModeProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
}

// =======================================================
// Router Provider
// =======================================================

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/splashscreen',

    refreshListenable: routerNotifier,

    redirect: (context, state) {
      final location = state.matchedLocation;

      final isSplash = location == '/splashscreen';

      final isOnboarding = location == '/onboarding';

      final isAuthPage = location == '/login' || location == '/signup';

      final initState = ref.read(appInitProvider);

      final user = Supabase.instance.client.auth.currentUser;

      final isGuest = ref.read(isGuestModeProvider);

      final hasSeenOnboarding = ref.read(hasSeenOnboardingProvider);

      final profileAsync = user == null
          ? const AsyncData(false)
          : ref.read(profileCompletedProvider);

      final profileCompleted = profileAsync.value ?? false;

      print("====================");
      print("ROUTE : $location");
      print("USER : ${user?.email}");
      print("ONBOARDING : $hasSeenOnboarding");
      print("PROFILE : $profileAsync");
      print("====================");

      // =========================
      // 1. INITIALISATION
      // =========================

      if (initState.isLoading) {
        return isSplash ? null : '/splashscreen';
      }
      // =========================
      // 2. ONBOARDING
      // PRIORITE MAXIMUM
      // =========================

      if (!hasSeenOnboarding) {
        if (isOnboarding) {
          return null;
        }

        return '/onboarding';
      }

      // =========================
      // 3. SPLASH FINI
      // =========================

      if (isSplash) {
        if (user != null) {
          if (profileAsync.isLoading) {
            return '/splashscreen';
          }

          if (!profileCompleted) {
            return '/complete-profile';
          }

          return '/';
        }

        if (isGuest) {
          return '/';
        }

        return '/login';
      }

      // =========================
      // 4. UTILISATEUR NON CONNECTE
      // =========================

      if (user == null && !isGuest) {
        if (isAuthPage) {
          return null;
        }

        return '/login';
      }

      // =========================
      // 5. PROFIL INCOMPLET
      // =========================

      if (user != null) {
        if (profileAsync.isLoading) {
          return null;
        }

        if (!profileCompleted && location != '/complete-profile') {
          return '/complete-profile';
        }
      }

      // =========================
      // 6. CONNECTE MAIS SUR LOGIN
      // =========================

      if ((user != null || isGuest) && isAuthPage) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainLayout()),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(onFinished: () {}),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: '/splashscreen',
        builder: (context, state) => const SplashScreen(),
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
  ref.onDispose(routerNotifier.dispose);
  return router;
});
