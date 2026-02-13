
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../config/routes/app_routes.dart';



class StepPreviewWidget extends StatefulWidget {
  const StepPreviewWidget({super.key});

  @override
  State<StepPreviewWidget> createState() => _StepPreviewWidgetState();
}

class _StepPreviewWidgetState extends State<StepPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final validItems = provider.cartItems; 
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Review Items"),
          SizedBox(height: 10.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: validItems.length,
            itemBuilder: (ctx, i) {
                final item = validItems[i];
                return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                        leading: Image.network(item.image ?? "", width: 50.w, height: 50.w, errorBuilder: (_,__,___) => const Icon(Icons.image)),
                        title: Text(item.title ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp)),
                        subtitle: Text("Qty: ${item.qty} | ${item.orderedAs}", style: TextStyle(fontSize: 12.sp)),
                        trailing: Text("AUD ${item.salePrice}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    ),
                );
            },
          ),
          
          SizedBox(height: 20.h),
          _buildSectionTitle("Order Summary"),
          SizedBox(height: 10.h),
          // Price Breakdown
           _buildPriceRow("Sub Total", provider.subTotal),
          if (double.tryParse(provider.discount) != 0)
              _buildPriceRow("Discount", "- ${provider.discount}", color: AppTheme.successGreen),
          
          if (double.tryParse(provider.couponDiscount) != 0)
              _buildPriceRow("Coupon (${provider.couponName})", "- ${provider.couponDiscount}", color: AppTheme.successGreen),

          if (double.tryParse(provider.shippingCharge) != 0)
              _buildPriceRow("Shipping", provider.shippingCharge),
          
          if (double.tryParse(provider.supplierCharge) != 0)
              _buildPriceRow("Supplier Surcharge", provider.supplierCharge),

          if (double.tryParse(provider.taxTotal) != 0)
              _buildPriceRow("Tax (GST)", provider.taxTotal),
          
          const Divider(thickness: 1),
          _buildPriceRow("Total Amount", provider.totalAmount, isBold: true, size: 16.sp),

          

          SizedBox(height: 30.h),
          
          // Navigation Buttons
          Row(
            children: [
               // Back Button
               Expanded(
                 child: InkWell(
                   onTap: () {
                      provider.previousStep();
                   },
                   child: Container(
                     height: 45.h,
                     decoration: BoxDecoration(
                       color: AppTheme.tealColor, // Filled Teal
                       borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
                         SizedBox(width: 8.w),
                         Text("Back", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                       ],
                     ),
                   ),
                 ),
               ),
               SizedBox(width: 15.w),
               
               // Submit Button
               Expanded(
                 child: InkWell(
                   onTap: provider.isLoading 
                     ? null 
                     : () async {
                         final response = await provider.createOrder();
                         if(!context.mounted) return;
                         
                         if(response != null) {
                            // Construct simple object or pass response directly if OrderSuccessScreen handles it
                            final orderData = {
                                'order_id': response['order_id'], 
                                'transaction_id': response['transaction_id'], 
                                'payment_type': provider.paymentMethod,
                                'success_msg': response['message']
                            };
                            
                            context.go(AppRoutes.orderSuccess, extra: orderData); // Ensure AppRoutes.orderSuccess expects this map
                         } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text(provider.errorMessage.isNotEmpty ? provider.errorMessage : "Order Failed"), backgroundColor: AppTheme.redColor)
                             );
                         } 
                   },
                   child: Container(
                     height: 45.h,
                     decoration: BoxDecoration(
                       color: AppTheme.tealColor,
                       borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r),
                     ),
                     child: Center(
                        child: provider.isLoading 
                          ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : Text("Proceed to Pay", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                     ),
                   ),
                 ),
               ),
            ],
          ),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color color = AppTheme.blackColor, double? size}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: size ?? 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: AppTheme.darkGrayColor)),
          Text(value, style: TextStyle(fontSize: size ?? 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
