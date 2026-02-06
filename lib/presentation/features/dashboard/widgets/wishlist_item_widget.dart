import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../data/models/home_models.dart';
import '../../products/product_details_screen.dart';

class WishlistItemWidget extends StatelessWidget {
  final ProductItem item;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onDelete;
  final bool isSelected;
  final VoidCallback? onSelect;
  final String? categoryName;

  const WishlistItemWidget({
    super.key,
    required this.item,
    required this.width,
    this.onTap,
    this.onAddToCart,
    this.onDelete,
    this.isSelected = false,
    this.onSelect,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    // Logic Parity with Android Fav_ProductslistAdapter.kt
    
    final bool isOutOfStock = item.qtyStatus == "Out Of Stock";
    final bool canAddToCart = item.supplierAvailable == "1" && item.productAvailable == "1" && !isOutOfStock;
    final bool hasPromotion = item.promotionPrice != null && double.tryParse(item.promotionPrice ?? "0")! > 0;
    
    // Determine category name to display (Parity: Show if 'All' categories selected)
    // For now, allow it to be passed in or just show it if available.
    // Provider logic handles filtering, but Widget might need to know "current context".
    // Android shows it if `favCategoty == ""`
    
    return Container(
      width: width,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), // List spacing
      child: Card(
        elevation: 1,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.r), 
        ),
        child: InkWell(
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(productId: item.productId!),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // 1. Checkbox
                     // Using a custom container to match look or standard Checkbox
                     SizedBox(
                       width: 24.w,
                       height: 24.w,
                       child: Checkbox(
                         value: isSelected, 
                         onChanged: (val) {
                            if (onSelect != null) onSelect!();
                         },
                         activeColor: AppTheme.primaryColor,
                         side: BorderSide(color: Colors.grey, width: 1.5),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                       ),
                     ),
                     SizedBox(width: 8.w),

                     // 2. Image
                     Container(
                        height: 80.h,
                        width: 80.w,
                        alignment: Alignment.center,
                        child: _buildImage(item.image),
                     ),
                     SizedBox(width: 10.w),

                     // 3. Details Column
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Text(
                              item.brandName ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.title ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppTheme.textColor, 
                                  fontSize: 13.sp, 
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 5.h),
                             // Price Section
                            if (!hasPromotion) ...[
                               Text(
                                 _formatPrice(item.price),
                                 style: TextStyle(color: AppTheme.textColor, fontSize: 12.sp),
                               ),
                            ] else ...[
                               // Formatting for promo
                               Row(
                                 children: [
                                   Text(
                                     _formatPrice(item.price),
                                     style: TextStyle(
                                       color: Colors.grey, 
                                       fontSize: 12.sp,
                                       decoration: TextDecoration.lineThrough
                                     ),
                                   ),
                                   SizedBox(width: 5.w),
                                   Text(
                                     _formatPrice(item.promotionPrice),
                                     style: TextStyle(color: AppTheme.redColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                   ),
                                 ],
                               )
                            ],
                         ],
                       ),
                     ),
                     
                     // 4. Delete Icon (Heart Red)
                     InkWell(
                        onTap: onDelete,
                        child: Padding(
                          padding: EdgeInsets.all(5.w),
                          child: Icon(
                            Icons.favorite, // Filled Red Heart logic
                            color: AppTheme.redColor,
                            size: 24.sp,
                          ),
                        ),
                     )
                  ],
                ),
                
                SizedBox(height: 10.h),
                
                // Bottom Row: Button & Category Name
                Row(
                   children: [
                      // Button
                      InkWell(
                        onTap: canAddToCart ? onAddToCart : null,
                        child: Container(
                          height: 32.h,
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: canAddToCart ? AppTheme.orangeColor : AppTheme.redColorOpacity50,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                               BoxShadow(
                                 color: AppTheme.shadowBlack,
                                 blurRadius: 4,
                                 offset: Offset(0, 2)
                               )
                            ]
                          ),
                          child: Text(
                             isOutOfStock 
                                 ? "Out Of Stock" 
                                 : (item.addedToCart == "Yes" 
                                     ? "Update Cart [${item.addedQty ?? '1'}]" 
                                     : "Add To Cart"),
                             style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                   ],
                ),
                if (categoryName != null && categoryName!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 5.h),
                     child: Text(
                       "[$categoryName]",
                       style: TextStyle(color: Colors.black, fontSize: 11.sp, fontWeight: FontWeight.bold),
                     ),
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(String? price) {
    if (price == null) return "AUD 0.00";
    double? p = double.tryParse(price);
    if (p == null) return "AUD 0.00";
    return "AUD ${p.toStringAsFixed(2)}";
  }


  Widget _buildImage(String? path) {
      if (path == null || path.isEmpty) {
        return Container(color: Colors.grey[200]);
      }
      String finalUrl = path;
      if (!path.startsWith("http")) {
          finalUrl = "${UrlApiKey.mainUrl}$path";
      }

      return CachedNetworkImage(
        imageUrl: finalUrl,
        height: 120.h,
        fit: BoxFit.contain, 
        cacheManager: ImageCacheManager(),
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
      );
  }
}
