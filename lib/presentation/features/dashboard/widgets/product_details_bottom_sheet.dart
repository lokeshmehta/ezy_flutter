import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../data/models/home_models.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../providers/dashboard_provider.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final ProductItem product;

  const ProductDetailsBottomSheet({super.key, required this.product});

  @override
  State<ProductDetailsBottomSheet> createState() => _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  late String _selectedSoldAs;
  late double _currentPrice;
  late double _currentPromoPrice;
  int _quantity = 0;
  final List<String> _soldAsOptions = ["Each", "Carton"]; // Verify correct values
  
  @override
  void initState() {
    super.initState();
    // Initialize defaults
    _selectedSoldAs = widget.product.orderedAs ?? "Each"; // Default to orderedAs
    
    // If spinner is needed (show_sold_as == "Yes" && sold_as == "Each")
    // For now assuming simplified logic or verify with provider
    
    _calculatePrices();
    
    // Initialize Quantity from Added Qty or Min Qty
    if (widget.product.addedToCart == "Yes") {
       _quantity = int.tryParse(widget.product.addedQty ?? "0") ?? 0;
    } else {
       _quantity = int.tryParse(widget.product.minimumOrderQty ?? "0") ?? 0;
       if (_quantity == 0) _quantity = 1; // Default min
    }
  }

  void _calculatePrices() {
    double basePrice = double.tryParse(widget.product.price ?? "0") ?? 0;
    double basePromo = double.tryParse(widget.product.promotionPrice ?? "0") ?? 0;
    
    int qtyPerOuter = int.tryParse(widget.product.qtyPerOuter ?? "1") ?? 1;

    // Logic from Android:
    // price = if (spinnerPosition == 0) basePrice else (qty_per_outer * basePrice)
    // Assuming Index 0 is "Each" and Index 1 is "Outer/Carton"
    
    if (_selectedSoldAs == "Each") {
       _currentPrice = basePrice;
       _currentPromoPrice = basePromo;
    } else {
       _currentPrice = basePrice * qtyPerOuter;
       _currentPromoPrice = basePromo * qtyPerOuter;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check show_sold_as from provider?
    final provider = context.watch<DashboardProvider>();
    // Assuming provider has response accessible or passed down. 
    // Android checks DashboardViewModel.getUpResponse. 
    // I'll stick to local logic for now based on Item.
    
    final bool hasPromotion = widget.product.hasPromotion == "Yes" || (double.tryParse(widget.product.promotionPrice ?? "0") ?? 0) > 0;
    final bool isAdded = widget.product.addedToCart == "Yes";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)), // Match rounded top
      ),
      padding: EdgeInsets.all(15.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Close Button
           Align(
             alignment: Alignment.topRight,
             child: InkWell(
               onTap: () => Navigator.pop(context),
               child: Icon(Icons.cancel, color: Colors.grey, size: 28.sp),
             ),
           ),
           
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Image
               Container(
                 width: 100.w,
                 height: 100.w,
                 decoration: BoxDecoration(
                   border: Border.all(color: Colors.grey[300]!),
                   borderRadius: BorderRadius.circular(10.r),
                 ),
                 child: CachedNetworkImage(
                    imageUrl: widget.product.image?.startsWith("http") == true 
                        ? widget.product.image! 
                        : "${UrlApiKey.mainUrl}${widget.product.image}",
                    fit: BoxFit.contain,
                    errorWidget: (_,__,___) => Icon(Icons.broken_image, color: Colors.grey),
                 ),
               ),
               SizedBox(width: 10.w),
               
               // Details
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      // Tag
                      if (widget.product.divisionId != null) // Tag check generic
                       Text(
                         widget.product.divisionId ?? "", // Using division as category placeholder? Android uses category field which I might not have mapped fully in ProductItem logic but is in response.
                         style: TextStyle(color: AppTheme.tealColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
                       ),
                         
                      Text(
                        widget.product.brandName ?? "",
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Text(
                        widget.product.title ?? "",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                        maxLines: 2,
                      ),
                      
                      SizedBox(height: 5.h),
                      // Prices
                      if (hasPromotion) ...[
                         Text(
                           "AUD ${_currentPrice.toStringAsFixed(2)}",
                           style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12.sp),
                         ),
                         Row(
                           children: [
                             Text(
                               "AUD ${_currentPromoPrice.toStringAsFixed(2)}",
                               style: TextStyle(color: AppTheme.redColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
                             ),
                             SizedBox(width: 5.w),
                             Container(
                               padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                               color: AppTheme.redColor,
                               child: Text(
                                 "-${_calculateDiscount(_currentPrice, _currentPromoPrice)}%",
                                 style: TextStyle(color: AppTheme.white, fontSize: 10.sp),
                               ),
                             )
                           ],
                         )
                      ] else 
                         Text(
                           "AUD ${_currentPrice.toStringAsFixed(2)}",
                           style: TextStyle(color: AppTheme.textColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
                         ),
                   ],
                 ),
               )
             ],
           ),
           
           SizedBox(height: 15.h),
           
           // Min Qty
           Text(
             "Minimum Order Quantity : ${widget.product.minimumOrderQty ?? "1"}",
             style: TextStyle(color: Colors.grey, fontSize: 12.sp),
           ),
           
           // In Stock
           Text(
             "In Stock : ${widget.product.availableStockQty ?? "0"}",
             style: TextStyle(color: AppTheme.tealColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
           ),
           
           SizedBox(height: 15.h),
           
           // Spinner / Sold As Label
           // Logic: If show_sold_as=Yes && sold_as=Each -> Show Dropdown
           // Else -> Show Label
            // Assuming 'Each' allows switching to 'Carton'
            if (widget.product.soldAs == "Each" && (widget.product.qtyPerOuter != null)) 
               Container(
                 padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                 decoration: BoxDecoration(
                   border: Border.all(color: Colors.grey[300]!),
                   borderRadius: BorderRadius.circular(5.r),
                 ),
                 child: DropdownButtonHideUnderline(
                   child: DropdownButton<String>(
                     value: _selectedSoldAs,
                     isExpanded: true,
                     items: _soldAsOptions.map((String value) {
                       return DropdownMenuItem<String>(
                         value: value,
                         child: Text(value),
                       );
                     }).toList(),
                     onChanged: (newValue) {
                       setState(() {
                         _selectedSoldAs = newValue!;
                         _calculatePrices();
                       });
                     },
                   ),
                 ),
               )
            else if (widget.product.soldAs != null) 
               Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  color: Colors.grey[100],
                  child: Text(
                     "${widget.product.soldAs} (${widget.product.qtyPerOuter ?? "0"} Units)",
                     style: TextStyle(fontWeight: FontWeight.bold),
                  ),
               ),
              
           SizedBox(height: 20.h),
           
           // Quantity Picker (Horizontal)
           // Placeholder for Picker
           SizedBox(
             height: 50.h,
             child: ListView.builder(
               scrollDirection: Axis.horizontal,
               itemCount: 100, // limited range for functionality
               itemBuilder: (context, index) {
                  // Range: MinQty to MaxQty based on Stock.
                  // For now simple list
                  int val = (int.tryParse(widget.product.minimumOrderQty ?? "0") ?? 1) + index;
                  bool isSelected = val == _quantity;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _quantity = val;
                      });
                    },
                    child: Container(
                      width: 50.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: isSelected ? Border(bottom: BorderSide(color: AppTheme.tealColor, width: 2)) : null,
                      ),
                      child: Text(
                        "$val",
                        style: TextStyle(
                          fontSize: isSelected ? 18.sp : 14.sp,
                          color: isSelected ? AppTheme.tealColor : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        ),
                      ),
                    ),
                  );
               },
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
                     backgroundColor: AppTheme.tealColor,
                     padding: EdgeInsets.symmetric(vertical: 12.h),
                   ),
                   child: Text(
                     isAdded ? "Update Cart [$_quantity]" : "Add To Cart",
                     style: TextStyle(color: AppTheme.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                   ),
                 ),
               ),
               if (isAdded) ...[
                 SizedBox(width: 10.w),
                 InkWell(
                   onTap: () {
                      provider.deleteCart(widget.product.productId!, widget.product.brandId ?? "");
                      Navigator.pop(context);
                   },
                   child: Container(
                     padding: EdgeInsets.all(10.w),
                     decoration: BoxDecoration(
                       border: Border.all(color: AppTheme.redColor),
                       borderRadius: BorderRadius.circular(5.r),
                     ),
                     child: Icon(Icons.delete, color: AppTheme.redColor),
                   ),
                 )
               ]
             ],
           )
        ],
      ),
    );
  }

  String _calculateDiscount(double price, double promo) {
    if (price == 0) return "0";
    return (((price - promo) / price) * 100).toInt().toString();
  }
  
  void _addToCart(BuildContext context) {
      final provider = context.read<DashboardProvider>();
      final profile = provider.profileResponse;
      final result = profile?.results?.isNotEmpty == true ? profile!.results![0] : null;

      if (result == null) return;

      int currentSupplierCount = int.tryParse(profile?.suppliersCount ?? "0") ?? 0;
      int maxSupplierCount = int.tryParse(result.maximumNumberOfSuppliersProductsForFreeShipping ?? "0") ?? 0;
      String currentSuppliers = profile?.suppliers ?? "";
      String productBrandId = widget.product.brandId ?? "";

      bool isSupplierInList = false;
      if (currentSuppliers.isNotEmpty) {
          List<String> supplierList = currentSuppliers.split(",");
          isSupplierInList = supplierList.contains(productBrandId);
      }

      String showShippingSegment = result.showShippingSegment ?? "";

      // Logic: If limit reached AND new supplier AND shipping segment enabled
      if (currentSupplierCount >= maxSupplierCount && !isSupplierInList && showShippingSegment == "Yes") {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Additional Supplier Charge"),
              content: Text(result.customerMessageForAdditionalSuppliersCharge ?? "Extra charges apply for additional suppliers."),
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

  void _performAddToCart(DashboardProvider provider) {
       if (widget.product.addedToCart == "Yes") {
           provider.updateCart(
              widget.product.productId!,
              _quantity.toString(),
              widget.product.brandId ?? "",
              _currentPromoPrice.toStringAsFixed(2), // Use formatted or raw? API expects string.
              _selectedSoldAs
           ); // Note: Android passes brandId for update
       } else {
           provider.addToCart(
              widget.product.productId!,
              _quantity.toString(),
              _currentPromoPrice.toStringAsFixed(2),
              _selectedSoldAs,
              widget.product.apiData ?? "",
              widget.product.brandId ?? ""
           );
       }
       Navigator.pop(context);
  }
}
