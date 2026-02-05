import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'flash_deal_item_widget.dart';
import 'section_header_widget.dart';

class FlashDealsSection extends StatefulWidget {
  const FlashDealsSection({super.key});

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  final ScrollController _scrollController = ScrollController();

  void _scroll(bool forward) {
    if (!_scrollController.hasClients) return;
    const double scrollAmount = 300;
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
        final response = provider.flashDealsResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final products = response.results!;
        final double width = MediaQuery.of(context).size.width;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Flash Deals",
              onPrevTap: () => _scroll(false),
              onNextTap: () => _scroll(true),
            ),
            SizedBox(
              height: 230, // Large enough for FlashDealItemWidget
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                   final item = products[index];
                   if (item == null) return const SizedBox.shrink();

                   return FlashDealItemWidget(
                     item: item,
                     width: width - 40,
                     onTap: () {
                        // Navigate to Product Details
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
