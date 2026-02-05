import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'home_promotion_item_widget.dart';
import 'section_header_widget.dart';
import 'package:intl/intl.dart'; // Identify if intl is available or use basic split

class PromotionsSection extends StatefulWidget {
  const PromotionsSection({super.key});

  @override
  State<PromotionsSection> createState() => _PromotionsSectionState();
}

class _PromotionsSectionState extends State<PromotionsSection> {
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

  String _formatDate(String? dateStr) {
     if (dateStr == null || dateStr.isEmpty) return "";
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

        final promotions = response.results!;
        final double width = MediaQuery.of(context).size.width;
        final double cardWidth = (width / 2) - 30;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Promotions",
              onPrevTap: () => _scroll(false),
              onNextTap: () => _scroll(true),
            ),
            SizedBox(
              height: 200, // 120 image + text + shop now
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                scrollDirection: Axis.horizontal,
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                   final item = promotions[index];
                   if (item == null) return const SizedBox.shrink();

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
