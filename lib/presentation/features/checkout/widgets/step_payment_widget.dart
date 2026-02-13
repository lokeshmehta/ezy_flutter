import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_messages.dart';


class StepPaymentWidget extends StatefulWidget {
  const StepPaymentWidget({super.key});

  @override
  State<StepPaymentWidget> createState() => _StepPaymentWidgetState();
}

class _StepPaymentWidgetState extends State<StepPaymentWidget> {
  // Hardcoded mirroring Android preference logic default
  final List<String> _paymentMethods = ["Cash on Delivery", "Online Payment"];

  @override
  void initState() {
    super.initState();
    // Set default payment method if not set
    final provider = context.read<CheckoutProvider>();
    if(provider.paymentMethod.isEmpty) {
       provider.selectPaymentMethod("Cash on Delivery");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Select Payment Method"),
          SizedBox(height: 10.h),
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.hintColor),
              borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: provider.paymentMethod.isNotEmpty && _paymentMethods.contains(provider.paymentMethod) 
                    ? provider.paymentMethod 
                    : _paymentMethods[0],
                items: _paymentMethods.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    provider.selectPaymentMethod(val);
                  }
                },
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          _buildSectionTitle("Promo Code"),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: provider.couponController,
                  decoration: InputDecoration(
                    hintText: "Enter Coupon Code",
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
                      borderSide: const BorderSide(color: AppTheme.hintColor),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              ElevatedButton(
                onPressed: provider.isLoading 
                   ? null 
                   : () async {
                       bool success = await provider.applyCoupon();
                       if(!context.mounted) return;
                       if(success) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppMessages.couponAppliedSuccessfully)));
                       }
                 },
                style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.orderSuccessTeal,
                   foregroundColor: AppTheme.white,
                   minimumSize: Size(0, 45.h),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r)),
                   padding: EdgeInsets.symmetric(horizontal: 20.w)
                ),
                child: provider.isLoading 
                    ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: AppTheme.white, strokeWidth: 2)) 
                    : const Text("Apply"),
              )
            ],
          ),
          if(provider.errorMessage.isNotEmpty)
             Padding(
               padding: EdgeInsets.only(top: 5.h),
               child: Text(provider.errorMessage, style: TextStyle(color: AppTheme.redColor, fontSize: 12.sp)),
             ),

          SizedBox(height: 20.h),
          _buildSectionTitle("Order Notes"),
          SizedBox(height: 10.h),
          TextFormField(
            controller: provider.orderNotesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Reason for ordering...", // Android hint
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          const Divider(),
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
                       color: AppTheme.tealColor, // Filled Teal as per plan
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
               
               // Next / Place Order Button
               Expanded(
                 child: InkWell(
                   onTap: () {
                      if(provider.validatePaymentStep()) {
                          if (provider.isLastStep) {
                              _submitOrder(context, provider);
                          } else {
                              provider.nextStep();
                          }
                      } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppMessages.pleaseSelectPaymentMethod)));
                      }
                   },
                   child: Container(
                     height: 45.h,
                     decoration: BoxDecoration(
                       color: AppTheme.tealColor,
                       borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         if(provider.isLoading)
                            SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                         else ...[
                            Text(provider.isLastStep ? "Place Order" : "Next", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                            if(!provider.isLastStep) ...[
                               SizedBox(width: 8.w),
                               Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
                            ]
                         ]
                       ],
                     ),
                   ),
                 ),
               ),
            ],
          ),
          
          SizedBox(height: 30.h),
          
          if(provider.isLastStep)
             Padding(
               padding: EdgeInsets.only(bottom: 20.h),
               child: Center(child: Text("By placing an order you agree to our Terms", style: TextStyle(color: Colors.grey, fontSize: 12.sp))),
             ),
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
  
  void _submitOrder(BuildContext context, CheckoutProvider provider) async {
       // Assuming createOrder returns Map<String, dynamic>?
       final response = await provider.createOrder();
       if(!context.mounted) return;
       
       if(response != null && response['status'] == 200) {
           context.go(AppRoutes.orderSuccess, extra: response);
       } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage.isNotEmpty ? provider.errorMessage : "Order Failed")));
       }
  }
}
