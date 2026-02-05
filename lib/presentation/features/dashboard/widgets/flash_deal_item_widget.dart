import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../data/models/home_models.dart';

class FlashDealItemWidget extends StatefulWidget {
  final ProductItem item;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;

  const FlashDealItemWidget({
    super.key,
    required this.item,
    required this.width,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
  });

  @override
  State<FlashDealItemWidget> createState() => _FlashDealItemWidgetState();
}

class _FlashDealItemWidgetState extends State<FlashDealItemWidget> {
  Timer? _timer;
  String days = "00";
  String hours = "00";
  String minutes = "00";
  String seconds = "00";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.item.toDate != null) {
          _calculateTimeRemaining(widget.item.toDate!);
      }
    });
  }

  void _calculateTimeRemaining(String toDateStr) {
     try {
       DateTime toDate = DateTime.parse(toDateStr); // Ensure format matches API
       DateTime now = DateTime.now();
       Duration diff = toDate.difference(now);

       if (diff.isNegative) {
          if (mounted) {
            setState(() {
               days = "00"; hours = "00"; minutes = "00"; seconds = "00";
            });
          }
          _timer?.cancel();
          return;
       }

       if (mounted) {
         setState(() {
           days = diff.inDays.toString().padLeft(2, '0');
           hours = (diff.inHours % 24).toString().padLeft(2, '0');
           minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
           seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
         });
       }
     } catch (e) {
       // Handle parse error
     }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Logic similar to ProductItemWidget but with Split layout
    final item = widget.item;
    final bool isOutOfStock = item.qtyStatus == "Out Of Stock";
    final bool canAddToCart = item.supplierAvailable == "1" && item.productAvailable == "1" && !isOutOfStock;

    final bool hasPromotion = item.promotionPrice != null && (double.tryParse(item.promotionPrice!) ?? 0) > 0;

    return Container(
      width: widget.width, // Usually wider than normal cards? Android uses match_parent in vertical list but inside dashboard it might be different.
      // FlashDealsProductsAdapter line 101 comment: width - 30. 
      // It seems mostly full width or large card.
      margin: EdgeInsets.only(right: 10.w, bottom: 5.h),
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.all(5.0.w),
            child: Row(
              children: [
                // Left Side (Image & Info) - Weight 0.52
                Expanded(
                  flex: 52,
                  child: Column(
                    children: [
                       SizedBox(
                         height: 110.h,
                         child: Stack(
                           children: [
                              Center(child: _buildImage(item.image)),
                              Positioned(
                                left: 5.w, top: 5.h,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                                  color: Colors.red,
                                  child: Text("Flash Deals", style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                ),
                              )
                           ],
                         ),
                       ),
                       SizedBox(height: 5.h),
                       
                       // Info
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            if (item.brandName != null)
                             Text(item.brandName!, style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                            Text(item.title ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp), maxLines: 2),
                            
                            // MOQ
                            if (item.minimumOrderQty != null && item.minimumOrderQty != "0")
                             Text("MOQ : ${item.minimumOrderQty}", style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                            
                            // Price
                            SizedBox(height: 5.h),
                            // Flash Deal Logic: often has promotion
                            if (hasPromotion) ...[
                               Text(_formatPrice(item.price), style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12.sp)),
                               Row(
                                 children: [
                                   Text(_formatPrice(item.promotionPrice), style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                                   SizedBox(width: 5.w),
                                   Container(color: Colors.red, padding: EdgeInsets.all(2.w), child: Text("-${_calculateDiscount(item.price, item.promotionPrice)}%", style: TextStyle(color: Colors.white, fontSize: 8.sp))),
                                 ],
                               )
                            ] else 
                               Text(_formatPrice(item.price), style: TextStyle(color: AppTheme.textColor, fontSize: 13.sp)),

                            // Add To Cart
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: canAddToCart ? widget.onAddToCart : null,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: canAddToCart ? AppTheme.tealColor : Colors.red,
                                        minimumSize: Size(0, 30.h)
                                    ),
                                    child: Text(isOutOfStock ? "Out Of Stock" : "Add To Cart", style: TextStyle(fontSize: 10.sp, color: Colors.white)),
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                InkWell(
                                  onTap: widget.onFavorite,
                                  child: Icon(item.isFavourite == "Yes" ? Icons.favorite : Icons.favorite_border, color: Colors.grey, size: 24.sp),
                                )
                              ],
                            )
                         ],
                       )
                    ],
                  ),
                ),
                
                // Right Side (Timer & Stock) - Weight 0.48
                SizedBox(width: 5.w),
                Expanded(
                  flex: 48,
                  child: Column(
                    children: [
                       // Sold As (Teal)
                       if (item.soldAs != null)
                        Container(
                          width: double.infinity,
                          color: AppTheme.tealColor,
                          padding: EdgeInsets.all(5.w),
                          child: Text(item.soldAs!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                        ),
                       SizedBox(height: 20.h),
                       
                       // Availability
                       Text("Availability :", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                       Text("${item.availableStockQty} In Stock", style: TextStyle(color: AppTheme.tealColor, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                       
                       SizedBox(height: 10.h),
                       Text("Hurry Up!\nOffers ends in :", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                       
                       // Timer
                       SizedBox(height: 10.h),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         children: [
                            _buildTimerBox(days, "DAYS"),
                            _buildTimerBox(hours, "HOURS"),
                            _buildTimerBox(minutes, "MINS"),
                            _buildTimerBox(seconds, "SEC"),
                         ],
                       )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBox(String value, String label) {
    return Column(
      children: [
        Text("$value :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
        Text(label, style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
      ],
    );
  }

  String _formatPrice(String? price) {
    if (price == null) return "\$0.00";
    double? p = double.tryParse(price);
    if (p == null) return "\$0.00";
    return "\$${p.toStringAsFixed(2)}";
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
        fit: BoxFit.contain, 
        cacheManager: ImageCacheManager(),
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
      );
  }
}
