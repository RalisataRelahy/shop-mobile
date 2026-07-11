import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';
import 'package:shop_good/features/auth/views/login_screen.dart';
import 'package:shop_good/features/auth/views/signup_screen.dart';
import 'package:shop_good/shared/views/main_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth changes to trigger router refresh
  ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
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
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
    ],
  );
});
