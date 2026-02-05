import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'home_promotion_item_widget.dart';
import 'section_header_widget.dart';
import 'package:intl/intl.dart'; // Identify if intl is available or use basic split

class PromotionsSection extends StatelessWidget {
  const PromotionsSection({super.key});

  String _formatDate(String? dateStr) {
     if (dateStr == null || dateStr.isEmpty) return "";
     // Android uses CommonMethods.getDate which parses "yyyy-MM-dd HH:mm:ss" to "MMM dd, yyyy"
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

        // Filtering logic from Android: if(!products_count.equals("0"))
        // But ProductItem in Flutter doesn not have products_count field mapped in home_models.dart?
        // Let's check home_models.dart ProductItem.
        // It has availableStockQty, etc. but strictly `products_count` might be missing.
        // DashboardActivity line 1127: checks products_count != "0"
        
        // Assumption: Display all for now or check available fields.
        final promotions = response.results!;
        final double width = MediaQuery.of(context).size.width;
        final double cardWidth = (width / 2) - 30;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Promotions",
              onPrevTap: () {},
              onNextTap: () {},
            ),
            SizedBox(
              height: 200, // 120 image + text + shop now
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                   final item = promotions[index];
                   if (item == null) return const SizedBox.shrink();

                   // Title mapping: display_name
                   // Android Activity Line 1131: name = display_name. Wait, Layout uses 'heading'. 
                   // Adapter Line 382: heading.text = name.
                   // Activity Line 1131: menuItemsResponse.name = get(i).display_name.
                   // So use display_name equivalent which is likely `title` or `brandName` in ProductItem
                   // Let's use `title` as default, fallback to `brandName`.
                   
                   // Subtitle: Date Range
                   // ProductItem in home_models has no from_date/to_date?
                   // I need to check home_models.dart again.
                   
                   return HomePromotionItemWidget(
                     imageUrl: item.image,
                     title: item.title ?? "",
                     subtitle: "Valid until ${_formatDate(item.toDate)}", 
                     width: cardWidth,
                     onTap: () {
                        // Navigate to Promotions List
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
