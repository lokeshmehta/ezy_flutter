
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/checkout_provider.dart';
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
             Text("Your cart is empty", style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
           ],
         ),
       );
    }

    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 10.h),
            itemCount: cartResult.brands?.length ?? 0,
            itemBuilder: (context, index) {
              final brand = cartResult.brands![index];
              if (brand == null) return SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...brand.products?.map((product) {
                    if (product == null) return SizedBox.shrink();
                    // Show header only for first item of the brand? 
                    // Android Adapter logic: if brand_id changes.
                    // Here we iterate brands, so checking index 0 of product list is enough? 
                    // Actually, we are mapping products directly under the brand loop.
                    // So we can pass ShowHeader = true for the first product, false for others.
                    // Wait, we are generating children for the Column.
                    int pIndex = brand.products!.indexOf(product);
                    return CartItemRefinedWidget(
                      item: product,
                      showHeader: pIndex == 0,
                      brandName: brand.brandName ?? "",
                      brandId: brand.brandId ?? "",
                    );
                  }).toList() ?? [],
                ],
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
                        cartResult.totalHeading ?? "Total Amount", // "Price Details" or similar
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
                      Row(
                        children: [
                          Text(
                            "\$${provider.totalAmount}",
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
                      _buildSummaryRow(cartResult.subTotalHeading ?? "Sub Total", "\$${provider.subTotal}"),
                      if(double.parse(provider.discount) > 0)
                         _buildSummaryRow("Discount", "-\$${provider.discount}", isDiscount: true),
                      if(double.parse(provider.shippingCharge) > 0)
                         _buildSummaryRow("Shipping Charges", "\$${provider.shippingCharge}"),
                      if(double.parse(provider.supplierCharge) > 0)
                         _buildSummaryRow("Supplier Charges", "\$${provider.supplierCharge}"),
                      if(double.parse(provider.taxTotal) > 0)
                         _buildSummaryRow("Tax (GST)", "\$${provider.taxTotal}"),
                      if(double.parse(provider.couponDiscount) > 0)
                          _buildSummaryRow("Coupon (${provider.couponName})", "-\$${provider.couponDiscount}", isDiscount: true),
                      
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Divider(),
                      ),
                      _buildSummaryRow("Total Amount", "\$${provider.totalAmount}", isBold: true),
                    ],
                  ),
                ),

              // Action Buttons
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Row(
                  children: [
                    // Clear Cart
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                           // Show confirmation dialog?
                           provider.clearCart();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text("Clear Cart"),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    // Next Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                           provider.nextStep();
                           if(provider.errorMessage.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage)));
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFA500), // Orange
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text("Next", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
}
