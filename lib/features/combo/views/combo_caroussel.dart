import 'package:flutter/material.dart';
import 'package:shop_good/features/combo/views/widgets/combo_card.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import '../data/models/combo_models.dart';

class ComboCarrousel extends StatefulWidget {
  const ComboCarrousel({super.key});

  @override
  State<ComboCarrousel> createState() => _ComboCarrouselState();
}

class _ComboCarrouselState extends State<ComboCarrousel> {
  late PageController _pageController;
  int _currentPage = 0;
  double _currentFraction = 0.85;
  bool _isSwappingController = false;

  final List<ComboModels> _combosMock = [
    ComboModels(
      id: "1",
      name: "Combo Burger King",
      description: "Burger + Frites + Boisson",
      price: 25000,
      imageUrl: "https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=800",
      isActive: true,
    ),
    ComboModels(
      id: "2",
      name: "Combo Pizza Family",
      description: "2 Pizzas XL + 1L Coca",
      price: 45000,
      imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800",
      isActive: true,
    ),
    ComboModels(
      id: "3",
      name: "Combo Sushi Zen",
      description: "12 California + 6 Maki + Soupe",
      price: 35000,
      imageUrl: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800",
      isActive: true,
    ),
  ];

  double _getViewportFraction(double width) {
    if (width >= 1200) return 0.28;
    if (width >= 900) return 0.36;
    if (width >= 600) return 0.5;
    return 0.85;
  }

  double _getCardHeight(double width, double fraction) {
    final cardWidth = width * fraction;
    final imageHeight = cardWidth * (10 / 16);
    // Zone de texte adaptative : un peu plus grande sur cartes très étroites
    // (texte qui a besoin de plus de lignes) et bornée pour rester raisonnable.
    final textZoneHeight = (cardWidth < 220 ? 112.0 : 100.0);
    final total = imageHeight + textZoneHeight;
    return total.clamp(160.0, 320.0);
  }

  double _dotScale(double width) {
    if (width >= 900) return 1.15;
    if (width < 360) return 0.9;
    return 1.0;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _currentFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Remplace le PageController de façon sûre : on attend la fin de la frame
  /// en cours pour éviter de disposer un contrôleur pendant qu'il est utilisé
  /// par le PageView actuellement affiché.
  void _swapControllerIfNeeded(double newFraction) {
    if ((newFraction - _currentFraction).abs() < 0.001 || _isSwappingController) {
      return;
    }
    _isSwappingController = true;
    final oldController = _pageController;
    final keptPage = oldController.hasClients
        ? (oldController.page?.round() ?? _currentPage)
        : _currentPage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _currentFraction = newFraction;
        _pageController = PageController(
          viewportFraction: newFraction,
          initialPage: keptPage,
        );
        _currentPage = keptPage;
      });
      oldController.dispose();
      _isSwappingController = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = _getViewportFraction(width);
        final cardHeight = _getCardHeight(width, fraction);
        final dotScale = _dotScale(width);

        // Planifie le remplacement du contrôleur après cette frame si la
        // fraction cible a changé (rotation, redimensionnement de fenêtre...).
        _swapControllerIfNeeded(fraction);

        return Column(
          children: [
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _combosMock.length,
                pageSnapping: true,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final combo = _combosMock[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 10.0,
                    ),
                    child: ComboCard(combo: combo),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _combosMock.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(horizontal: 4 * dotScale),
                  height: 8 * dotScale,
                  width: (_currentPage == index ? 24 : 8) * dotScale,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryGreen
                        : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(4 * dotScale),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}