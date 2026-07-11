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
    const textZoneHeight = 100.0;
    return imageHeight + textZoneHeight;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = _getViewportFraction(width);
        final cardHeight = _getCardHeight(width, fraction);

        if (_pageController.viewportFraction != fraction) {
          final oldPage = _pageController.hasClients
              ? (_pageController.page?.round() ?? _currentPage)
              : _currentPage;
          _pageController.dispose();
          _pageController = PageController(
            viewportFraction: fraction,
            initialPage: oldPage,
          );
        }

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
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryGreen
                        : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(4),
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
