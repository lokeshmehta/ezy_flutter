import 'package:flutter/material.dart';
import '../../../../data/models/home_models.dart';
import 'product_item_widget.dart';
import 'section_header_widget.dart';

class ProductListSection extends StatelessWidget {
  final String title;
  final List<ProductItem> items;
  final Function(ProductItem) onTap;
  final Function(ProductItem) onAddToCart;
  final Function(ProductItem) onFavorite;

  const ProductListSection({
    super.key,
    required this.title,
    required this.items,
    required this.onTap,
    required this.onAddToCart,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    final itemWidth = (width / 2) - 30;

    return Column(
      children: [
        SectionHeaderWidget(
          title: title,
          onPrevTap: () {},
          onNextTap: () {},
        ),
        SizedBox(
          height: 270, // Estimate height: 120 img + text + price + button ~ 250-270
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ProductItemWidget(
                item: item,
                width: itemWidth,
                onTap: () => onTap(item),
                onAddToCart: () => onAddToCart(item),
                onFavorite: () => onFavorite(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
