import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/wishlist_item_widget.dart';
import '../../../../data/models/home_models.dart';
import 'package:go_router/go_router.dart';

class MyWishlistScreen extends StatefulWidget {
  const MyWishlistScreen({super.key});

  @override
  State<MyWishlistScreen> createState() => _MyWishlistScreenState();
}

class _MyWishlistScreenState extends State<MyWishlistScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchMyWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match Android background
      appBar: AppBar(
        title: Text(
          "My Wishlist",
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
             IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Navigate to Search
            },
          ),
        ]
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isFetchingMyWishlist) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myWishlistItems.isEmpty) {
             return Center(
               child: Text("No items in wishlist", style: TextStyle(fontSize: 16.sp)),
             );
          }

          return Column(
            children: [
              // Categories List (Placeholder for now, or populate if we have global categories)
              // Android has a Horizontal RecyclerView for categories here.
              // For now, we focus on the product grid as per the main request.
              
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(5.w),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65, // Adjust as needed
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: provider.myWishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.myWishlistItems[index];
                    return WishlistItemWidget(
                      item: item,
                      width: double.infinity,
                      onTap: () {
                          // Go to Product Details
                          // Need to handle navigation properly
                      },
                      onAddToCart: () {
                         if (item.addedToCart == "Yes") {
                             // Update Cart Logic
                             provider.addToCart(
                               item.productId!, 
                               (int.parse(item.addedQty ?? "1") + 1).toString(), 
                               item.price!, 
                               item.orderedAs ?? "Each", 
                               item.apiData ?? "", 
                               item.brandId!
                             );
                         } else {
                             provider.addToCart(
                               item.productId!, 
                               "1", 
                               item.price!, 
                               item.orderedAs ?? "Each", 
                               item.apiData ?? "", 
                               item.brandId!
                             );
                         }
                      },
                      onDelete: () {
                          _showDeleteConfirmation(context, item);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ProductItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Item"),
        content: const Text("Are you sure you want to remove this item from wishlist?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
               Navigator.pop(ctx);
               if (item.wishlistId != null) {
                   context.read<DashboardProvider>().deleteWishlistItem(item.wishlistId!);
               }
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
