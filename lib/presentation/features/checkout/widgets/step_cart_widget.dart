
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/common_methods.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../widgets/custom_loader_widget.dart';
import 'cart_item_refined_widget.dart';
import 'clear_cart_dialog.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';


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
      return Center(child: CustomLoaderWidget(size: 40.w));
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
                      onUpdateQty: (newQty) async {
                          // Fix: Ensure we send valid price on update
                          String priceOne = product.salePrice ?? "0";
                          if((double.tryParse(priceOne) ?? 0) <= 0) {
                             priceOne = product.normalPrice ?? "0";
                          }
                          await provider.updateCartItem(product.productId!, newQty, brand.brandId!, priceOne, product.orderedAs ?? "");
                          if (context.mounted) {
                             context.read<DashboardProvider>().setCartCount(CommonMethods.cartCount);
                          }
                      },
                      onDelete: () async {
                          await provider.deleteCartItem(product.productId!, brand.brandId!);
                          if (context.mounted) {
                             context.read<DashboardProvider>().setCartCount(CommonMethods.cartCount);
                          }
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
            // Match Native Shadow: distinct shadow lifting the footer
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, -3),
              )
            ],
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.primaryColor),
                      ),
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF27AE60), // Green from screenshot
                        ),
                         child: Icon(
                           _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                           color: Colors.white,
                           size: 18.sp,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sub-Total Section
                      Text(
                        provider.cartResult?.subTotalHeading ?? "Sub-Total",
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 5.h),
                      _buildSummaryRow("Ex. GST :", "AUD ${provider.subTotal}", isBlueValue: true),
                      
                      // GST
                      _buildSummaryRow("GST :", "AUD ${provider.taxTotal}", isBlueValue: true),
                      
                      // Extra Charges if any
                      if((double.tryParse(provider.shippingCharge) ?? 0) > 0)
                         _buildSummaryRow("Shipping Charges", "AUD ${provider.shippingCharge}", isBlueValue: true),
                      if((double.tryParse(provider.supplierCharge) ?? 0) > 0)
                         _buildSummaryRow("Supplier Charges", "AUD ${provider.supplierCharge}", isBlueValue: true),
                      if((double.tryParse(provider.discount) ?? 0) > 0)
                         _buildSummaryRow("Discount", "-AUD ${provider.discount}", isDiscount: true),
                      if((double.tryParse(provider.couponDiscount) ?? 0) > 0)
                          _buildSummaryRow("Coupon (${provider.couponName})", "-AUD ${provider.couponDiscount}", isDiscount: true),

                      SizedBox(height: 10.h),
                      
                      // Grand Total Section
                      Text(
                        provider.cartResult?.totalHeading ?? "Grand Total",
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.darkGrayColor),
                      ),
                       SizedBox(height: 5.h),
                      _buildSummaryRow("Inc. GST :", "AUD ${provider.totalAmount}", isBlueValue: true),
                      SizedBox(height: 5.h),
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
                            backgroundColor: AppTheme.redColor, // Darker Red
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
                        child: Text("1/3", style: TextStyle(color: AppTheme.primaryColor, fontSize: 15.sp, fontWeight: FontWeight.bold)),
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
                            color: AppTheme.secondaryColor, // Orange/Yellow
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
          Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.darkGrayColor, fontWeight: FontWeight.w600)), 
          Text(value, style: TextStyle(
              fontSize: 14.sp, 
              color: isDiscount ? AppTheme.redColor : (isBlueValue ? AppTheme.primaryColor : Colors.black), 
              fontWeight: FontWeight.bold 
          )),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CheckoutProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ClearCartDialog(
        onClose: () => Navigator.pop(dialogContext),
        onClear: () async {
            // 1. Close dialog FIRST
            Navigator.pop(dialogContext);
            
            // 2. Perform Clear Action
            await provider.clearCart();
            
            // 3. Force Update Dashboard Provider & Navigate
            if (context.mounted) {
               final dashboardProvider = context.read<DashboardProvider>();
               
               // Update global cart count to 0
               dashboardProvider.setCartCount("0");

               // Reset to Home Tab
               dashboardProvider.setIndex(0);
               
               // Trigger Full Refresh
               dashboardProvider.init();
               
               // Navigate to Dashboard (Home) to refresh state
               context.go(AppRoutes.dashboard);
            }
        },
      ),
    );
  }
}
