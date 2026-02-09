import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../config/routes/app_routes.dart';

import '../../providers/cart_provider.dart';
import 'widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
      backgroundColor: AppTheme.lightGrayBg, // Light background
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        leading: Navigator.canPop(context) 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            )
          : null,
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.cartItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.cartItems.isEmpty) {
             if (provider.errorMsg != null) {
                  return Center(child: Padding(padding: EdgeInsets.all(20), child: Text(provider.errorMsg!)));
             }
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.shopping_cart_outlined, size: 60.sp, color: AppTheme.hintColor),
                   SizedBox(height: 10.h),
                   Text("Your cart is empty", style: TextStyle(fontSize: 18.sp, color: AppTheme.hintColor)),
                   SizedBox(height: 20.h),
                   ElevatedButton(
                     onPressed: ()=> context.pop(), 
                     child: const Text("Start Shopping")
                   ),
                 ],
               ),
             );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Cart Items List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Scroll handled by SingleChildScrollView
                        itemCount: provider.cartItems.length,
                        itemBuilder: (context, index) {
                          return CartItemWidget(item: provider.cartItems[index]);
                        },
                      ),
                      
                      SizedBox(height: 10.h),
                      
                      // Price Breakdown Section (Mirroring ShoppingCartFragment layout)
                      Container(
                        color: AppTheme.white,
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          children: [
                            _buildPriceRow("Sub Total", provider.subTotal),
                            
                            if (double.parse(provider.discount) > 0)
                              _buildPriceRow("Discount", "- ${provider.discount}", color: AppTheme.successGreen),
                            
                            if (double.parse(provider.couponDiscount) > 0)
                                _buildPriceRow("Coupon (${provider.couponName})", "- ${provider.couponDiscount}", color: AppTheme.successGreen),

                            if (double.parse(provider.deliveryCharge) > 0 || double.parse(provider.locationDeliveryCharge) > 0)
                               _buildPriceRow("Shipping", (double.parse(provider.deliveryCharge) + double.parse(provider.locationDeliveryCharge)).toStringAsFixed(2)),

                            if (double.parse(provider.suppliersExceededCharge) > 0)
                               _buildPriceRow("Supplier Surcharge", provider.suppliersExceededCharge),
                               
                            if (double.parse(provider.taxTotal) > 0)
                               _buildPriceRow("Tax (GST)", provider.taxTotal),
                             
                            Divider(height: 20.h, thickness: 1),
                            
                            _buildPriceRow("Total Amount", provider.totalAmount, isBold: true, size: 16.sp),
                          ],
                        ),
                      ),
                      
                      // Minimum/Max Order Notifications (Logic from Fragment)
                      // ... (We can add this later if validation fails on checkout)
                      
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Bar
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  boxShadow: [
                    BoxShadow(color: AppTheme.shadowBlack, blurRadius: 4, offset: Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                       onPressed: () {
                          context.push(AppRoutes.checkout);
                       },
                      child: Text(
                        "PROCEED TO CHECKOUT",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, double? size, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: size ?? 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppTheme.darkGrayColor)),
          Text("\$$value", style: TextStyle(fontSize: size ?? 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? AppTheme.textColor)),
        ],
      ),
    );
  }
}
