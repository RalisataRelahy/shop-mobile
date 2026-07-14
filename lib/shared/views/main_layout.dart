import 'package:flutter/material.dart';
import 'package:shop_good/features/about/views/about_screen.dart';
import 'package:shop_good/features/dashboard/views/home_screen.dart';
import 'package:shop_good/features/orders/views/order_screen.dart';
import 'package:shop_good/app/theme/app_colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    OrdersPage(),
    const Center(child: Text('Mes notifications', style: TextStyle(fontSize: 24))),
    const AboutScreen(),
  ];

  static const List<_NavItemData> _destinations = [
    _NavItemData(
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
      label: 'Accueil',
    ),
    _NavItemData(
      icon: Icons.delivery_dining_outlined,
      selectedIcon: Icons.delivery_dining_rounded,
      label: 'Ma commande',
    ),
    _NavItemData(
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications_rounded,
      label: 'Notifications',
    ),
    _NavItemData(
      icon: Icons.info_outline,
      selectedIcon: Icons.info_rounded,
      label: 'A propos',
    ),
  ];

  /// Retourne un facteur d'échelle en fonction de la largeur de l'écran.
  /// - < 360 : petits téléphones -> on réduit un peu
  /// - 360-600 : téléphones standards -> échelle de référence
  /// - 600-900 : phablettes / petites tablettes -> légère augmentation
  /// - > 900 : tablettes / desktop -> augmentation plus marquée
  double _scaleFactor(double width) {
    if (width < 360) return 0.90;
    if (width < 600) return 1.0;
    if (width < 900) return 1.15;
    return 1.3;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scale = _scaleFactor(width);

        // Tailles adaptatives
        final double iconSizeSelected = (26 * scale).clamp(22.0, 34.0);
        final double iconSizeUnselected = (24 * scale).clamp(20.0, 30.0);
        final double labelFontSizeSelected = (13 * scale).clamp(11.0, 18.0);
        final double topRadius = (24 * scale).clamp(16.0, 36.0);
        final double navBarHeight = (64 * scale).clamp(56.0, 96.0);
        final double blurRadius = (10 * scale).clamp(8.0, 18.0);
        final double spreadRadius = (2 * scale).clamp(1.0, 4.0);

        // Sur très grand écran (desktop/tablette large), on limite la largeur
        // de la barre de navigation pour éviter qu'elle s'étire à l'infini,
        // et on la centre.
        final bool isWideScreen = width > 900;
        final double navBarMaxWidth = isWideScreen ? 700 : double.infinity;

        Widget navigationBar = Container(
          height: navBarHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topRadius),
              topRight: Radius.circular(topRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: blurRadius,
                spreadRadius: spreadRadius,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topRadius + 6),
              topRight: Radius.circular(topRadius + 6),
            ),
            child: ColoredBox(
              color: AppColors.surfaceWhite,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: navBarHeight,
                  child: Row(
                    children: List.generate(_destinations.length, (index) {
                      final destination = _destinations[index];
                      final bool isSelected = index == _currentIndex;

                      return Expanded(
                        child: _NavItem(
                          icon: destination.icon,
                          selectedIcon: destination.selectedIcon,
                          label: destination.label,
                          isSelected: isSelected,
                          iconSize: isSelected ? iconSizeSelected : iconSizeUnselected,
                          labelFontSize: labelFontSizeSelected,
                          onTap: () => setState(() => _currentIndex = index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );

        // Centrage + largeur max sur grands écrans
        if (isWideScreen) {
          navigationBar = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: navBarMaxWidth),
              child: navigationBar,
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: navigationBar,
        );
      },
    );
  }
}

/// Un item de barre de navigation dont le label ne passe jamais à la ligne :
/// s'il est trop long pour la largeur disponible, il rétrécit automatiquement
/// (via FittedBox) au lieu de wrapper sur 2 lignes ou de déborder.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final double iconSize;
  final double labelFontSize;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.iconSize,
    required this.labelFontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? AppColors.primaryGreen : AppColors.mediumGrey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: color,
                size: iconSize,
              ),
              if (isSelected) ...[
                const SizedBox(height: 2),
                // FittedBox force le label à rester sur une seule ligne :
                // s'il ne rentre pas dans la largeur allouée à cet item,
                // il est réduit proportionnellement plutôt que de wrapper.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}