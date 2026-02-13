
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../widgets/custom_loader_widget.dart';




class StepPreviewWidget extends StatelessWidget {
  const StepPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    // Use cartResult.brands for grouped items, fallback to cartItems if empty
    final brands = provider.cartResult?.brands;
    final flatItems = provider.cartItems;
    final hasBrands = brands != null && brands.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Order Details Card
          _buildCard(
            context,
            title: "Order Details",
            onEdit: () => provider.goToStep(0), // Go to Cart
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Items", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    Text("Qty", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                  ],
                ),
                SizedBox(height: 10.h),
                const Divider(),
                
                // Grouped Items (by Brand) OR Flat list
                if (hasBrands)
                  ...brands.map((brand) {
                    if (brand == null || brand.products == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        Text(
                          brand.brandName ?? "Unknown Vendor",
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Column(
                            children: brand.products!.map((product) {
                              if (product == null) return const SizedBox.shrink();
                              return Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.title ?? "",
                                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "AUD ${product.salePrice}",
                                            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "${product.qty}",
                                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  })
                else
                   ...flatItems.map((item) {
                      return Padding(
                         padding: EdgeInsets.symmetric(vertical: 5.h),
                         child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Expanded(
                                 child: Text(item.title ?? "", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                               ),
                               Text("${item.qty}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            ]
                         ),
                      );
                   }),

                SizedBox(height: 15.h),
                const Divider(),
                SizedBox(height: 10.h),

                // Price Breakdown
                _buildSummaryRow(provider.cartResult?.subTotalHeading ?? "Sub-Total", "AUD ${provider.subTotal}"),
                _buildSummaryRow("Ex. GST :", "AUD ${provider.subTotal}", isBlueValue: true),
                
                if((double.tryParse(provider.shippingCharge) ?? 0) > 0)
                   _buildSummaryRow("Shipping :", "AUD ${provider.shippingCharge}", isBlueValue: true),
                   
                if((double.tryParse(provider.supplierCharge) ?? 0) > 0)
                   _buildSummaryRow("Supplier Charges :", "AUD ${provider.supplierCharge}", isBlueValue: true),

                if((double.tryParse(provider.taxTotal) ?? 0) > 0)
                   _buildSummaryRow("GST :", "AUD ${provider.taxTotal}", isBlueValue: true),

                if((double.tryParse(provider.couponDiscount) ?? 0) > 0)
                    _buildSummaryRow("Coupon (${provider.couponName})", "-AUD ${provider.couponDiscount}", isDiscount: true),

                SizedBox(height: 5.h),
                Text("Grand Total", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                _buildSummaryRow("Inc. GST :", "AUD ${provider.totalAmount}", isBlueValue: true),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          // 2. Address Details Card
          _buildCard(
            context,
            title: "Address Details",
            onEdit: () => provider.goToStep(1), // Go to Address
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Delivery Address", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 2.h),
                Text(
                  _formatAddress(
                    provider.shipFirstNameController.text,
                    provider.shipLastNameController.text,
                    provider.shipStreetController.text,
                    provider.shipCityController.text,
                    provider.shipStateController.text,
                    provider.shipPostCodeController.text,
                  ),
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Text("Billing Address", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 2.h),
                Text(
                  _formatAddress(
                    provider.billFirstNameController.text, // Assuming Billing is same or populated
                    provider.billLastNameController.text,
                    provider.billStreetController.text,
                    provider.billCityController.text,
                    provider.billStateController.text,
                    provider.billPostCodeController.text,
                  ),
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          // 3. Payment Details Card
          _buildCard(
            context,
            title: "Payment Details",
            onEdit: () => provider.goToStep(2), // Go to Payment
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment Method", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 2.h),
                Text(
                  provider.paymentMethod.isNotEmpty ? provider.paymentMethod : "Not Selected",
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () {
                      provider.placeOrder(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF5A623), // Orange
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
                elevation: 2,
              ),
              child: provider.isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CustomLoaderWidget(size: 20.w),
                    )
                  : Text(
                      provider.paymentMethod == "Cash on Delivery" ? "Submit Order" : "Proceed To Pay",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  String _formatAddress(String fName, String lName, String street, String city, String state, String zip) {
    List<String> parts = [];
    String name = "$fName $lName".trim();
    if(name.isNotEmpty) parts.add(name);
    // Logic matches Android: "rajat mehra, malviya nagar, jaipur, jaipur rajasthan 302017"
    if(street.isNotEmpty) parts.add(street);
    if(city.isNotEmpty) parts.add(city);
    String stateZip = "$state $zip".trim();
    if(stateZip.isNotEmpty) parts.add(stateZip);
    
    if(parts.isEmpty) return "Not provided";
    return parts.join(", "); 
  }

  Widget _buildCard(BuildContext context, {required String title, required VoidCallback onEdit, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 4, spreadRadius: 1),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor, // Blue
                ),
              ),
              InkWell(
                onTap: onEdit,
                child: Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBlueValue = false, bool isDiscount = false, bool isGrandTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: isGrandTotal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade700
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.red : (isBlueValue ? AppTheme.primaryColor : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
