import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'home_promotion_item_widget.dart';
import 'section_header_widget.dart';

class PopularCategoriesSection extends StatelessWidget {
  const PopularCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.popularCategoriesResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Filtering based on count != 0 is done in Android (Activity Line 1187)
        // datalist.results.get(i)?.category_products_count!!.toString().equals("0") check
        final categories = response.results!.where((item) {
           return item != null && item.categoryProductsCount != "0";
        }).toList();

        if (categories.isEmpty) return const SizedBox.shrink();

        final double width = MediaQuery.of(context).size.width;
        final double cardWidth = (width / 2) - 30;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Popular Categories",
              onPrevTap: () {},
              onNextTap: () {},
            ),
            SizedBox(
              height: 200, 
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                     // Android maps group_level_1 to name (Activity Line 1192)
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
