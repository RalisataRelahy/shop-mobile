import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_good/features/cart/providers/cart_provider.dart';
import 'package:shop_good/features/menu/data/models/menu_models.dart';
import 'package:shop_good/shared/widgets/toast_notification.dart';
import 'package:shop_good/app/theme/app_colors.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuModels menu;
  final VoidCallback? onTap;

  const MenuItemCard({super.key, required this.menu, this.onTap});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 170.0;

        final double scale = (width / 170.0).clamp(0.75, 1.6);

        final double borderRadius = 18 * scale;
        final double padding = (10 * scale).clamp(8.0, 16.0);
        final double titleSize = (14 * scale).clamp(12.0, 17.0);
        final double priceSize = (14 * scale).clamp(12.0, 17.0);
        final double addIconSize = (18 * scale).clamp(16.0, 22.0);
        final double addButtonPadding = (1 * scale).clamp(2.0, 4.0);
        final double favIconSize = (18 * scale).clamp(16.0, 22.0);
        final double favPadding = (6 * scale).clamp(5.0, 9.0);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10 * scale,
                  offset: Offset(0, 5 * scale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius),
                        ),
                        child: Image.network(
                          menu.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: AppColors.lightGrey,
                              child: Icon(
                                Icons.fastfood,
                                size: 40 * scale,
                                color: AppColors.mediumGrey,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8 * scale,
                        right: 8 * scale,
                        child: Container(
                          padding: EdgeInsets.all(favPadding),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceWhite,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            size: favIconSize,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        menu.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            size: 14,
                            color: AppColors.darkGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            menu.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${menu.price} Ar",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: priceSize,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 6 * scale),

                          Container(
                            padding: EdgeInsets.all(addButtonPadding),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                ref.read(cartProvider.notifier).addItem(menu);
                                ToastNotification.showSuccess(
                                    context,
                                    '${menu.name} ajouté au panier !'
                                );
                              },
                              icon: Icon(
                                Icons.add,
                                color: AppColors.surfaceWhite,
                                size: addIconSize,
                              )
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
