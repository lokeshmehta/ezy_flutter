import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'home_promotion_item_widget.dart';
import 'section_header_widget.dart';
import 'package:intl/intl.dart'; 
import '../../../providers/product_list_provider.dart';


class PromotionsSection extends StatefulWidget {
  const PromotionsSection({super.key});

  @override
  State<PromotionsSection> createState() => _PromotionsSectionState();
}

class _PromotionsSectionState extends State<PromotionsSection> {
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
    const double scrollAmount = 250;
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

  String _formatDate(String? dateStr) {
     if (dateStr == null || dateStr.isEmpty) return "";
     try {
       final DateTime date = DateTime.parse(dateStr);
       return DateFormat("MMM dd, yyyy").format(date);
     } catch (e) {
       return dateStr;
     }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.promotionsResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final promotions = response.results!;
        final double cardWidth = (1.sw / 2) - 25.w;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Promotions",
              onPrevTap: _canScrollLeft ? () => _scroll(false) : null,
              onNextTap: _canScrollRight ? () => _scroll(true) : null,
            ),
            SizedBox(
              height: 240.h, // Dynamic height
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                scrollDirection: Axis.horizontal,
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                   final item = promotions[index];
 
                   return HomePromotionItemWidget(
                     imageUrl: item.image,
                     title: item.title ?? "",
                     subtitle: "Valid until ${_formatDate(item.toDate)}", 
                     width: cardWidth,
                     onTap: () {
                        final productProvider = context.read<ProductListProvider>();
                        productProvider.clearFilters();
                        
                        // Extract product IDs
                        if (item.products != null && item.products!.isNotEmpty) {
                          final productIds = item.products!.map((p) => p.productId).whereType<String>().join(',');
                          productProvider.setSelectedProducts(productIds);
                        }
                        
                        if (item.divisionId != null && item.divisionId != "0") {
                          productProvider.setCategory(item.divisionId!);
                        }
                        
                        if (item.groupId != null && item.groupId != "0") {
                          productProvider.setGroup(item.groupId!);
                        }

                        context.read<DashboardProvider>().setIndex(1);
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
