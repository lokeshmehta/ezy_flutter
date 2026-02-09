import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../data/models/home_models.dart';
import '../../products/product_details_screen.dart';

class ProductItemWidget extends StatelessWidget {
  final ProductItem item;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;

  const ProductItemWidget({
    super.key,
    required this.item,
    required this.width,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.badgeLabel,
  });

  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    // Logic from FutureProductsAdapter.kt

    // Sold As Logic
    // TODO: Need access to DashboardProvider or passing 'show_sold_as' flag. 
    // For now assuming show_sold_as is false or handled elsewhere, or I can check item fields if they exist.
    // Android checks DashboardViewModel.getUpResponse?.value?.results?.get(0)?.show_sold_as == "Yes"
    
    final bool isOutOfStock = item.qtyStatus == "Out Of Stock";
    final bool canAddToCart = item.supplierAvailable == "1" && item.productAvailable == "1" && !isOutOfStock;
    final bool hasPromotion = item.promotionPrice != null && double.tryParse(item.promotionPrice ?? "0")! > 0;
    
    // Vendor Visibility: 
    // Android: if category is Promotions/Pop Cat -> GONE. 
    // But this widget is mostly for standard products. Passing visibility might be cleaner, but let's default to visible.
    
    return Container(
      width: width,
      margin: EdgeInsets.only(right: 4.w, bottom: 4.h), // Matched android:layout_marginRight/Bottom="@dimen/dimen_4"
      child: Card(
        elevation: 1,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.r),
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
            padding: EdgeInsets.all(5.0.w), // cardView padding="@dimen/dimens_5"
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unit Header (Orange Bar)
                if (item.soldAs != null && item.soldAs!.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(bottom: 5.h), // layout_marginBottom="@dimen/dimens_5"
                     child: Container(
                       width: double.infinity,
                       height: 24.h,
                       decoration: BoxDecoration(
                          color: AppTheme.tealColor,
                          borderRadius: BorderRadius.circular(3.r), // Standardized with edittext_bg radius
                       ),
                       alignment: Alignment.center,
                       child: Text(
                         (item.soldAs == "Each") ? "Each" : "${item.soldAs} (${item.qtyPerOuter ?? "0"} Units)",
                         style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                       ),
                     ),
                   ),

                // Image Layer
                Stack(
                  children: [
                     Container(
                        height: 110.h, // Matched @dimen/dimen_110
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: _buildImage(item.image),
                     ),
                     // Status Badge (Top Left)
                     if (badgeLabel != null && badgeLabel!.isNotEmpty)
                       Positioned(
                         top: 5.h, // Match Kotlin layout_marginTop/marginLeft 5dp
                         left: 5.w,
                         child: Container(
                           padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                           decoration: BoxDecoration(
                             color: AppTheme.redColor,
                             borderRadius: BorderRadius.circular(3.r), // Matched edittext_bg radius
                           ),
                           child: Text(
                             badgeLabel!,
                             style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                           ),
                         ),
                       ),
                  ],
                ),

                // Content Area (Fixed Height or alignment)
                SizedBox(height: 4.h), // layout_marginTop="@dimen/dimen_4"

                // Vendor Name
                if (item.brandName != null && item.brandName!.isNotEmpty)
                  Text(
                    item.brandName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.darkGreyColor, fontSize: 12.sp), // hint_size12=12sp
                  ),

                // Product Name
                SizedBox(height: 2.h), // layout_marginTop="@dimen/dimen_2"
                Text(
                  item.title ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppTheme.textColor, 
                      fontSize: 13.sp, // _13sdp
                      fontWeight: FontWeight.bold
                  ),
                ),

                // MOQ
                if (item.minimumOrderQty != null && item.minimumOrderQty != "0" && item.minimumOrderQty != "1")
                   Padding(
                     padding: EdgeInsets.only(top: 10.h), // layout_marginTop="@dimen/top_10"
                     child: Text(
                       "MOQ : ${item.minimumOrderQty}",
                       style: TextStyle(color: AppTheme.redColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
                     ),
                   ),

                // Price Section
                SizedBox(height: 2.h), // layout_marginTop="@dimen/dimen_2"
                if (!hasPromotion) ...[
                   Text(
                     _formatPrice(item.price),
                     style: TextStyle(color: AppTheme.darkGreyColor, fontSize: 14.sp), // _14sdp
                   ),
                ] else ...[
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         _formatPrice(item.price),
                         style: TextStyle(
                           color: AppTheme.darkGreyColor, 
                           fontSize: 14.sp, // _14sdp
                           decoration: TextDecoration.lineThrough
                         ),
                       ),
                       SizedBox(height: 2.h),
                       Row(
                         children: [
                           Text(
                             _formatPrice(item.promotionPrice),
                             style: TextStyle(color: AppTheme.lightBlue, fontSize: 14.sp, fontWeight: FontWeight.bold), // @color/blue
                           ),
                           SizedBox(width: 5.w),
                           Container(
                             padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                             decoration: BoxDecoration(
                               color: AppTheme.redColor,
                               borderRadius: BorderRadius.circular(3.r),
                             ),
                             child: Text(
                               "-${_calculateDiscount(item.price, item.promotionPrice)}%",
                               style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                             ),
                           )
                         ],
                       )
                     ],
                   ),
                ],
                
                const Spacer(),

                // Add To Cart & Fav
                Padding(
                  padding: EdgeInsets.only(bottom: 5.h), // layout_marginBottom="@dimen/dimens_5"
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: canAddToCart ? onAddToCart : null,
                        child: Container(
                          width: 110.w, // layout_width="@dimen/dimen_110"
                          height: 35.h, // layout_height="@dimen/dimen_35"
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: canAddToCart ? AppTheme.tealColor : AppTheme.redColor,
                            borderRadius: BorderRadius.circular(20.r), // graybg.xml radius 20dp
                          ),
                          child: Text(
                             isOutOfStock 
                                 ? "Out Of Stock" 
                                 : (item.addedToCart == "Yes" 
                                     ? "Update Cart [${item.addedQty ?? '1'}]" 
                                     : "Add To Cart"),
                             style: TextStyle(
                               fontSize: 12.sp, // padding_12
                               color: Colors.white, 
                               fontWeight: FontWeight.bold
                             ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w), // layout_marginLeft="@dimen/top_10"
                      InkWell(
                        onTap: onFavorite,
                        child: Image.asset(
                          item.isFavourite == "Yes" ? "assets/images/favadded.png" : "assets/images/fav_new.png",
                          width: 35.h, // Matched height @dimen/dimen_35
                          height: 35.h,
                        ),
                      )
                    ],
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
        fit: BoxFit.contain, // scaleType="fitCenter"
        cacheManager: ImageCacheManager(),
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
      );
  }
}
