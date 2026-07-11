import 'package:flutter/material.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/features/categorie/views/categories_list.dart';

class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 4,
    this.initialRows = 1,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  final int crossAxisCount;
  final int initialRows;
  final double spacing;
  final double runSpacing;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with TickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleItems = expanded
        ? widget.itemCount
        : (widget.crossAxisCount * widget.initialRows).clamp(
            0,
            widget.itemCount,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down,size: 15,color:AppColors.primaryGreen)
                ],
              ),
            ),

            if (widget.itemCount > widget.crossAxisCount * widget.initialRows)
              TextButton(
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
                child: Text(expanded ? "Réduire" : "Voir tout"),
              ),
          ],
        ),
        const SizedBox(height: 10),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleItems,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              crossAxisSpacing: widget.spacing,
              mainAxisSpacing: widget.runSpacing,
              childAspectRatio: .85,
            ),
            itemBuilder: widget.itemBuilder,
          ),
        ),
      ],
    );
  }
}
