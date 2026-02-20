import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../../widgets/custom_loader_widget.dart';
import 'widgets/promotion_item_widget.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Determine page to fetch (1 if refreshing or initial)
    // Actually DashboardProvider has promotionPage state. 
    // We should probably reset to 1 when entering this screen if viewed as a "list"
    // But Dashboard uses the same response. 
    // Let's just fetch page 1 to be safe and ensure list is up to date.
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.fetchPromotions(page: 1);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      // Logic from Android: increment page and fetch
      // Android uses logic: if (loading) return; 
      // We need to check if we have more data. 
      // Provider does not seem to have max page info explicitly, usually result < count means end.
      // But typically we just try to fetch next page.
      provider.fetchPromotions(page: provider.promotionPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Promotions",
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pop(context);
          },
        ),
        actions: [
          // Cart Icon (Placeholder logic for now, matching Android visual)
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 24.sp),
                  // Count badge could represent cart count if available
                ],
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              final promotions = provider.promotionsResponse?.results;
              
              if (provider.isLoading && promotions == null) {
                return const SizedBox.shrink(); // Overlay handles it
              }

              if (promotions == null || promotions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        "No Promotions Available",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(10.w),
                itemCount: promotions.length + (provider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == promotions.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CustomLoaderWidget(size: 30.w)),
                    );
                  }
                  return PromotionItemWidget(item: promotions[index], index: index);
                },
              );
            },
          ),
          Consumer<DashboardProvider>(
             builder: (context, provider, child) {
                // Show overlay only if initial load (no data yet)
                // If data exists, we show pagination loader at bottom (handled above)
                // BUT if we want blocking overlay for refresh? 
                // Android typically blocks on initial load. Pagination is non-blocking.
                // Logic: if isLoading && promotions == null => Blocking Overlay
                // if isLoading && promotions != null => Pagination Loader (in list)
                
                if (provider.isLoading && provider.promotionsResponse?.results == null) {
                   return Container(
                      color: Colors.black54,
                      child: Center(
                        child: SizedBox(
                          width: 100.w,
                          height: 100.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                               CustomLoaderWidget(size: 100.w),
                               Text(
                                 "Please Wait",
                                 textAlign: TextAlign.center,
                                 style: TextStyle(
                                   color: AppTheme.primaryColor,
                                   fontSize: 13.sp,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                            ],
                          ),
                        ),
                      ),
                    );
                }
                return const SizedBox.shrink();
             },
          ),
        ],
      ),
    );
  }
}
