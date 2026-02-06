import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'home_promotion_item_widget.dart';
import 'section_header_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; 

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
        final double cardWidth = (1.sw / 2) - 25.w;

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Promotions",
              onPrevTap: () => _scroll(false),
              onNextTap: () => _scroll(true),
            ),
            SizedBox(
              height: 240.h, // Dynamic height
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                scrollDirection: Axis.horizontal,
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                   final item = promotions[index];

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
