import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'dashboard_banner_item_widget.dart';

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
            // Header? Android does not show header for Popular Ads, it just shows list?
            // DashboardActivity.kt: Line 1851: updatelist("Popular Ads")
            // updatelist sets adapter.
            // XML: popularAdsRv.
            // No header visible in layout_dashboard.xml for popularAdsRv explicitly?
            // Actually, there is `popular_ads_lay` which contains `popularAdsRv`.
            // Does it have a header?
            // Checking activity_dashboard.xml...
            // Lay 1160: popularAdsRv inside LinearLayout. No TextView header nearby.
            // BannerslistAdapter sets "Popular Ads" as tagline? No, BannerslistAdapter is simple.
            // BannerslistAdapter_two (Suppliers) has "Supplier Logos".
            // Popular ads usually just banners.
            // I will omit header unless verification shows otherwise.
            
            SizedBox(
              height: 220, 
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                   final item = items[index];
                   if (item == null) return const SizedBox.shrink();

                   return DashboardBannerItemWidget(
                     item: item,
                     onTap: () {
                        // Handled in widget or here
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
