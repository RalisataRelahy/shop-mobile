import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_good/features/cart/providers/cart_provider.dart';
import 'package:shop_good/features/menu/data/models/menu_invariant_models.dart';
import 'package:shop_good/features/menu/data/models/menu_models.dart';
import 'package:shop_good/features/menu/views/widgets/show_pop_up_menu_items.dart';
import 'package:shop_good/shared/widgets/toast_notification.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/utils/factorisingprice.dart';

class MenuItemCard extends ConsumerStatefulWidget {
  final MenuModels menu;
  final VoidCallback? onTap;

  const MenuItemCard({super.key, required this.menu, this.onTap});

  @override
  ConsumerState<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends ConsumerState<MenuItemCard> {
  MenuInvariantModels? selectedVariant;

  @override
  void initState() {
    super.initState();
    _initSelectedVariant();
  }

  void _initSelectedVariant() {
    if (widget.menu.variants.isNotEmpty) {
      selectedVariant = widget.menu.variants.first;
    }
  }

  @override
  void didUpdateWidget(MenuItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si le menu a changé ou si les variantes ont été mises à jour
    if (widget.menu.id != oldWidget.menu.id || widget.menu.variants != oldWidget.menu.variants) {
      if (widget.menu.variants.isNotEmpty) {
        // Tenter de retrouver la variante précédemment sélectionnée par son ID
        final index = widget.menu.variants.indexWhere((v) => v.id == selectedVariant?.id);
        if (index != -1) {
          selectedVariant = widget.menu.variants[index];
        } else {
          selectedVariant = widget.menu.variants.first;
        }
      } else {
        selectedVariant = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        final double addButtonPadding = (1 * scale).clamp(1.0, 2.0);

        // Déduplication par ID pour éviter le crash du DropdownButton si doublons en BDD
        final Map<String, MenuInvariantModels> uniqueVariantsMap = {};
        for (var v in widget.menu.variants) {
          uniqueVariantsMap[v.id] = v;
        }
        final List<MenuInvariantModels> variants = uniqueVariantsMap.values.toList();

        return InkWell(
          onTap: widget.onTap ?? () {
            showDialog(
              context: context,
              builder: (context) => ShowPopUpMenuItems(
                menu: widget.menu,
                onConfirmer: (product) {
                  ref.read(cartProvider.notifier).addItem(product);
                  ToastNotification.showSuccess(
                    context,
                    '${product.cartName} ajouté au panier !'
                  );
                },
              ),
            );
          },
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
                          widget.menu.imageUrl,
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
                        widget.menu.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Dropdown for variants
                      // Dropdown for variants
                      if (variants.length > 1)
                        Row(
                          children: [
                            Text(
                              'Taille:',
                              style: GoogleFonts.poppins(
                                fontSize: 12 * scale,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 35 * scale,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<MenuInvariantModels>(
                                    value: selectedVariant,
                                    isDense: true,
                                    isExpanded: true, // <-- force le dropdown à occuper l'espace dispo
                                    icon: const Icon(Icons.arrow_drop_down, size: 18),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13 * scale,
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    items: variants.map((variant) {
                                      return DropdownMenuItem(
                                        value: variant,
                                        child: Text(
                                          variant.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, // <-- tronque si trop long
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedVariant = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (variants.isNotEmpty)
                        Text(
                          variants.first.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // <-- idem pour le cas variante unique
                          style: GoogleFonts.poppins(
                            fontSize: 11 * scale,
                            color: AppColors.mediumGrey,
                          ),
                        ),

                      SizedBox(height: 8 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              selectedVariant != null
                                  ? "${factorisingPrice(selectedVariant!.price.toInt())} Ar"
                                  : "Prix indisponible",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: priceSize,
                              ),
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
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                if (selectedVariant != null) {
                                  final cartItem = MenuVariantCartItem(
                                    menu: widget.menu,
                                    variant: selectedVariant!,
                                  );
                                  ref.read(cartProvider.notifier).addItem(cartItem);
                                  ToastNotification.showSuccess(
                                      context,
                                      '${widget.menu.name} (${selectedVariant!.name}) ajouté au panier !'
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.add_shopping_cart_outlined,
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
