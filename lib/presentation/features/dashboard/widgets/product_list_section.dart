import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/home_models.dart';
import '../../../providers/dashboard_provider.dart';
import 'product_item_widget.dart';
import 'section_header_widget.dart';
import 'wishlist_category_dialog.dart';
import 'product_details_bottom_sheet.dart';

class ProductListSection extends StatefulWidget {
  final String title;
  final List<ProductItem?>? products;
  final VoidCallback? onSeeAll;

  const ProductListSection({
    super.key,
    required this.title,
    required this.products,
    this.onSeeAll,
    this.badgeLabel,
  });

  final String? badgeLabel;

  @override
  State<ProductListSection> createState() => _ProductListSectionState();
}

class _ProductListSectionState extends State<ProductListSection> {
  final ScrollController _scrollController = ScrollController();

  void _scroll(bool forward) {
    if (!_scrollController.hasClients) return;
    const double scrollAmount = 300;
    final double target = forward 
        ? _scrollController.offset + scrollAmount 
        : _scrollController.offset - scrollAmount;
    
    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products == null || widget.products!.isEmpty) {
      return const SizedBox.shrink();
    }

    final double itemWidth = (1.sw / 2) - 25.w;

    return Column(
      children: [
        SectionHeaderWidget(
          title: widget.title,
          onPrevTap: () => _scroll(false),
          onNextTap: () => _scroll(true),
        ),
        SizedBox(
          height: 300.h, // Dynamic height
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            scrollDirection: Axis.horizontal,
            itemCount: widget.products!.length,
            itemBuilder: (context, index) {
              final product = widget.products![index];
              if (product == null) return const SizedBox.shrink();

              return ProductItemWidget(
                item: product,
                width: itemWidth,
                onTap: () {
                   // Navigate to Product Details
                },
                onFavorite: () {
                  final provider = context.read<DashboardProvider>();
                  provider.fetchWishlistCategories(product.productId!);
                  showDialog(
                    context: context,
                    builder: (context) => WishlistCategoryDialog(product: product),
                  );
                },
                onAddToCart: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ProductDetailsBottomSheet(product: product),
                  );
                },
                badgeLabel: widget.badgeLabel,
              );
            },
          ),
        ),
      ],
    );
  }
}
