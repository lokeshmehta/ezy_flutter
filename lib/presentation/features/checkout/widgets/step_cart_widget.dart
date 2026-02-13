
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
                        provider.cartResult?.totalHeading ?? "Total Amount",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
                      Row(
                        children: [
                          Text(
                            "AUD ${provider.totalAmount}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black),
                          ),
                          Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (_isExpanded)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                  color: Colors.grey.shade50,
                  child: Column(
                    children: [
                      _buildSummaryRow(provider.cartResult?.subTotalHeading ?? "Sub Total", "AUD ${provider.subTotal}"),
                      if((double.tryParse(provider.discount) ?? 0) > 0)
                         _buildSummaryRow("Discount", "-AUD ${provider.discount}", isDiscount: true),
                      if((double.tryParse(provider.shippingCharge) ?? 0) > 0)
                         _buildSummaryRow("Shipping Charges", "AUD ${provider.shippingCharge}"),
                      if((double.tryParse(provider.supplierCharge) ?? 0) > 0)
                         _buildSummaryRow("Supplier Charges", "AUD ${provider.supplierCharge}"),
                      if((double.tryParse(provider.taxTotal) ?? 0) > 0)
                         _buildSummaryRow("Tax (GST)", "AUD ${provider.taxTotal}"),
                      if((double.tryParse(provider.couponDiscount) ?? 0) > 0)
                          _buildSummaryRow("Coupon (${provider.couponName})", "-AUD ${provider.couponDiscount}", isDiscount: true),
                      
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Divider(),
                      ),
                      _buildSummaryRow("Total Amount", "AUD ${provider.totalAmount}", isBold: true),
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
                      flex: 1, // Layout weight might differ but 1:1 or specific ratio. XML doesn't show weight in snippet.
                      child: SizedBox(
                        height: 45.h,
                        child: ElevatedButton(
                          onPressed: () {
                             _showClearCartDialog(context, provider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.redColor, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r)),
                          ),
                          child: Text("Clear Cart", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    // Next (Layout with Text + Image)
                    Expanded(
                      flex: 1, 
                      child: InkWell(
                        onTap: () {
                           provider.nextStep();
                           if(provider.errorMessage.isNotEmpty) {
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage)));
                           }
                        },
                        child: Container(
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: AppTheme.tealColor, // Or Teal
                            borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r),
                            // Gradient? snippet doesn't say.
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Next", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.white)),
                              SizedBox(width: 8.w),
                              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp), // pd_nextStep Image
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

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 13.sp, color: isDiscount ? Colors.green : Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
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
