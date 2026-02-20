import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/utils/common_methods.dart';
import '../../../../data/models/home_models.dart';

import '../../../providers/product_list_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../widgets/custom_loader_widget.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final ProductItem product;

  const ProductDetailsBottomSheet({super.key, required this.product});

  @override
  State<ProductDetailsBottomSheet> createState() => _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  String _selectedSoldAs = "Each";
  int _selectedQty = 1;
  late FixedExtentScrollController _qtyScrollController;

  @override
  void initState() {
    super.initState();
    _selectedSoldAs = widget.product.orderedAs ?? "Each";
    _selectedQty = int.tryParse(widget.product.addedQty ?? "1") ?? 1;
    if (_selectedQty < 1) _selectedQty = 1;
    
    _qtyScrollController = FixedExtentScrollController(initialItem: _selectedQty - 1);
  }

  @override
  void dispose() {
    _qtyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.read<DashboardProvider>();
    final showSoldAs = dashboardProvider.profileResponse?.results?[0]?.showSoldAs == "Yes";
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.r),
          topRight: Radius.circular(15.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(context),
          
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15.w).copyWith(bottom: 15.w + MediaQuery.of(context).padding.bottom),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image & Tag
                          _buildProductImage(),
                          SizedBox(width: 15.w),
                          // Product Info
                          Expanded(
                            child: _buildProductDetails(showSoldAs),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 15.h),
                      
                      // Min Order Qty & Stock Info
                      _buildStockInfo(),
                      
                      SizedBox(height: 15.h),
                      
                      // Quantity Picker
                      _buildQuantityPicker(),
                      
                      SizedBox(height: 15.h),
                      
                      // Action Buttons
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.r),
          topRight: Radius.circular(15.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.r,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Product Details",
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppTheme.primaryColor, size: 22.sp),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    // Simplified tag logic matching Android pdTagTxt
    String tagText = "";
    
    // Priority: Label (Best Seller/Hot Selling) -> Promotion -> New Arrival
    if (widget.product.label != null && widget.product.label!.isNotEmpty) {
      tagText = widget.product.label!;
    } else if (widget.product.hasPromotion == "Yes") {
      tagText = "Promotion";
    } else if (widget.product.qtyStatus == "New Arrival") {
      tagText = "New Arrival";
    }

    return Stack(
      children: [
        Container(
          width: 150.w,
          height: 150.w,
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: CachedNetworkImage(
            imageUrl: widget.product.image?.startsWith("http") == true 
                ? widget.product.image! 
                : "${UrlApiKey.mainUrl}${widget.product.image}",
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(child: CustomLoaderWidget(size: 30.w)),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        if (tagText.isNotEmpty)
          Positioned(
            top: 5.h,
            left: 5.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppTheme.redColor, // Red stripe
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: Text(
                tagText,
                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetails(bool showSoldAs) {
    // Match Dashboard Logic: Always show Unit Price
    double basePrice = double.tryParse(widget.product.price ?? "0.0") ?? 0.0;
    double basePromoPrice = double.tryParse(widget.product.promotionPrice ?? "0.0") ?? 0.0;
    
    // In Dashboard, price is NOT multiplied by qtyPerOuter. It shows unit price.
    double currentPrice = basePrice;
    double currentPromoPrice = basePromoPrice;
    
    bool hasPromo = widget.product.hasPromotion == "Yes" && currentPromoPrice > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSoldAs)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), // Match Dashboard padding
            margin: EdgeInsets.only(bottom: 5.h),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor, // Orange, matching Dashboard
              borderRadius: BorderRadius.circular(0.r), // Match Dashboard (Square/small radius) - Dashboard uses 0.r or small
            ),
            child: Text(
              widget.product.soldAs == "Each" 
                ? "Each" // Dashboard shows "Each" or "Carton (X Units)"
                : "${widget.product.soldAs} (${widget.product.qtyPerOuter} Units)",
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
        
        Text(
          widget.product.brandName ?? "",
          style: TextStyle(color: Colors.grey[700], fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 2.h),
        Text(
          widget.product.title ?? "",
          style: TextStyle(color: AppTheme.primaryColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 5.h),
        
        // Pricing
        if (hasPromo) ...[
          Text(
            "AUD ${currentPrice.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13.sp,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Row(
            children: [
               Text(
                "AUD ${currentPromoPrice.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.grey, fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.redColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Text(
                  "-${CommonMethods.findDiscount(currentPrice.toString(), currentPromoPrice.toString())}%",
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
              ),
            ],
          ),
        ] else
          Text(
            "AUD ${currentPrice.toStringAsFixed(2)}",
            style: TextStyle(color: AppTheme.primaryColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
        
        SizedBox(height: 5.h),
        
        // Sold As Spinner - only if show_sold_as is Yes and sold_as is Each
        if (showSoldAs && widget.product.soldAs == "Each")
          Container(
            height: 42.h,
            width: double.infinity,
            margin: EdgeInsets.only(top: 5.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(5.r),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSoldAs,
                isExpanded: true,
                items: ["Each", "Carton"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 14.sp)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSoldAs = value!;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStockInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.product.minimumOrderQty != null && widget.product.minimumOrderQty != "1")
          Text(
            "Minimum Order Quantity: ${widget.product.minimumOrderQty}",
            style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
        if (widget.product.stockUnlimited == "No")
          Text(
            "In Stock: ${widget.product.availableStockQty}",
            style: TextStyle(color: Colors.red, fontSize: 11.sp, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildQuantityPicker() {
    // Android uses a horizontal picker. 
    // We can use a ListView.builder with a FixedExtentScrollController or just a scrollable row.
    // The Android code uses `getData(1, 100)` or similar. 
    // Default range 1 to 100 as per common practice in this app.
    List<String> qtyList = List.generate(100, (index) => (index + 1).toString());

    return Container(
      height: 60.h,
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE), // greybtn color
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: qtyList.length,
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        itemBuilder: (context, index) {
          bool isSelected = _selectedQty == (index + 1);
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedQty = index + 1;
              });
            },
            child: Container(
              width: 50.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: isSelected ? Border(bottom: BorderSide(color: AppTheme.secondaryColor, width: 2.h)) : null,
              ),
              child: Text(
                qtyList[index],
                style: TextStyle(
                  color: isSelected ? AppTheme.secondaryColor : Colors.black,
                  fontSize: isSelected ? 20.sp : 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<ProductListProvider>();
    bool isAdded = widget.product.addedToCart == "Yes";

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: ElevatedButton(
            onPressed: () async {
              if (isAdded) {
                await provider.updateCart(widget.product, _selectedQty.toString(), _selectedSoldAs);
              } else {
                await provider.addToCart(widget.product, _selectedQty.toString(), _selectedSoldAs);
              }
              
              if (context.mounted) {
                 context.read<DashboardProvider>().setCartCount(CommonMethods.cartCount);
                 Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tealColor, // Synchronized orange
              minimumSize: Size(double.infinity, 40.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r)),
            ),
            child: Text(
              isAdded ? "Update Cart [${widget.product.addedQty}]" : "Add To Cart",
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ),
        if (isAdded) ...[
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () async {
              await provider.deleteFromCart(widget.product);
              if (context.mounted) Navigator.pop(context);
            },
            child: Container(
              width: 40.h,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r),
              ),
              child: Icon(Icons.delete, color: Colors.white, size: 26.sp),
            ),
          ),
        ],
      ],
    );
  }
}
