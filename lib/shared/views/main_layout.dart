import 'package:flutter/material.dart';
import 'package:shop_good/features/dashboard/views/home_screen.dart';
import 'package:shop_good/features/profile/views/profile_screen.dart';
import 'package:shop_good/app/theme/app_colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Favoris', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Ma livraison', style: TextStyle(fontSize: 24))),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppColors.surfaceWhite,
              elevation: 0,
              indicatorColor: Colors.transparent,
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(
                    color: AppColors.primaryGreen,
                    size: 26,
                  );
                }
                return const IconThemeData(
                  color: AppColors.mediumGrey,
                  size: 24,
                );
              }),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  );
                }
                return const TextStyle(
                  color: AppColors.mediumGrey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favoris',
                ),
                NavigationDestination(
                  icon: Icon(Icons.delivery_dining_outlined),
                  selectedIcon: Icon(Icons.delivery_dining_rounded),
                  label: 'Ma commande',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_2_outlined),
                  selectedIcon: Icon(Icons.person_2_rounded),
                  label: 'Moi',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
