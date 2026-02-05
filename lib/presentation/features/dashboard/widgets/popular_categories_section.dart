import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_promotion_item_widget.dart';
import 'section_header_widget.dart';

class PopularCategoriesSection extends StatefulWidget {
  const PopularCategoriesSection({super.key});

  @override
  State<PopularCategoriesSection> createState() => _PopularCategoriesSectionState();
}

class _PopularCategoriesSectionState extends State<PopularCategoriesSection> {
  final ScrollController _scrollController = ScrollController();

  void _scroll(bool forward) {
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.popularCategoriesResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = response.results!.where((item) {
           return item != null && item.categoryProductsCount != "0";
        }).toList();

        if (categories.isEmpty) return const SizedBox.shrink();

        final double cardWidth = (1.sw / 2) - 25.w;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Popular Categories",
              onPrevTap: () => _scroll(false),
              onNextTap: () => _scroll(true),
            ),
            SizedBox(
              height: 240.h, // Dynamic height
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                   final item = categories[index];
                   if (item == null) return const SizedBox.shrink();

                   final count = item.categoryProductsCount ?? "0";
                   final subtitle = count == "1" ? "$count Product" : "$count Products";

                   return HomePromotionItemWidget(
                     imageUrl: item.image,
                     title: item.groupLevel1 ?? item.popularCategory ?? "", 
                     subtitle: subtitle,
                     width: cardWidth,
                     onTap: () {
                        // Navigate to Products list
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
