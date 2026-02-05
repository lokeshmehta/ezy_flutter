import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'product_list_section.dart';

class BestSellersSection extends StatelessWidget {
  const BestSellersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.bestSellersResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = response.results!.where((i) => i != null).map((i) => i!).toList();

        return ProductListSection(
          title: "Best Sellers",
          items: items,
          onTap: (item) {
             // Navigation to Product Details
          },
          onAddToCart: (item) {},
          onFavorite: (item) {},
        );
      },
    );
  }
}

class NewArrivalsSection extends StatelessWidget {
  const NewArrivalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.newArrivalsResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = response.results!.where((i) => i != null).map((i) => i!).toList();

        return ProductListSection(
          title: "New Arrivals",
          items: items,
          onTap: (item) {},
          onAddToCart: (item) {},
          onFavorite: (item) {},
        );
      },
    );
  }
}

class HotSellingSection extends StatelessWidget {
  const HotSellingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.hotSellingResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = response.results!.where((i) => i != null).map((i) => i!).toList();

        return ProductListSection(
          title: "Hot Selling",
          items: items,
          onTap: (item) {},
          onAddToCart: (item) {},
          onFavorite: (item) {},
        );
      },
    );
  }
}

class RecentlyAddedSection extends StatelessWidget {
  const RecentlyAddedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.recentlyAddedResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = response.results!.where((i) => i != null).map((i) => i!).toList();

        return ProductListSection(
          title: "Recently Added",
          items: items,
          onTap: (item) {},
          onAddToCart: (item) {},
          onFavorite: (item) {},
        );
      },
    );
  }
}
