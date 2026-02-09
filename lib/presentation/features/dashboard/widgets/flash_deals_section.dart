import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../providers/dashboard_provider.dart';
import 'flash_deal_item_widget.dart';
import 'section_header_widget.dart';
import 'wishlist_category_dialog.dart';
import 'product_details_bottom_sheet.dart';

class FlashDealsSection extends StatefulWidget {
  const FlashDealsSection({super.key});

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    setState(() {
      _canScrollLeft = currentScroll > 0;
      _canScrollRight = currentScroll < maxScroll;
    });
  }

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
     _scrollController.removeListener(_updateScrollState);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.flashDealsResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final products = response.results!;
        final double width = MediaQuery.of(context).size.width;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Flash Deals",
              onPrevTap: _canScrollLeft ? () => _scroll(false) : null,
              onNextTap: _canScrollRight ? () => _scroll(true) : null,
            ),
            SizedBox(
              height: 280.h, // Dynamic height
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                   final item = products[index];
                   if (item == null) return const SizedBox.shrink();

                   return FlashDealItemWidget(
                     item: item,
                     width: width - 40,
                     onTap: () {
                        context.push(AppRoutes.productDetails, extra: item.productId);
                     },
                     onFavorite: () {
                       final provider = context.read<DashboardProvider>();
                       if (item.productId != null) {
                           provider.fetchWishlistCategories(item.productId!);
                           showDialog(
                             context: context,
                             builder: (context) => WishlistCategoryDialog(product: item),
                           );
                       }
                     },
                     onAddToCart: () {
                       showModalBottomSheet(
                         context: context,
                         isScrollControlled: true,
                         backgroundColor: Colors.transparent,
                         builder: (context) => ProductDetailsBottomSheet(product: item),
                       );
                     },
                   );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
