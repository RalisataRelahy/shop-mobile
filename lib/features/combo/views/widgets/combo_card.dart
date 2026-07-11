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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                            child: Center(
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
                        points: 24,
                        ),
                    ),
                    Positioned(
                      top:100,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StrokeText(text: combo.name,fontSize: 20,maxLine: 1,strokeColor: Colors.black,textColor: Colors.white,),
                              if (combo.description != null &&
                                  combo.description!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                StrokeText(text: combo.description!,fontSize: 13,maxLine: 2,strokeColor: Colors.black,textColor: Colors.white,),

                              ],
                            ],
                          ),
                        ),
                    )
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Voir le combo',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
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
  }
}
