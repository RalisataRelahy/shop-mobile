import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/features/menu/data/models/menu_invariant_models.dart';
import 'package:shop_good/features/menu/data/models/menu_models.dart';
import 'package:shop_good/shared/models/cart_items.dart';
import 'package:shop_good/utils/factorisingprice.dart';
import '../../../combo/data/models/combo_models.dart';

class ShowPopUpMenuItems extends StatefulWidget {
  final MenuModels? menu;
  final ComboModels? combo;
  final Function(CartProduct) onConfirmer;

  const ShowPopUpMenuItems({
    super.key,
    this.menu,
    this.combo,
    required this.onConfirmer,
  }) : assert(
         menu != null || combo != null,
         'Vous devez fournir un menu ou un combo',
       );

  @override
  State<ShowPopUpMenuItems> createState() => _ShowPopUpMenuItemsState();
}

class _ShowPopUpMenuItemsState extends State<ShowPopUpMenuItems> {
  late MenuInvariantModels selectedVariant;

  bool get isCombo => widget.combo != null;
  String get name => widget.menu?.name ?? widget.combo!.name;
  String? get description =>
      widget.menu?.description ?? widget.combo!.description;
  String get imageUrl => widget.menu?.imageUrl ?? widget.combo!.imageUrl;
  int get price => widget.menu?.cartPrice ?? widget.combo!.price;
  List<MenuInvariantModels> get variants => widget.menu?.variants ?? [];
  String get category => widget.menu?.category ?? 'Combo';

  @override
  void initState() {
    super.initState();
    if (!isCombo && variants.isNotEmpty) {
      selectedVariant = variants.first;
    } else {
      selectedVariant = MenuInvariantModels(
        id: isCombo ? widget.combo!.id : '0',
        name: isCombo ? name : 'Indisponible',
        price: price.toDouble(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;

    final scale = (size.width / 390).clamp(0.85, 1.15);
    final dialogMaxWidth = isTablet ? 480.0 : size.width;
    final dialogMaxHeight = size.height * 0.9;
    final imageHeight = (size.height * 0.26).clamp(160.0, 260.0);
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? (size.width - dialogMaxWidth) / 2 : 16,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: _buildContent(
          context,
          scale: scale,
          imageHeight: imageHeight,
          horizontalPadding: horizontalPadding,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required double scale,
    required double imageHeight,
    required double horizontalPadding,
  }) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Container(
                    height: imageHeight,
                    width: double.infinity,
                    color: AppColors.lightGrey.withOpacity(0.3),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain, // Affiche l'image entière sans rognage
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: imageHeight,
                        color: AppColors.lightGrey,
                        child: Icon(
                          Icons.fastfood,
                          size: 80 * scale,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 22 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    "${factorisingPrice(selectedVariant.price.toInt())} Ar",
                    style: GoogleFonts.poppins(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  if (variants.length > 1) ...[
                    Text(
                      "Choisir une taille",
                      style: GoogleFonts.poppins(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: variants.map((variant) {
                        final isSelected = selectedVariant.id == variant.id;
                        return ChoiceChip(
                          label: Text(
                            variant.name,
                            style: GoogleFonts.poppins(fontSize: 13 * scale),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedVariant = variant;
                              });
                            }
                          },
                          selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                          labelStyle: GoogleFonts.poppins(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16 * scale),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 16 * scale,
                        color: AppColors.mediumGrey,
                      ),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: AppColors.mediumGrey,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  if (description != null && description!.isNotEmpty) ...[
                    Text(
                      "Description",
                      style: GoogleFonts.poppins(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      description!,
                      style: GoogleFonts.poppins(
                        fontSize: 14 * scale,
                        color: AppColors.darkGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                  SizedBox(height: 24 * scale),
                  SizedBox(
                    width: double.infinity,
                    height: 50 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                        // On construit le produit final selon si c'est un combo ou un menu variant
                        final CartProduct result = isCombo
                            ? widget.combo!
                            : MenuVariantCartItem(
                                menu: widget.menu!,
                                variant: selectedVariant,
                              );
                        widget.onConfirmer(result);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "Commander",
                        style: GoogleFonts.poppins(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
