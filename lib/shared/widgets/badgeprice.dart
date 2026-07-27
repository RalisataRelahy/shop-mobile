import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shop_good/utils/factorisingprice.dart';

class OvalPromoBadge extends StatelessWidget {
  final int text;
  final TextStyle? textStyle;
  final Color badgeColor;
  final int points;

  const OvalPromoBadge({
    super.key,
    required this.text,
    this.textStyle,
    this.badgeColor = Colors.redAccent,
    this.points = 10, // Un nombre plus élevé de pointes (24-32) rend l'ovale plus fluide
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OvalStarPainter(
        color: badgeColor,
        points: points,
      ),
      child: Container(
        // Un padding asymétrique pour épouser la forme ovale (plus large que haut)
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        alignment: Alignment.center,
        child: Text(
          '${factorisingPrice(text)} Ar',
          textAlign: TextAlign.center,
          style: textStyle ?? const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _OvalStarPainter extends CustomPainter {
  final Color color;
  final int points;

  _OvalStarPainter({required this.color, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true; // Assure des contours lisses sans pixellisation

    final path = Path();
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Rayons Externes (Bord extérieur de l'ovale)
    final double outerRadiusX = size.width / 2;
    final double outerRadiusY = size.height / 2;

    // Rayons Internes (Creux du zigzag, réglé à 85% de la taille externe)
    final double innerRadiusX = outerRadiusX * 0.70;
    final double innerRadiusY = outerRadiusY * 0.70;

    final double angleStep = (2 * pi) / (points * 2);

    // Point de départ
    path.moveTo(cx + outerRadiusX * cos(0), cy + outerRadiusY * sin(0));

    for (int i = 1; i <= points * 2; i++) {
      final double currentAngle = i * angleStep;

      // Alternance des rayons pour créer le zigzag
      final double rx = (i % 2 == 0) ? outerRadiusX : innerRadiusX;
      final double ry = (i % 2 == 0) ? outerRadiusY : innerRadiusY;

      path.lineTo(
        cx + rx * cos(currentAngle),
        cy + ry * sin(currentAngle),
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OvalStarPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.points != points;
  }
}
