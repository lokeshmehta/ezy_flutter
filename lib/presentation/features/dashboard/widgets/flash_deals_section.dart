import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'flash_deal_item_widget.dart';
import 'section_header_widget.dart';

class FlashDealsSection extends StatelessWidget {
  const FlashDealsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.flashDealsResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = response.results!;
        final width = MediaQuery.of(context).size.width;
        // Flash Deals usually wider card? 
        // Adapter logic: ButtonWidth = width (full width?) 
        // Line 98: val width: Int = displaymetrics.widthPixels
        // Line 99: val buttonWidth = width
        // Line 102: params(buttonWidth - 30, ...)
        // So Flash Deals are FULL WIDTH cards (minus padding). Paging horizontal?
        // XML: flashDealsRv
        // It's likely a horizontal list of full-width cards, acting like a carousel/slider but user scrolls.
        
        final itemWidth = width - 30;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Flash Deals",
              onPrevTap: () {},
              onNextTap: () {},
            ),
            SizedBox(
              height: 180, // Estimate height
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                   final item = items[index];
                   if (item == null) return const SizedBox.shrink();

                   return FlashDealItemWidget(
                     item: item,
                     width: itemWidth,
                     onTap: () {},
                     onAddToCart: () {},
                     onFavorite: () {},
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
