import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../data/models/home_models.dart';
import 'package:provider/provider.dart';
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
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  void _goToPage(bool forward, int totalPages) {
    int nextPage = forward ? _currentPage + 1 : _currentPage - 1;

    if (nextPage < 0) nextPage = totalPages - 1;
    if (nextPage >= totalPages) nextPage = 0;

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products == null || widget.products!.isEmpty) {
      return const SizedBox.shrink();
    }

    final products = widget.products!;
    final totalPages = (products.length / 2).ceil();
    final double itemWidth = (1.sw / 2) - 25.w;

    return Column(
      children: [
        SectionHeaderWidget(
          title: widget.title,
          onPrevTap:
          totalPages > 1 ? () => _goToPage(false, totalPages) : null,
          onNextTap:
          totalPages > 1 ? () => _goToPage(true, totalPages) : null,
        ),
        SizedBox(
          height: 290.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, pageIndex) {
              final firstIndex = pageIndex * 2;
              final secondIndex = firstIndex + 1;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildProduct(
                        context,
                        products[firstIndex],
                        itemWidth,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: secondIndex < products.length
                          ? _buildProduct(
                        context,
                        products[secondIndex],
                        itemWidth,
                      )
                          : const SizedBox(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProduct(
      BuildContext context,
      ProductItem? product,
      double itemWidth,
      ) {
    if (product == null) return const SizedBox.shrink();

    return ProductItemWidget(
      item: product,
      width: itemWidth,
      onTap: () {
        context.push(AppRoutes.productDetails,
            extra: product.productId);
      },
      onFavorite: () {
        final provider = context.read<DashboardProvider>();
        if (product.productId != null) {
          provider.fetchWishlistCategories(product.productId!);
          showDialog(
            context: context,
            builder: (context) =>
                WishlistCategoryDialog(product: product),
          );
        }
      },
      onAddToCart: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) =>
              ProductDetailsBottomSheet(product: product),
        );
      },
      badgeLabel: widget.badgeLabel,
    );
  }
}

