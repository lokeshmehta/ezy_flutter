import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/product_list_provider.dart';
import 'dashboard_banner_item_widget.dart';
import 'section_header_widget.dart';

class PopularAdsSection extends StatefulWidget {
  const PopularAdsSection({super.key});

  @override
  State<PopularAdsSection> createState() => _PopularAdsSectionState();
}

class _PopularAdsSectionState extends State<PopularAdsSection> {
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
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.popularAdvertisementsResponse;

        if (response == null ||
            response.results == null ||
            response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = response.results!;
        final totalPages = items.length;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Popular Ads",
              onPrevTap:
              totalPages > 1 ? () => _goToPage(false, totalPages) : null,
              onNextTap:
              totalPages > 1 ? () => _goToPage(true, totalPages) : null,
            ),
            SizedBox(
              height: 180.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item == null) return const SizedBox.shrink();

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: DashboardBannerItemWidget(
                      item: item,
                      onTap: () {
                        if (item.brandid != null &&
                            item.brandid != "0") {
                          final productProvider =
                          context.read<ProductListProvider>();
                          productProvider.clearFilters();
                          productProvider.setSupplier(item.brandid!);

                          context
                              .read<DashboardProvider>()
                              .setIndex(1);
                        }
                      },
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
}

