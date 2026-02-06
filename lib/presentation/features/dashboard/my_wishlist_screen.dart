import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezy_orders_flutter/presentation/features/dashboard/widgets/wishlist_item_widget.dart';
import 'package:ezy_orders_flutter/presentation/features/dashboard/widgets/product_details_bottom_sheet.dart';
import 'package:ezy_orders_flutter/presentation/providers/dashboard_provider.dart';
import 'package:ezy_orders_flutter/data/models/wishlist_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "My Favourites", // Parity: Title Match
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isFetchingMyWishlist) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myWishlistItems.isEmpty && provider.myWishlistCategories.isEmpty) {
            return Center(
              child: Text(
                "No items in wishlist",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
               // Horizontal Categories List
               if (provider.myWishlistCategories.isNotEmpty)
                Container(
                  height: 40.h,
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemCount: provider.myWishlistCategories.length + 1, // +1 for "All"
                    itemBuilder: (context, index) {
                       String catName = "";
                       String catId = "";
                       
                       // "All" Tab
                       if (index == 0) {
                         catName = "All Items"; // Or a specific label if Android has one, e.g. "All"
                         catId = "";
                       } else {
                         final cat = provider.myWishlistCategories[index - 1];
                         catName = cat.categoryName ?? "Unknown";
                         catId = cat.categoryId?.toString() ?? "";
                       }

                       final isSelected = provider.selectedWishlistCategoryId == catId;

                       return InkWell(
                         onTap: () {
                           provider.setSelectedWishlistCategory(catId);
                         },
                         child: Container(
                           margin: EdgeInsets.only(right: 10.w),
                           padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                           decoration: BoxDecoration(
                             color: isSelected ? Colors.white : Colors.white, // In screenshot, selected looks like Outline button style logic in Adapter code?
                             // Adapter code: `binding.selectedFavLay.background=activity.resources.getDrawable(R.drawable.buttonbackground)` if selected (Blue?)
                             // Else `edittext_bg` (likely white with border).
                             // The screenshot shows text styles. Let's follow basic logic: Selected = Highlighted.
                             // Actually, let's stick to standard behavior:
                             // Selected: Primary Color BG, White Text
                             // Unselected: White BG, Primary Color Text, Border

                             borderRadius: BorderRadius.circular(4.r),
                             border: Border.all(
                               color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                               width: isSelected ? 2 : 1,
                             ),
                           ),
                           alignment: Alignment.center,
                           child: Text(
                             catName,
                             style: TextStyle(
                               color: isSelected ? AppTheme.primaryColor : Colors.black, // Matching Screenshot logic likely
                               fontSize: 12.sp,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       );
                    },
                  ),
                ),

              // Product List
              Expanded(
                child: provider.myWishlistItems.isEmpty
                    ? Center(
                        child: Text(
                          "No items in this category",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.myWishlistItems.length,
                        padding: EdgeInsets.only(bottom: 20.h),
                        itemBuilder: (context, index) {
                          final item = provider.myWishlistItems[index];

                          // Determine Category Name display logic for parity
                          String? displayCatName;
                          if (provider.selectedWishlistCategoryId.isEmpty) {
                             // Find category name for this item
                             try {
                               final cat = provider.myWishlistCategories.firstWhere(
                                 (c) => c.categoryId.toString() == item.wishlistCategoryId, 
                               );
                               displayCatName = cat.categoryName;
                             } catch (e) {
                               displayCatName = "";
                             }
                          } else {
                             // Android implementation hides it if category is selected.
                             displayCatName = null; 
                          }

                          return WishlistItemWidget(
                            item: item,
                            width: 1.sw, // Full width for list item
                            isSelected: provider.isWishlistItemSelected(item.wishlistId ?? ""),
                            categoryName: displayCatName,
                            
                            onSelect: () {
                               if (item.wishlistId != null) {
                                  provider.toggleWishlistItemSelection(item.wishlistId!);
                               }
                            },
                            
                            onDelete: () {
                              if (item.wishlistId != null) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Remove Item"),
                                    content: Text("Are you sure you want to delete ${item.title} from Wishlist?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          provider.deleteWishlistItem(item.wishlistId!);
                                        },
                                        child: const Text("Delete", style: TextStyle(color: AppTheme.redColor)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            
                            onAddToCart: () {
                                // Parity: Opens Bottom Sheet
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (ctx) => ProductDetailsBottomSheet(product: item),
                                ).then((_) {
                                    provider.fetchMyWishlist(); 
                                });
                            },
                            
                            onTap: () {
                               context.push('/product-details', extra: item);
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
}
