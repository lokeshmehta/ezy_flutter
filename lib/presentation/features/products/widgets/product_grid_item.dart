import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../data/models/home_models.dart';
import '../product_details_screen.dart';

class ProductGridItem extends StatefulWidget {
  final ProductItem item;
  final VoidCallback? onTap;
  final Function(int qty)? onAddToCart;
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
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem> {
  late int _quantity;
  late int _minQty;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _minQty = int.tryParse(widget.item.minimumOrderQty ?? "1") ?? 1;
    if (_minQty < 1) _minQty = 1;
    _quantity = _minQty;
    _qtyController = TextEditingController(text: _quantity.toString());
  }

  void _incrementQty() {
    setState(() {
      _quantity++;
      _qtyController.text = _quantity.toString();
    });
  }

  void _decrementQty() {
    if (_quantity > _minQty) {
      setState(() {
        _quantity--;
        _qtyController.text = _quantity.toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Minimum Quantity Should be $_minQty"), 
        duration: const Duration(seconds: 1),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = widget.item.qtyStatus == "Out Of Stock";
    final bool canAddToCart = widget.item.supplierAvailable == "1" && widget.item.productAvailable == "1" && !isOutOfStock;
    final bool hasPromotion = widget.item.promotionPrice != null && double.tryParse(widget.item.promotionPrice ?? "0")! > 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.all(2.w),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: InkWell(
          onTap: widget.onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(productId: widget.item.productId!),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sold As
              if (widget.showSoldAs && widget.item.soldAs != null && widget.item.soldAs!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  decoration: const BoxDecoration(
                    color: AppTheme.tealColor,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.item.soldAs == "Each" 
                        ? "Each" 
                        : "${widget.item.soldAs} (${widget.item.qtyPerOuter} Units)",
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),

              // Image & Tag
              Stack(
                children: [
                   Container(
                     height: 110.h,
                     width: double.infinity,
                     alignment: Alignment.center,
                     child: CachedNetworkImage(
                        imageUrl: _getImageUrl(widget.item.image),
                        fit: BoxFit.contain,
                        cacheManager: ImageCacheManager(),
                        placeholder: (context, url) => Container(color: Colors.grey[100]),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                     ),
                   ),
                   if (widget.item.label != null && widget.item.label!.isNotEmpty)
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
                           widget.item.label!,
                           style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                         ),
                       ),
                     ),
                ],
              ),

              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor
                    SizedBox(height: 5.h),
                    Text(
                      widget.item.brandName ?? "",
                      style: TextStyle(color: AppTheme.darkerGrayColor, fontSize: 11.sp , fontWeight: FontWeight.w800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Title
                    SizedBox(height: 2.h),
                    Text(
                      widget.item.title ?? "",
                      style: TextStyle(color: AppTheme.textColor, fontSize: 12.sp, fontWeight: FontWeight.w800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // MOQ
                    if (widget.item.minimumOrderQty != null && widget.item.minimumOrderQty != "0" && widget.item.minimumOrderQty != "1")
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          "MOQ : ${widget.item.minimumOrderQty}",
                          style: TextStyle(color: AppTheme.redColor, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),

                    // Price Section
                    SizedBox(height: 5.h),
                    if (!hasPromotion)
                      Text(
                        _formatPrice(widget.item.price),
                        style: TextStyle(color: AppTheme.darkerGrayColor, fontSize: 12.sp, fontWeight: FontWeight.w800),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                               Text(
                                 _formatPrice(widget.item.price), // Original Price (Was)
                                 style: TextStyle(
                                   color: AppTheme.darkerGrayColor, 
                                   fontSize: 12.sp,
                                   decoration: TextDecoration.lineThrough
                                 ),
                               ),
                               SizedBox(width: 5.w),
                               Text(
                                 _formatPrice(widget.item.promotionPrice), // Promo Price (Now)
                                 style: TextStyle(color: AppTheme.primaryColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
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
                              "-${_calculateDiscount(widget.item.price, widget.item.promotionPrice)}%",
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
                child: Column(
                  children: [
                    // Quantity Control
                    /*if (canAddToCart)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
                        ),
                        margin: EdgeInsets.only(bottom: 5.h), // Spacing below quantity
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: _decrementQty,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                                child: Icon(Icons.remove, size: 16.sp, color: Colors.grey[600]),
                              ),
                            ),
                            Text(
                               _quantity.toString(),
                               style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: _incrementQty,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                                child: Icon(Icons.add, size: 16.sp, color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),*/

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: canAddToCart && widget.onAddToCart != null
                                 ? () => widget.onAddToCart!(_quantity)
                                 : null,
                            child: Container(
                              height: 35.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: canAddToCart ? AppTheme.tealColor : AppTheme.redColor,
                                borderRadius: BorderRadius.circular(AppTheme.productButtonRadius.r),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                   isOutOfStock
                                      ? "Out Of Stock"
                                      : (widget.item.addedToCart == "Yes"
                                          ? "Update Cart" // Shortened for Grid
                                          : "Add To Cart"), // Shortened for Grid
                                   style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        InkWell(
                          onTap: widget.onFavorite,
                          child: Image.asset(
                            widget.item.isFavourite == "Yes" ? "assets/images/favadded.png" : "assets/images/fav_new.png",
                            width: 30.h,
                            height: 30.h,
                          ),
                        ),
                      ],
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
