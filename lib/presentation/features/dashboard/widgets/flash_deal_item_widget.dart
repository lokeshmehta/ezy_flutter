import 'dart:async';
import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.only(right: 10, bottom: 5),
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                // Left Side (Image & Info) - Weight 0.52
                Expanded(
                  flex: 52,
                  child: Column(
                    children: [
                       SizedBox(
                         height: 110,
                         child: Stack(
                           children: [
                              Center(child: _buildImage(item.image)),
                              Positioned(
                                left: 5, top: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                  color: Colors.red,
                                  child: const Text("Flash Deals", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              )
                           ],
                         ),
                       ),
                       const SizedBox(height: 5),
                       
                       // Info
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            if (item.brandName != null)
                             Text(item.brandName!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            Text(item.title ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2),
                            
                            // MOQ
                            if (item.minimumOrderQty != null && item.minimumOrderQty != "0")
                             Text("MOQ : ${item.minimumOrderQty}", style: const TextStyle(color: Colors.red, fontSize: 12)),
                            
                            // Price
                            const SizedBox(height: 5),
                            // Flash Deal Logic: often has promotion
                            if (hasPromotion) ...[
                               Text(_formatPrice(item.price), style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                               Row(
                                 children: [
                                   Text(_formatPrice(item.promotionPrice), style: const TextStyle(color: Colors.red, fontSize: 12)),
                                   const SizedBox(width: 5),
                                   Container(color: Colors.red, padding: const EdgeInsets.all(2), child: Text("-${_calculateDiscount(item.price, item.promotionPrice)}%", style: const TextStyle(color: Colors.white, fontSize: 8))),
                                 ],
                               )
                            ] else 
                               Text(_formatPrice(item.price), style: const TextStyle(color: AppTheme.textColor, fontSize: 13)),

                            // Add To Cart
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: canAddToCart ? widget.onAddToCart : null,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: canAddToCart ? AppTheme.tealColor : Colors.red,
                                        minimumSize: const Size(0, 30)
                                    ),
                                    child: Text(isOutOfStock ? "Out Of Stock" : "Add To Cart", style: const TextStyle(fontSize: 10, color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: widget.onFavorite,
                                  child: Icon(item.isFavourite == "Yes" ? Icons.favorite : Icons.favorite_border, color: Colors.grey),
                                )
                              ],
                            )
                         ],
                       )
                    ],
                  ),
                ),
                
                // Right Side (Timer & Stock) - Weight 0.48
                const SizedBox(width: 5),
                Expanded(
                  flex: 48,
                  child: Column(
                    children: [
                       // Sold As (Teal)
                       if (item.soldAs != null)
                        Container(
                          width: double.infinity,
                          color: AppTheme.tealColor,
                          padding: const EdgeInsets.all(5),
                          child: Text(item.soldAs!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                       const SizedBox(height: 20),
                       
                       // Availability
                       const Text("Availability :", style: TextStyle(color: Colors.grey, fontSize: 14)),
                       Text("${item.availableStockQty} In Stock", style: const TextStyle(color: AppTheme.tealColor, fontSize: 14, fontWeight: FontWeight.bold)),
                       
                       const SizedBox(height: 10),
                       const Text("Hurry Up!\nOffers ends in :", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                       
                       // Timer
                       const SizedBox(height: 10),
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
        Text("$value :", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
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
