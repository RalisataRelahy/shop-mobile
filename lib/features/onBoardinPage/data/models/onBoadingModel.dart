// features/onboarding/data/models/onboarding_slide_model.dart

class OnboardingSlideModel {
  final String imageAsset; // ou imageUrl si tu préfères charger depuis le réseau
  final String title;
  final String subtitle;

  const OnboardingSlideModel({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });
}