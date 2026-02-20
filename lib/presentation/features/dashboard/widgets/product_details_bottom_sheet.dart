import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/utils/common_methods.dart';
import '../../../../data/models/home_models.dart';
import '../../../providers/dashboard_provider.dart';
import 'cart_success_dialog.dart';


class ProductDetailsBottomSheet extends StatefulWidget {
  final ProductItem product;
  final String? badgeLabel;

  const ProductDetailsBottomSheet({
    super.key,
    required this.product,
    this.badgeLabel,
  });

  @override
  State<ProductDetailsBottomSheet> createState() =>
      _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  late String _selectedSoldAs;
  late double _currentPrice;
  late double _currentPromoPrice;

  int _quantity = 0;
  List<String> _soldAsOptions = [];

  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Initialize defaults
    // Logic: If orderedAs is set, try to match it.
    // Build options dynamically
    String qtyPerOuter = widget.product.qtyPerOuter ?? "1";
    _soldAsOptions = ["Each"];
    if (widget.product.qtyPerOuter != null && int.parse(qtyPerOuter) > 1) {
      _soldAsOptions.add("Carton ($qtyPerOuter Units)");
    }

    if (widget.product.addedToCart == "Yes") {
      _selectedSoldAs = widget.product.orderedAs ?? "Each";
    } else {
      _selectedSoldAs = "Each";
    }

    // Handle case where orderedAs might be just "Carton" but we display "Carton (x Units)"
    // Or map back/forth.
    if (_selectedSoldAs == "Carton") {
      // Find the option that contains Carton
      final cartonOption = _soldAsOptions
          .firstWhere((e) => e.startsWith("Carton"), orElse: () => "Each");
      _selectedSoldAs = cartonOption;
    }

    _calculatePrices();

    // Initialize Quantity
    int minQty = int.tryParse(widget.product.minimumOrderQty ?? "0") ?? 1;
    if (minQty == 0) minQty = 1;

    if (widget.product.addedToCart == "Yes") {
      _quantity = int.tryParse(widget.product.addedQty ?? "0") ?? 0;
    } else {
      _quantity = minQty;
    }
    
    // Ensure quantity is valid wrt min
    if (_quantity < minQty) _quantity = minQty;

    int initialItem = _quantity - minQty;
    if (initialItem < 0) initialItem = 0;

    _scrollController = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _calculatePrices() {
    double basePrice = double.tryParse(widget.product.price ?? "0") ?? 0;
    double basePromo =
        double.tryParse(widget.product.promotionPrice ?? "0") ?? 0;

    // Always show Unit Price as per native behavior
    _currentPrice = basePrice;
    _currentPromoPrice = basePromo;
  }

  @override
  Widget build(BuildContext context) {
    // Check show_sold_as from provider?
    final provider = context.watch<DashboardProvider>();
    // Assuming provider has response accessible or passed down.
    // Android checks DashboardViewModel.getUpResponse.
    // I'll stick to local logic for now based on Item.

    final bool hasPromotion = widget.product.hasPromotion == "Yes" ||
        (double.tryParse(widget.product.promotionPrice ?? "0") ?? 0) > 0;
    final bool isAdded = widget.product.addedToCart == "Yes";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(0.r)), // Match rounded top
      ),
      padding: EdgeInsets.all(15.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Product Details",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800),

              ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.cancel, color: Colors.black, size: 28.sp),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h,),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Badge + Sold As Strip
              Stack(
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.image?.startsWith("http") == true
                          ? widget.product.image!
                          : "${UrlApiKey.mainUrl}${widget.product.image}",
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                  // Status Badge
                  if (widget.badgeLabel != null && widget.badgeLabel!.isNotEmpty)
                    Positioned(
                      top: 5.h,
                      left: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.redColor,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          widget.badgeLabel!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 10.w),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sold As Strip (Moved here)
                    if (widget.product.soldAs != null &&
                        widget.product.soldAs != "Each" &&
                        widget.product.qtyPerOuter != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 5.h),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(0.r),
                        ),
                        child: Text(
                          "${widget.product.soldAs} (${widget.product.qtyPerOuter} Units)",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    // Tag
                   /* if (widget.product.divisionId != null) // Tag check generic
                      Text(
                        CommonMethods.decodeHtmlEntities(
                            widget.product.divisionId!),
                        // Using division as category placeholder? Android uses category field which I might not have mapped fully in ProductItem logic but is in response.
                        style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                      ),*/

                    Text(
                      CommonMethods.decodeHtmlEntities(
                          widget.product.brandName),
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp,fontWeight: FontWeight.w800) ,
                    ),
                    Text(
                      CommonMethods.decodeHtmlEntities(widget.product.title),
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp),
                      maxLines: 2,
                    ),

                    SizedBox(height: 5.h),

                    // Prices
                    if (hasPromotion) ...[
                      Text(
                        "AUD ${_currentPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 13.sp),
                      ),
                      Row(
                        children: [
                          Text(
                            "AUD ${_currentPromoPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppTheme.redColor,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                            child: Text(
                              "-${_calculateDiscount(_currentPrice, _currentPromoPrice)}%",
                              style: TextStyle(
                                  color: AppTheme.white, fontSize: 10.sp),
                            ),
                          )
                        ],
                      )
                    ] else
                      Text(
                        "AUD ${_currentPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold),
                      ),

                    SizedBox(height: 10.h),

                    // Dropdown / Sold As logic
                    if (widget.product.soldAs == "Each" &&
                        (widget.product.qtyPerOuter != null))
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSoldAs,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.black54),
                            items: _soldAsOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedSoldAs = newValue;
                                  _calculatePrices();
                                });
                              }
                            },
                          ),
                        ),
                      )
                  ],
                ),
              )
            ],
          ),

          SizedBox(height: 15.h),

          // Min Qty / Stock (Keep below row) -> Actually min qty might be hidden based on screenshot, but let's keep it for logic.
          // Screenshot shows Quantity Picker immediately after.

          // Quantity Picker (Horizontal Snapping)
          // "Center auto select on scroll" -> PageView with viewportFraction (0.33)
          // "3 Digit Visible" -> Constrained width (e.g. 180)
          // Quantity Picker (Horizontal Wheel)
          // Rotated ListWheelScrollView for 3-item visible "Wheel" effect
          Container(
            width: double.infinity,
            height: 50.h,
            color: const Color(0xFFEEEEEE), // Grey Background
            child: Center(
              child: SizedBox(
              height: 50.h,
              width: 150.w, // Approx 3 items * 50 width
              child: RotatedBox(
                quarterTurns: -1,
                child: ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 50.w, // Visual Width of each item
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.002, // Subtle curve
                  diameterRatio: 1.5,
                  onSelectedItemChanged: (index) {
                     int minQty = int.tryParse(widget.product.minimumOrderQty ?? "0") ?? 1;
                     if (minQty == 0) minQty = 1;
                     int newQty = minQty + index;

                     if (newQty != _quantity) {
                        setState(() {
                           _quantity = newQty;
                        });
                     }
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 100,
                    builder: (context, index) {
                       int minQty = int.tryParse(widget.product.minimumOrderQty ?? "0") ?? 1;
                       if (minQty == 0) minQty = 1;
                       int val = minQty + index;

                       bool isSelected = val == _quantity;

                       return RotatedBox(
                         quarterTurns: 1,
                         child: Center(
                           child: Text(
                             "$val",
                             style: TextStyle(
                               fontSize: isSelected ? 24.sp : 18.sp,
                               color: isSelected ? AppTheme.primaryColor : Colors.grey[400],
                               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                             ),
                           ),
                         )
                       );
                    },
                  ),
                ),
              ),
            ),
              ),
            ),

          SizedBox(height: 20.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add/Update Cart Logic
                    // If validation passes
                    _addToCart(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // 👈 makes it rectangle
                    ),
                  ),
                  child: Text(
                    isAdded ? "Update Cart [$_quantity]" : "Add To Cart",
                    style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (isAdded) ...[
                SizedBox(width: 10.w),
                InkWell(
                    onTap: () {
                      provider.deleteCart(widget.product.productId!,
                          widget.product.brandId ?? "");
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppTheme.redColor,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child:
                          const Icon(Icons.delete, color: Colors.white),
                    ))
              ], // Closes the `if (isAdded) ...[` block
            ], // Closes the `Row`'s children list
          ),
          // Closes the `Row` widget
        ], // Closes the `Column`'s children list
      ), // Closes the `Column` widget
    ); // Closes the `return` statement
  }

  String _calculateDiscount(double price, double promo) {
    if (price == 0) return "0";
    return (((price - promo) / price) * 100).toInt().toString();
  }

  void _addToCart(BuildContext context) {
    final provider = context.read<DashboardProvider>();
    final profile = provider.profileResponse;
    final result =
        profile?.results?.isNotEmpty == true ? profile!.results![0] : null;

    if (result == null) return;

    int currentSupplierCount =
        int.tryParse(profile?.suppliersCount ?? "0") ?? 0;
    int maxSupplierCount = int.tryParse(
            result.maximumNumberOfSuppliersProductsForFreeShipping ?? "0") ??
        0;
    String currentSuppliers = profile?.suppliers ?? "";
    String productBrandId = widget.product.brandId ?? "";

    bool isSupplierInList = false;
    if (currentSuppliers.isNotEmpty) {
      List<String> supplierList = currentSuppliers.split(",");
      isSupplierInList = supplierList.contains(productBrandId);
    }

    String showShippingSegment = result.showShippingSegment ?? "";

    // Logic: If limit reached AND new supplier AND shipping segment enabled
    if (currentSupplierCount >= maxSupplierCount &&
        !isSupplierInList &&
        showShippingSegment == "Yes") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Additional Supplier Charge"),
          content: Text(result.customerMessageForAdditionalSuppliersCharge ??
              "Extra charges apply for additional suppliers."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performAddToCart(provider);
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      );
    } else {
      _performAddToCart(provider);
    }
  }

  Future<void> _performAddToCart(DashboardProvider provider) async {
    String cleanSoldAs =
        _selectedSoldAs.startsWith("Carton") ? "Carton" : "Each";

    bool success = false;
    bool isUpdate = widget.product.addedToCart == "Yes";

    // Fix: Ensure we send the correct price (Promo if valid, else Base)
    double priceToSend = _currentPromoPrice;
    if (priceToSend <= 0) {
      priceToSend = _currentPrice;
    }

    if (isUpdate) {
      success = await provider.updateCart(
          widget.product.productId!,
          _quantity.toString(),
          widget.product.brandId ?? "",
          priceToSend.toStringAsFixed(2),
          cleanSoldAs);
    } else {
      success = await provider.addToCart(
          widget.product.productId!,
          _quantity.toString(),
          priceToSend.toStringAsFixed(2),
          cleanSoldAs,
          widget.product.apiData ?? "",
          widget.product.brandId ?? "");
    }
    
    if (mounted) {
      Navigator.pop(context); // Close Bottom Sheet regardless (or only on success? usually on action)
      
      if (success) {
        showDialog(
          context: context,
          builder: (context) => CartSuccessDialog(
            productName: widget.product.title ?? "Product",
            isUpdate: isUpdate,
          ),
        );
      }
    }
  }
}
