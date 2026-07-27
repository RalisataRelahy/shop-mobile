import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/about/views/about_screen.dart';
import 'package:shop_good/features/dashboard/views/home_screen.dart';
import 'package:shop_good/features/notifications/views/notifications_screen.dart';
import 'package:shop_good/features/notifications/views/providers/notification_providers.dart';
import 'package:shop_good/features/orders/views/order_screen.dart';
import 'package:shop_good/app/theme/app_colors.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
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

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const OrdersPage(),
    const NotificationsScreen(),
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

  double _scaleFactor(double width) {
    if (width < 360) return 0.90;
    if (width < 600) return 1.0;
    if (width < 900) return 1.15;
    return 1.3;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scale = _scaleFactor(width);

        final double iconSizeSelected = (26 * scale).clamp(22.0, 34.0);
        final double iconSizeUnselected = (24 * scale).clamp(20.0, 30.0);
        final double labelFontSizeSelected = (13 * scale).clamp(11.0, 18.0);
        final double topRadius = (24 * scale).clamp(16.0, 36.0);
        final double navBarHeight = (70 * scale).clamp(56.0, 96.0);
        final double blurRadius = (10 * scale).clamp(8.0, 18.0);
        final double spreadRadius = (2 * scale).clamp(1.0, 4.0);

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
                color: Colors.black.withOpacity(0.08),
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
                          badgeCount: index == 2 ? unreadCount : 0,
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final double iconSize;
  final double labelFontSize;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.iconSize,
    required this.labelFontSize,
    this.badgeCount = 0,
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? selectedIcon : icon,
                    color: color,
                    size: iconSize,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 2),
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
