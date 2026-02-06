import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/product_list_provider.dart';
import '../../products/products_list_screen.dart';
import 'dashboard_banner_item_widget.dart';
import 'section_header_widget.dart';

class PopularAdsSection extends StatelessWidget {
  const PopularAdsSection({super.key});

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
              showNavButtons: true, // Show arrows if more than 1
              onPrevTap: () {}, // Implement scroll logic if needed
              onNextTap: () {},
            ),
            SizedBox(
              height: 180.h, // Adjusted to match design
              child: ListView.builder(
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
