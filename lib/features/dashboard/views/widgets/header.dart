import 'package:flutter/material.dart';
import 'package:shop_good/features/dashboard/views/widgets/cart_button_badge.dart';
import 'package:shop_good/app/theme/app_colors.dart';


class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50, // Ajustez la hauteur si nécessaire
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(height: 5),
          // logo Shop +
          Image.asset(
            'assets/images/shop_logo.png',
            width: 100,
            height: 50,
          ),
          Positioned(
            right: 10, // Un petit décalage du bord droit
            child: CartButtonWithBadge(),
          ),
        ],
      ),
    );
  }
}
