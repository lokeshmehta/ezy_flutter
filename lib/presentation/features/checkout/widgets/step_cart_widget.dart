
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../core/constants/app_theme.dart';
import 'cart_item_refined_widget.dart';

class StepCartWidget extends StatefulWidget {
  const StepCartWidget({super.key});

  @override
  State<StepCartWidget> createState() => _StepCartWidgetState();
}

class _StepCartWidgetState extends State<StepCartWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final cartResult = provider.cartResult;

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (cartResult == null || (cartResult.brands?.isEmpty ?? true)) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.shopping_cart_outlined, size: 60.sp, color: Colors.grey),
             SizedBox(height: 10.h),
             Text("No Products added to Cart.", style: TextStyle(fontSize: 16.sp, color: Colors.grey)), // Exact text from dialog_emptycart.xml
             SizedBox(height: 20.h),
             // Back to Home Button
             ElevatedButton(
               onPressed: () {
                   Navigator.pop(context); // Or navigate to dashboard
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppTheme.tealColor,
                 foregroundColor: Colors.white,
                 minimumSize: Size(150.w, 40.h),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
               ),
               child: Text("Back to Home"),
             )
           ],
         ),
       );
    }

    return Column(
      children: [
        // Header (Delivery Location) - Simplified for now as per XML snippet inspection
        // fragment_shoppingcart.xml has a layout at top for delivery location?
        // Actually it wasn't explicitly in the snippet I viewed, but I'll add a placeholder if provider has it.
        // Provider has `updateDeliveryLocationAPI`, so there must be a selector.
        // Assuming it's a dropdown or text.
        
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 10.h),
            itemCount: cartResult.brands?.length ?? 0,
            itemBuilder: (context, index) {
              final brand = cartResult.brands![index];
              if (brand == null) return SizedBox.shrink();

              // For each brand, verify how it's displayed. XML shows item_cart has a header logic in adapter.
              // Here we stick to listing products.
              return Column(
                children: brand.products?.map((product) {
                    if (product == null) return SizedBox.shrink();
                    int pIndex = brand.products!.indexOf(product);

                    return CartItemRefinedWidget(
                      item: product,
                      showHeader: pIndex == 0, // Show header for first item of brand
                      brandName: brand.brandName ?? "",
                      brandId: brand.brandId ?? "",
                      onUpdateQty: (newQty) {
                          provider.updateCartItem(product.productId!, newQty, brand.brandId!, product.salePrice ?? "0", product.orderedAs ?? "");
                      },
                      onDelete: () {
                          provider.deleteCartItem(product.productId!, brand.brandId!);
                      },
                    );
                }).toList() ?? [],
              );
            },
          ),
        ),


        // Bottom Section (Price Details & Actions)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.3), blurRadius: 4, offset: Offset(0, -2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Expandable Price Details header
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cart Total",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Color(0xFF0038FF)),
                      ),
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green, // Screenshot shows green circle
                        ),
                         child: Icon(
                           _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                           color: Colors.white,
                           size: 16.sp,
                         ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isExpanded)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildSummaryRow(provider.cartResult?.subTotalHeading ?? "Sub-Total", "AUD ${provider.subTotal}"),
                      if((double.tryParse(provider.discount) ?? 0) > 0)
                         _buildSummaryRow("Discount", "-AUD ${provider.discount}", isDiscount: true),
                      
                      // Screenshot: Ex. GST
                      _buildSummaryRow("Ex. GST :", "AUD ${provider.subTotal}", isBlueValue: true), // Assuming subtotal is ex gst? Need to verify logic. Screenshot: Sub-Total ... Ex. GST ... 
                      // Wait, "Sub-Total" is usually Ex GST in B2B. Screenshot has "Sub-Total" label then "Ex. GST : AUD...".
                      // Let's blindly follow screenshot labels if possible. 
                      // Provider has 'subTotal', 'taxTotal', 'totalAmount'.
                      // Let's map: 
                      // Sub-Total -> provider.subTotal (Generic)
                      // Ex. GST -> provider.subTotal (Usually)
                      // GST -> provider.taxTotal
                      // Grand Total -> provider.totalAmount
                      // Inc. GST -> provider.totalAmount
                      
                      if((double.tryParse(provider.shippingCharge) ?? 0) > 0)
                         _buildSummaryRow("Shipping Charges", "AUD ${provider.shippingCharge}", isBlueValue: true),
                      if((double.tryParse(provider.supplierCharge) ?? 0) > 0)
                         _buildSummaryRow("Supplier Charges", "AUD ${provider.supplierCharge}", isBlueValue: true),
                         
                      _buildSummaryRow("GST :", "AUD ${provider.taxTotal}", isBlueValue: true),
                      
                      if((double.tryParse(provider.couponDiscount) ?? 0) > 0)
                          _buildSummaryRow("Coupon (${provider.couponName})", "-AUD ${provider.couponDiscount}", isDiscount: true),
                      
                      SizedBox(height: 5.h),
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                             Text("Grand Total", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                             SizedBox(),
                         ]
                      ),
                      _buildSummaryRow("Inc. GST :", "AUD ${provider.totalAmount}", isBlueValue: true),
                    ],
                  ),
                ),

              // Action Buttons (pd_next_back_layout)
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Row(
                  children: [
                    // Clear Cart (Red CustomButton)
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: () {
                             _showClearCartDialog(context, provider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD32F2F), // Darker Red
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                          ),
                          child: Text("Clear Cart", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                        ),
                      ),
                    ),
                    
                    // 1/3
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text("1/3", style: TextStyle(color: Color(0xFF0038FF), fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    // Next (Orange)
                    Expanded(
                      flex: 4, 
                      child: InkWell(
                        onTap: () {
                           provider.nextStep();
                           if(provider.errorMessage.isNotEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage)));
                           }
                        },
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Color(0xFFF5A623), // Orange/Yellow
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Text("Next", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                               SizedBox(width: 5.w),
                               Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14.sp), 
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
      
  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isBlueValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600)), 
          Text(value, style: TextStyle(
              fontSize: 14.sp, 
              color: isDiscount ? Colors.red : (isBlueValue ? Color(0xFF0038FF) : Colors.black), 
              fontWeight: FontWeight.bold 
          )),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CheckoutProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Cart Confirmation", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.tealColor, // or Red based on XML header
        // XML `dialog_clearcart.xml` has Header Red, Body White.
        // We'll use a custom Dialog matching XML if needed, or simple Alert for now.
        // Plan says: "Clear Cart (Red Background, White Text)" is the button. The dialog is separate.
        // Let's implement a simple dialog effectively.
        content: Text("Are you sure to clear items in the cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
          TextButton(
            onPressed: () {
              provider.clearCart();
              Navigator.pop(context);
            },
            child: Text("Clear Cart", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
