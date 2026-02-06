import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../data/models/home_models.dart';

class WishlistItemWidget extends StatelessWidget {
  final ProductItem item;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onDelete;

  const WishlistItemWidget({
    super.key,
    required this.item,
    required this.width,
    this.onTap,
    this.onAddToCart,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Logic Parity with Android Fav_ProductslistAdapter.kt
    
    final bool isOutOfStock = item.qtyStatus == "Out Of Stock";
    final bool canAddToCart = item.supplierAvailable == "1" && item.productAvailable == "1" && !isOutOfStock;
    final bool hasPromotion = item.promotionPrice != null && double.tryParse(item.promotionPrice ?? "0")! > 0;
    
    return Container(
      width: width,
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h), // Grid spacing
      child: Card(
        elevation: 1,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.r), 
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(5.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unit Header (Orange Bar)
                if (item.soldAs != null && item.soldAs!.isNotEmpty && item.soldAs != "Each" && item.qtyPerOuter != null)
                   Container(
                     width: double.infinity,
                     height: 24.h,
                     decoration: BoxDecoration(
                        color: AppTheme.orangeColor,
                     ),
                     alignment: Alignment.center,
                     child: Text(
                       "${item.soldAs} (${item.qtyPerOuter} Units)",
                       style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                     ),
                   )
                else if (item.soldAs == "Each")
                   Container(
                     width: double.infinity,
                     height: 24.h,
                     decoration: BoxDecoration(
                        color: AppTheme.orangeColor, 
                     ),
                     alignment: Alignment.center,
                     child: Text(
                       "Each",
                       style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                     ),
                   ),

                // Image Layer
                Stack(
                  children: [
                     Container(
                        height: 100.h,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: _buildImage(item.image),
                     ),
                     // No badges explicitly mentioned for Wishlist, but if they exist in item, we could show.
                     // Android adapter doesn't seem to show badges in wishlist usually, but parity suggests we keep it simple.
                  ],
                ),

                SizedBox(height: 5.h),

                // Vendor Name
                if (item.brandName != null && item.brandName!.isNotEmpty)
                  Text(
                    item.brandName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                  ),

                // Product Name
                SizedBox(height: 2.h),
                Text(
                  item.title ?? item.brandName ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppTheme.textColor, 
                      fontSize: 12.sp, 
                      fontWeight: FontWeight.bold
                  ),
                ),

                // MOQ
                if (item.minimumOrderQty != null && item.minimumOrderQty != "0" && item.minimumOrderQty != "1")
                   Padding(
                     padding: EdgeInsets.only(top: 5.h),
                     child: Text(
                       "MOQ : ${item.minimumOrderQty}",
                       style: TextStyle(color: AppTheme.redColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
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
                   Text(
                     _formatPrice(item.price),
                     style: TextStyle(
                       color: Colors.grey, 
                       fontSize: 12.sp,
                       decoration: TextDecoration.lineThrough
                     ),
                   ),
                   Row(
                     children: [
                       Text(
                         _formatPrice(item.promotionPrice),
                         style: TextStyle(color: AppTheme.redColor, fontSize: 12.sp),
                       ),
                       SizedBox(width: 5.w),
                       Container(
                         padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                         color: AppTheme.redColor,
                         child: Text(
                           "-${_calculateDiscount(item.price, item.promotionPrice)}%",
                           style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                         ),
                       )
                     ],
                   )
                ],
                
                SizedBox(height: 5.h),

                // Add To Cart & Delete
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: canAddToCart ? onAddToCart : null,
                        child: Container(
                          height: 30.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: canAddToCart ? AppTheme.tealColor : AppTheme.redColorOpacity50,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                             isOutOfStock 
                                 ? "Out Of Stock" 
                                 : (item.addedToCart == "Yes" 
                                     ? "Update Cart [${item.addedQty ?? '1'}]" 
                                     : "Add To Cart"),
                             style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline, // Trash icon for Wishlist
                        color: Colors.grey,
                        size: 22.sp,
                      ),
                    )
                  ],
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

  String _calculateDiscount(String? original, String? promo) {
     if (original == null || promo == null) return "0";
     double o = double.tryParse(original) ?? 0;
     double p = double.tryParse(promo) ?? 0;
     if (o == 0) return "0";
     int discount = (((o - p) / o) * 100).toInt();
     return discount.toString();
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
