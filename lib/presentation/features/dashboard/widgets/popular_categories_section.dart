import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/product_list_provider.dart';
import 'home_promotion_item_widget.dart';
import 'section_header_widget.dart';

class PopularCategoriesSection extends StatefulWidget {
  const PopularCategoriesSection({super.key});

  @override
  State<PopularCategoriesSection> createState() =>
      _PopularCategoriesSectionState();
}

class _PopularCategoriesSectionState
    extends State<PopularCategoriesSection> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) {
          if (!_pageController.hasClients) return;

          final provider = context.read<DashboardProvider>();
          final response = provider.popularCategoriesResponse;

          if (response == null ||
              response.results == null ||
              response.results!.isEmpty) {
            return;
          }

          final categories = response.results!
              .where((item) =>
          item != null && item.categoryProductsCount != "0")
              .toList();

          if (categories.isEmpty) return;

          final totalPages = (categories.length / 2).ceil();

          int nextPage = _currentPage + 1;
          if (nextPage >= totalPages) nextPage = 0;

          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
  }

  void _goToPage(bool forward, int totalPages) {
    int nextPage = forward ? _currentPage + 1 : _currentPage - 1;

    if (nextPage < 0) nextPage = totalPages - 1;
    if (nextPage >= totalPages) nextPage = 0;

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.popularCategoriesResponse;

        if (response == null ||
            response.results == null ||
            response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = response.results!
            .where((item) =>
        item != null && item.categoryProductsCount != "0")
            .toList();

        if (categories.isEmpty) return const SizedBox.shrink();

        final totalPages = (categories.length / 2).ceil();
        final double cardWidth = (1.sw / 2) - 14.w;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Popular Categories",
              onPrevTap: totalPages > 1
                  ? () => _goToPage(false, totalPages)
                  : null,
              onNextTap: totalPages > 1
                  ? () => _goToPage(true, totalPages)
                  : null,
            ),
            SizedBox(
              height: 210.h,
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
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: HomePromotionItemWidget(
                            imageUrl:
                            categories[firstIndex]?.image,
                            title: categories[firstIndex]
                                ?.groupLevel1 ??
                                categories[firstIndex]
                                    ?.popularCategory ??
                                "",
                            subtitle: _buildSubtitle(
                                categories[firstIndex]
                                    ?.categoryProductsCount),
                            width: cardWidth,
                            onTap: () {
                              final productProvider =
                              context.read<ProductListProvider>();
                              productProvider.clearFilters();
                              productProvider.setCategory(
                                  categories[firstIndex]
                                      ?.divisionId
                                      .toString() ??
                                      "");
                              context
                                  .read<DashboardProvider>()
                                  .setIndex(1);
                            },
                          ),
                        ),
                        // Removed SizedBox(width: 15.w) to match Best Sellers spacing
                        Expanded(
                          child: secondIndex < categories.length
                              ? HomePromotionItemWidget(
                            imageUrl:
                            categories[secondIndex]
                                ?.image,
                            title: categories[secondIndex]
                                ?.groupLevel1 ??
                                categories[secondIndex]
                                    ?.popularCategory ??
                                "",
                            subtitle: _buildSubtitle(
                                categories[secondIndex]
                                    ?.categoryProductsCount),
                            width: cardWidth,
                            onTap: () {
                              final productProvider =
                              context.read<
                                  ProductListProvider>();
                              productProvider.clearFilters();
                              productProvider.setCategory(
                                  categories[secondIndex]
                                      ?.divisionId
                                      .toString() ??
                                      "");
                              context
                                  .read<DashboardProvider>()
                                  .setIndex(1);
                            },
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
      },
    );
  }

  String _buildSubtitle(String? count) {
    final value = count ?? "0";
    return value == "1" ? "$value Product" : "$value Products";
  }
}
