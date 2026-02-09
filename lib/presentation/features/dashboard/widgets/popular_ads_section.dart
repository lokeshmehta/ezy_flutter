import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/product_list_provider.dart';
import '../../products/products_list_screen.dart';
import 'dashboard_banner_item_widget.dart';
import 'section_header_widget.dart';

class PopularAdsSection extends StatefulWidget {
  const PopularAdsSection({super.key});

  @override
  State<PopularAdsSection> createState() => _PopularAdsSectionState();
}

class _PopularAdsSectionState extends State<PopularAdsSection> {
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
        final response = provider.popularAdvertisementsResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = response.results!;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Popular Ads",
              onPrevTap: _canScrollLeft ? () => _scroll(false) : null,
              onNextTap: _canScrollRight ? () => _scroll(true) : null,
            ),
            SizedBox(
              height: 180.h,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                   final item = items[index];
                   if (item == null) return const SizedBox.shrink();

                   return DashboardBannerItemWidget(
                     item: item,
                     onTap: () {
                        if (item.brandid != null && item.brandid != "0") {
                          final productProvider = context.read<ProductListProvider>();
                          productProvider.clearFilters();
                          productProvider.setSupplier(item.brandid!);
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProductsListScreen()),
                          );
                        }
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
