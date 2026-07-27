// features/onboarding/data/onboarding_data.dart

import '../models/onBoadingModel.dart';

final List<OnboardingSlideModel> onboardingSlides = [
  const OnboardingSlideModel(
    imageAsset: 'assets/images/hamburger.jpg',
    title: 'Le goût qui fait revenir',
    subtitle: 'Des recettes maison préparées avec des ingrédients frais, chaque jour.',
  ),
  const OnboardingSlideModel(
    imageAsset: 'assets/images/hamburger.jpg',
    title: 'Commande en quelques taps',
    subtitle: 'Parcours le menu, personnalise tes plats et valide en un instant.',
  ),
  const OnboardingSlideModel(
    imageAsset: 'assets/images/hamburger.jpg',
    title: 'Livré chez toi, ou prêt à l\'heure',
    subtitle: 'Choisis la livraison ou le retrait en boutique, sans attendre.',
  ),
  const OnboardingSlideModel(
    imageAsset: 'assets/images/hamburger.jpg',
    title: 'Des récompenses à chaque commande',
    subtitle: 'Cumule des points et profite d\'offres exclusives rien que pour toi.',
  ),
];