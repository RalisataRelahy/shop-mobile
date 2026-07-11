import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  final String text;
  final int maxLine;
  final double fontSize;
  final Color strokeColor;
  final Color textColor;
  final double strokeWidth;

  const StrokeText({
    super.key,
    required this.text,
    this.fontSize = 32,
    this.maxLine=1,
    this.strokeColor = Colors.black,
    this.textColor = Colors.white,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Étape 1 : Le texte en arrière-plan qui sert de contour
        Text(
          text,
          maxLines: maxLine,
          style: TextStyle(
            fontSize: fontSize,

            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // Étape 2 : Le texte au premier plan qui remplit l'intérieur
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
