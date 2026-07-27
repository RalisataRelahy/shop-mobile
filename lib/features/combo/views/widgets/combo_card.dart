import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/cart/providers/cart_provider.dart';
import 'package:shop_good/features/combo/data/models/combo_models.dart';
import 'package:shop_good/features/menu/views/widgets/show_pop_up_menu_items.dart';
import 'package:shop_good/shared/widgets/badgeprice.dart';
import 'package:shop_good/shared/widgets/text_stroke.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/shared/widgets/toast_notification.dart';

class ComboCard extends ConsumerWidget {
  final ComboModels combo;
  const ComboCard({super.key, required this.combo});

  void _showDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ShowPopUpMenuItems(
        combo: combo,
        onConfirmer: (product) {
          ref.read(cartProvider.notifier).addItem(product);
          ToastNotification.showSuccess(
            context,
            '${product.cartName} ajouté au panier !'
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;

        final double titleFontSize = (cardWidth * 0.062).clamp(16.0, 24.0);
        final double descFontSize = (cardWidth * 0.040).clamp(12.0, 16.0);
        final double buttonFontSize = (cardWidth * 0.042).clamp(13.0, 16.0);
        final double buttonPadding = (cardWidth * 0.028).clamp(8.0, 13.0);
        final double cornerRadius = (cardWidth * 0.06).clamp(14.0, 24.0);
        final double captionPadding = (cardWidth * 0.045).clamp(12.0, 20.0);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cornerRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
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
                onTap: () => _showDetails(context, ref),
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
                              child: const Icon(Icons.image_not_supported_outlined,
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
                                  Colors.black.withOpacity(0.25),
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
                            text: combo.price,
                            badgeColor: Color(0xBD066300),
                          ),
                        ),
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
                          onPressed: () => _showDetails(context, ref),
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
