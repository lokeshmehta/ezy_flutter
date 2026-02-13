
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../config/routes/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../features/checkout/widgets/cart_item_refined_widget.dart';
import '../../../../core/utils/common_methods.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isShippingExpanded = true; // Default expanded? Android usually defaults to expanded or collapsed. Let's assume expanded to show totals.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCartDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, provider, child) {
            
            // Loading State (Center)
            if (provider.isLoading && provider.cartItems.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.tealColor));
            }

            // Empty State
            if (provider.cartResult == null || (provider.cartResult!.brands?.isEmpty ?? true)) {
               return _buildEmptyState(context);
            }

            return Column(
              children: [
                // Top Section (Header + List)
                Expanded(
                  child: Column(
                    children: [
                       _buildCustomHeader(),
                       
                       Expanded(
                         child: ListView.builder(
                           padding: EdgeInsets.only(bottom: 10.h),
                           itemCount: provider.cartResult?.brands?.length ?? 0,
                           itemBuilder: (context, index) {
                             final brand = provider.cartResult!.brands![index];
                             if (brand == null) return SizedBox.shrink();

                             return Column(
                               children: brand.products?.map((product) {
                                   if (product == null) return SizedBox.shrink();
                                   int pIndex = brand.products!.indexOf(product);
                                   return CartItemRefinedWidget(
                                     item: product,
                                     showHeader: pIndex == 0,
                                     brandName: brand.brandName ?? "",
                                     brandId: brand.brandId ?? "",
                                     onUpdateQty: (newQty) {
                                         provider.updateCartItem(product, newQty).then((_) {
                                             if(context.mounted) {
                                                 context.read<DashboardProvider>().setCartCount(CommonMethods.cartCount);
                                             }
                                         });
                                     },
                                     onDelete: () {
                                         provider.deleteCartItem(product).then((_) {
                                             if(context.mounted) {
                                                 context.read<DashboardProvider>().setCartCount(CommonMethods.cartCount);
                                             }
                                         });
                                     },
                                   );
                               }).toList() ?? [],
                             );
                           },
                         ),
                       ),
                    ],
                  ),
                ),

                // Bottom Fixed Section (Shipping Card + Actions)
                _buildBottomSection(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: [
          // If back navigation is needed (e.g. pushed from somewhere)
          if(Navigator.canPop(context))
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            ),
          ),
          
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Icon(Icons.shopping_cart, color: AppTheme.primaryColor, size: 20.sp), // Or Image logic
          ),
          SizedBox(width: 10.w),
          Text(
            "Cart",
             style: TextStyle(
               fontSize: 18.sp, 
               fontWeight: FontWeight.bold, 
               color: AppTheme.primaryColor // Blue
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(Icons.shopping_cart_outlined, size: 60.sp, color: Colors.grey),
           SizedBox(height: 10.h),
           Text("No items added to Cart", style: TextStyle(fontSize: 16.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
           SizedBox(height: 20.h),
           ElevatedButton(
             onPressed: () {
                 if(Navigator.canPop(context)) {
                    Navigator.pop(context);
                 } else {
                    context.go(AppRoutes.dashboard);
                 }
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

  Widget _buildBottomSection(CartProvider provider) {
    return Container(
      padding: EdgeInsets.all(5.w),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shipping Card
          Card(
            elevation: 5,
            color: Colors.white,
            margin: EdgeInsets.all(5.w),
            child: Column(
              children: [
                // Header (Clickable)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isShippingExpanded = !_isShippingExpanded;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Shipping",
                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                        Icon(
                          _isShippingExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppTheme.redColor, // Tint Red per XML
                          size: 28.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content
                if(_isShippingExpanded)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  child: Column(
                    children: [
                      // Delivery Location Selector (Mock UI based on XML)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Choose Your Delivery Location", style: TextStyle(color: AppTheme.darkGrayColor, fontSize: 13.sp)),
                      ),
                      SizedBox(height: 5.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Delivery Location", style: TextStyle(color: AppTheme.textColor, fontSize: 14.sp)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5.h),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                        decoration: BoxDecoration(
                           color: Colors.white,
                           border: Border.all(color: Colors.grey.shade400),
                           borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text("Select Delivery Location", style: TextStyle(color: AppTheme.primaryColor,fontSize: 14.sp)), // Placeholder
                             Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Price Breakdown
                      _buildSummaryRow(provider.cartResult?.subTotalHeading ?? "Sub Total", "AUD ${provider.subTotal}"),
                      if((double.tryParse(provider.discount) ?? 0) > 0)
                         _buildSummaryRow("Discount", "-AUD ${provider.discount}", isDiscount: true), // Green? XML says blue but standard is green/red. XML uses Blue for value.
                      if((double.tryParse(provider.deliveryCharge) ?? 0) > 0)
                         _buildSummaryRow("Shipping", "AUD ${provider.deliveryCharge}"),
                      if((double.tryParse(provider.suppliersExceededCharge) ?? 0) > 0)
                         _buildSummaryRow("Addnl. Supplier Charge", "AUD ${provider.suppliersExceededCharge}"),
                      if((double.tryParse(provider.couponDiscount) ?? 0) > 0)
                          _buildSummaryRow("Coupon Discount", "-AUD ${provider.couponDiscount}", isDiscount: true),
                      if((double.tryParse(provider.taxTotal) ?? 0) > 0)
                         _buildSummaryRow("GST", "AUD ${provider.taxTotal}"),
                      
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      _buildSummaryRow("Total", "AUD ${provider.totalAmount}", isBold: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Bar
          Container(
            margin: EdgeInsets.only(top: 10.h, left: 5.w, right: 5.w, bottom: 5.w),
            height: 45.h,
            child: Row(
              children: [
                // Clear Cart (Red)
                Expanded(
                  flex: 1, // pd_clearCartLay width 110dp vs next 90dp. Let's use approx ratios or flex.
                  child: ElevatedButton(
                    onPressed: () {
                       _showClearCartDialog(context, provider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.redColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // XML background @drawable/redbackground (usually small radius or rect)
                      // Let's use standard radius
                    ),
                    child: Text("Clear Cart", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  ),
                ),
                
                // Step Logic "1/3"
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      "1/3", 
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 15.sp),
                    ),
                  ),
                ),
                
                // Next (Teal)
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                         context.push(AppRoutes.checkout, extra: {'initialStep': 1}); // Start at Address Step
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.tealColor,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text("Next", style: TextStyle(color: Colors.white, fontSize: 15.sp)),
                           SizedBox(width: 5.w),
                           Icon(Icons.arrow_forward, color: Colors.white, size: 16.sp),
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
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label, 
              style: TextStyle(fontSize: 14.sp, color: AppTheme.darkGrayColor, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.primaryColor, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Cart Confirmation"),
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
