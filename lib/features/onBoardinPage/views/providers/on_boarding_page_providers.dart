// features/onboarding/providers/onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _onboardingSeenKey = 'has_seen_onboarding';

/// État synchrone, lu/écrit en mémoire après chargement initial depuis
/// SharedPreferences (fait dans appInitProvider au démarrage de l'app).
/// C'est CE provider qu'il faut utiliser dans le router (redirect est synchrone).
final hasSeenOnboardingProvider = StateProvider<bool>((ref) => false);

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(ref);
});

class OnboardingController {
  final Ref ref;
  OnboardingController(this.ref);

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
    ref.read(hasSeenOnboardingProvider.notifier).state = true;
  }

  /// Appelé une seule fois au démarrage de l'app (dans appInitProvider)
  /// pour charger la valeur persistée dans l'état synchrone ci-dessus.
  static Future<bool> loadOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }
}