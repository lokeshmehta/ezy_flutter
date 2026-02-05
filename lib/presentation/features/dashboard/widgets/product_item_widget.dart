import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../data/models/home_models.dart';

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
  });

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
      margin: const EdgeInsets.only(right: 10, bottom: 5),
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sold As (Teal Banner)
                // Placeholder: If 'soldAs' exists and is relevant. 
                // Android uses a card view for this.
                if (item.soldAs != null && item.soldAs!.isNotEmpty)
                   Container(
                     width: double.infinity,
                     color: AppTheme.tealColor, // Needs AppTheme.tealColor
                     padding: const EdgeInsets.all(5),
                     margin: const EdgeInsets.only(bottom: 5),
                     child: Text(
                       item.soldAs!, // Complicated logic for units in Android
                       textAlign: TextAlign.center,
                       style: const TextStyle(color: Colors.white, fontSize: 12),
                     ),
                   ),

                // Image Layer (FrameLayout in Android)
                Stack(
                  children: [
                     Container(
                        height: 120,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: _buildImage(item.image),
                     ),
                     // Tagline (Top Right) "Hot Selling" etc.
                     // Android sets this dynamically based on category.
                     // We can pass `tagline` as param if needed. 
                  ],
                ),

                const SizedBox(height: 5),

                // Vendor Name
                if (item.brandName != null && item.brandName!.isNotEmpty)
                  Text(
                    item.brandName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),

                // Product Name
                const SizedBox(height: 2),
                Text(
                  item.title ?? item.brandName ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.textColor, 
                      fontSize: 13, 
                      fontWeight: FontWeight.bold
                  ),
                ),

                // MOQ
                if (item.minimumOrderQty != null && item.minimumOrderQty != "0" && item.minimumOrderQty != "1")
                   Padding(
                     padding: const EdgeInsets.only(top: 5),
                     child: Text(
                       "MOQ : ${item.minimumOrderQty}",
                       style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                     ),
                   ),

                const SizedBox(height: 5),

                // Price Section
                if (!hasPromotion) ...[
                   Text(
                     _formatPrice(item.price),
                     style: const TextStyle(color: AppTheme.textColor, fontSize: 12), // Use grey? Android uses 'darkgreycolor'
                   ),
                ] else ...[
                   // Promotion UI
                   Text(
                     _formatPrice(item.price),
                     style: const TextStyle(
                       color: Colors.grey, 
                       fontSize: 12,
                       decoration: TextDecoration.lineThrough
                     ),
                   ),
                   Row(
                     children: [
                       Text(
                         _formatPrice(item.promotionPrice),
                         style: const TextStyle(color: Colors.red, fontSize: 12),
                       ),
                       const SizedBox(width: 5),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                         color: Colors.red,
                         child: Text(
                           "-${_calculateDiscount(item.price, item.promotionPrice)}%",
                           style: const TextStyle(color: Colors.white, fontSize: 10),
                         ),
                       )
                     ],
                   )
                ],

                // Add To Cart & Fav
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Quantity Counter (Hidden by default in Android unless logic triggers? 
                    // Android layout has `dashCartLay` visibility gone by default, shown based on logic)
                    // For now, mirroring "Add To Cart" button.
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canAddToCart ? onAddToCart : null,
                        style: ElevatedButton.styleFrom(
                           backgroundColor: canAddToCart ? AppTheme.tealColor : Colors.red,
                           minimumSize: const Size(0, 30),
                           padding: const EdgeInsets.symmetric(horizontal: 5),
                        ),
                        child: Text(
                           isOutOfStock ? "Out Of Stock" : (item.addedToCart == "Yes" ? "Update Cart [${item.addedQty}]" : "Add To Cart"),
                           style: const TextStyle(fontSize: 11, color: Colors.white),
                           maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: onFavorite,
                      child: Icon(
                        item.isFavourite == "Yes" ? Icons.favorite : Icons.favorite_border,
                        color: Colors.grey, // Check Android tint
                        size: 24,
                      ),
                    )
                  ],
                ),
                
                // Shop Now (Hidden by default in FutureProducts except Pop Categories?)
                // Assuming this generic widget is for products.
              ],
            ),
          ),
        ),
      ),
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
        fit: BoxFit.contain, // scaleType="fitCenter"
        cacheManager: ImageCacheManager(),
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
      );
  }
}
