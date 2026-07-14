import 'package:flutter/material.dart';
import 'package:shop_good/features/combo/data/models/combo_models.dart';
import 'package:shop_good/shared/widgets/badgeprice.dart';
import 'package:shop_good/shared/widgets/text_stroke.dart';
import 'package:shop_good/app/theme/app_colors.dart';

class ComboCard extends StatelessWidget {
  final ComboModels combo;
  const ComboCard({super.key, required this.combo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // La carte peut avoir n'importe quelle largeur selon l'écran
        // (carrousel mobile, grille tablette/desktop...). On dérive toutes
        // les tailles de cette largeur plutôt que d'utiliser des valeurs
        // fixes, avec des bornes pour rester lisible dans tous les cas.
        final double cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;

        final double titleFontSize = (cardWidth * 0.062).clamp(16.0, 24.0);
        final double descFontSize = (cardWidth * 0.040).clamp(12.0, 16.0);
        final double badgePoints = (cardWidth * 0.075).clamp(18.0, 30.0);
        final double buttonFontSize = (cardWidth * 0.042).clamp(13.0, 16.0);
        final double buttonPadding = (cardWidth * 0.028).clamp(8.0, 13.0);
        final double cornerRadius = (cardWidth * 0.06).clamp(14.0, 24.0);
        final double captionPadding = (cardWidth * 0.045).clamp(12.0, 20.0);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cornerRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius),
            child: Material(
              color: theme.cardColor,
              child: InkWell(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Image.network(
                            combo.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: AppColors.backgroundOffWhite,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.backgroundOffWhite,
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: AppColors.mediumGrey, size: 32),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.25),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: -1,
                          child: OvalPromoBadge(
                            text: '${combo.price} Ar',
                            badgeColor: AppColors.primaryGreen,
                            // points: int.parse(badgePoints as String) ,
                          ),
                        ),
                        // Ancré en bas de l'image (au lieu d'un décalage
                        // fixe en pixels) : reste toujours collé au bord
                        // inférieur quelle que soit la hauteur de l'image.
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              captionPadding,
                              14,
                              captionPadding,
                              captionPadding * 0.8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StrokeText(
                                  text: combo.name,
                                  fontSize: titleFontSize,
                                  maxLine: 1,
                                  strokeColor: Colors.black,
                                  textColor: Colors.white,
                                ),
                                if (combo.description != null &&
                                    combo.description!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  StrokeText(
                                    text: combo.description!,
                                    fontSize: descFontSize,
                                    maxLine: 2,
                                    strokeColor: Colors.black,
                                    textColor: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.primaryGreen, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: buttonPadding),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Voir le combo',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: buttonFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}