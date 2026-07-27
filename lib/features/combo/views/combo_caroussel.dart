import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/combo/views/providers/combo_providers.dart';
import 'package:shop_good/features/combo/views/widgets/combo_card.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import '../data/models/combo_models.dart';

class ComboCarrousel extends ConsumerStatefulWidget {
  const ComboCarrousel({super.key});

  @override
  ConsumerState<ComboCarrousel> createState() => _ComboCarrouselState();
}

class _ComboCarrouselState extends ConsumerState<ComboCarrousel> {
  late PageController _pageController;
  int _currentPage = 0;
  double _currentFraction = 0.85;
  bool _isSwappingController = false;

  double _getViewportFraction(double width) {
    if (width >= 1200) return 0.28;
    if (width >= 900) return 0.36;
    if (width >= 600) return 0.5;
    return 0.85;
  }

  double _getCardHeight(double width, double fraction) {
    final cardWidth = width * fraction;
    final imageHeight = cardWidth * (10 / 16);
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
    final comboAsync = ref.watch(realtimeComboProvider);

    return comboAsync.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) {
        print(err); // Point-virgule obligatoire après le print
        return SizedBox(
          height: 220,
          child: Center(
            child: Text('Erreur de chargement du combo: $err'),
          ),
        );
      },

      data: (combos) {
        if (combos.isEmpty) {
          return const SizedBox(
            height: 220,
            child: Center(child: Text('Aucun combo disponible pour le moment')),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final fraction = _getViewportFraction(width);
            final cardHeight = _getCardHeight(width, fraction);
            final dotScale = _dotScale(width);

            _swapControllerIfNeeded(fraction);

            // Sécurise l'index courant si la liste a rétréci
            final safeCurrentPage = _currentPage.clamp(0, combos.length - 1);

            return Column(
              children: [
                SizedBox(
                  height: cardHeight,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: combos.length,
                    pageSnapping: true,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final combo = combos[index];
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
                    combos.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.symmetric(horizontal: 4 * dotScale),
                      height: 8 * dotScale,
                      width: (safeCurrentPage == index ? 24 : 8) * dotScale,
                      decoration: BoxDecoration(
                        color: safeCurrentPage == index
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
      },
    );
  }
}