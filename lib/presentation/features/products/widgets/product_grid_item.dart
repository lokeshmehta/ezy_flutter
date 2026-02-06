import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../data/models/home_models.dart';
import '../product_details_screen.dart';

class ProductGridItem extends StatelessWidget {
  final ProductItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final bool showSoldAs;

  const ProductGridItem({
    super.key,
    required this.item,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.showSoldAs = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = item.qtyStatus == "Out Of Stock";
    final bool canAddToCart = item.supplierAvailable == "1" && item.productAvailable == "1" && !isOutOfStock;
    final bool hasPromotion = item.promotionPrice != null && double.tryParse(item.promotionPrice ?? "0")! > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.all(2.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: InkWell(
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(productId: item.productId!),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sold As
              if (showSoldAs && item.soldAs != null && item.soldAs!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.tealColor,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.soldAs == "Each" 
                        ? "Each" 
                        : "${item.soldAs} (${item.qtyPerOuter} Units)",
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),

              // Image & Tag
              Stack(
                children: [
                   Container(
                     height: 120.h,
                     width: double.infinity,
                     alignment: Alignment.center,
                     child: CachedNetworkImage(
                        imageUrl: _getImageUrl(item.image),
                        fit: BoxFit.contain,
                        cacheManager: ImageCacheManager(),
                        placeholder: (context, url) => Container(color: Colors.grey[100]),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                     ),
                   ),
                   if (item.label != null && item.label!.isNotEmpty)
                     Positioned(
                       top: 5.h,
                       left: 5.w,
                       child: Container(
                         padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                         decoration: BoxDecoration(
                           color: AppTheme.redColor,
                           borderRadius: BorderRadius.circular(3.r),
                         ),
                         child: Text(
                           item.label!,
                           style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                         ),
                       ),
                     ),
                ],
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor
                    SizedBox(height: 5.h),
                    Text(
                      item.brandName ?? "",
                      style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Title
                    SizedBox(height: 2.h),
                    Text(
                      item.title ?? "",
                      style: TextStyle(color: AppTheme.textColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // MOQ
                    if (item.minimumOrderQty != null && item.minimumOrderQty != "0" && item.minimumOrderQty != "1")
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          "MOQ : ${item.minimumOrderQty}",
                          style: TextStyle(color: AppTheme.redColor, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),

                    // Price Section
                    SizedBox(height: 5.h),
                    if (!hasPromotion)
                      Text(
                        _formatPrice(item.price),
                        style: TextStyle(color: Colors.grey[700], fontSize: 12.sp),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppTheme.redColor,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                            child: Text(
                              "-${_calculateDiscount(item.price, item.promotionPrice)}%",
                              style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Actions
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: canAddToCart ? onAddToCart : null,
                        child: Container(
                          height: 40.h, // Standardized touch target
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: canAddToCart ? AppTheme.tealColor : AppTheme.redColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: FittedBox( // Prevent text overflow in button
                            fit: BoxFit.scaleDown,
                            child: Text(
                               isOutOfStock 
                                  ? "Out Of Stock" 
                                  : (item.addedToCart == "Yes" 
                                      ? "Update Cart [${item.addedQty ?? '1'}]" 
                                      : "Add To Cart"),
                               style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    InkWell(
                      onTap: onFavorite,
                      child: Image.asset(
                        item.isFavourite == "Yes" ? "assets/images/favadded.png" : "assets/images/fav_new.png",
                        width: 40.h, // Match button height
                        height: 40.h,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "${UrlApiKey.mainUrl}$path";
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
}
