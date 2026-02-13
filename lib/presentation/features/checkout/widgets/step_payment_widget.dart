import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_messages.dart';
import '../../../widgets/custom_loader_widget.dart';


class StepPaymentWidget extends StatefulWidget {
  const StepPaymentWidget({super.key});

  @override
  State<StepPaymentWidget> createState() => _StepPaymentWidgetState();
}

class _StepPaymentWidgetState extends State<StepPaymentWidget> {

  @override
  void initState() {
    super.initState();
    // Payment method default selection is now handled in CheckoutProvider._loadPaymentMethods()
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Order Summary" Header
          Row(
            children: [
              Icon(Icons.description_outlined, color: Color(0xFF0038FF), size: 20.sp), // Document Icon
              SizedBox(width: 8.w),
              Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0038FF), // Blue
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Main Card
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.r),
              boxShadow: [
                BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 5, spreadRadius: 1),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Additional Information
                _buildSectionTitle("Additional Information"),
                SizedBox(height: 5.h),
                Text("Order Notes", style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                SizedBox(height: 5.h),
                TextFormField(
                  controller: provider.orderNotesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Notes about your order, e.g special notes for delivery",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.r),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    contentPadding: EdgeInsets.all(10.w),
                  ),
                ),

                SizedBox(height: 15.h),

                // Use Coupon Code
                _buildSectionTitle("Use Coupon Code"),
                SizedBox(height: 5.h),
                Text("Enter your coupon code if you have one.", style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 40.h,
                        child: TextFormField(
                          controller: provider.couponController,
                          decoration: InputDecoration(
                            hintText: "Enter Promo Code",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 40.h,
                        child: ElevatedButton(
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
                             backgroundColor: Color(0xFFF5A623), // Orange
                             foregroundColor: Colors.white,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                             padding: EdgeInsets.zero,
                          ),
                          child: provider.isLoading 
                              ? SizedBox(width: 20.w, height: 20.w, child: const CustomLoaderWidget(size: 20)) 
                              : Text("Apply", style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                    )
                  ],
                ),
                if(provider.errorMessage.isNotEmpty)
                   Padding(
                     padding: EdgeInsets.only(top: 5.h),
                     child: Text(provider.errorMessage, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                   ),

                SizedBox(height: 15.h),

                // Order Details
                _buildSectionTitle("Order Details"),
                SizedBox(height: 10.h),
                // Price Breakdown logic (matching Step 1 refined)
                _buildSummaryRow(provider.cartResult?.subTotalHeading ?? "Sub-Total", "AUD ${provider.subTotal}"),
                
                // Ex GST (Blue)
                _buildSummaryRow("Ex. GST :", "AUD ${provider.subTotal}", isBlueValue: true), // Assuming logic same as step 1

                if((double.tryParse(provider.shippingCharge) ?? 0) > 0)
                   _buildSummaryRow("Shipping :", "AUD ${provider.shippingCharge}", isBlueValue: true),

                if((double.tryParse(provider.supplierCharge) ?? 0) > 0)
                   _buildSummaryRow("Supplier Charges :", "AUD ${provider.supplierCharge}", isBlueValue: true),
                   
                _buildSummaryRow("GST :", "AUD ${provider.taxTotal}", isBlueValue: true),
                
                if((double.tryParse(provider.couponDiscount) ?? 0) > 0)
                    _buildSummaryRow("Coupon (${provider.couponName})", "-AUD ${provider.couponDiscount}", isDiscount: true),
                
                SizedBox(height: 5.h),
                Text("Grand Total", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                _buildSummaryRow("Inc. GST :", "AUD ${provider.totalAmount}", isBlueValue: true),

                SizedBox(height: 15.h),
                
                // Payment Method
                _buildSectionTitle("Payment Method"),
                SizedBox(height: 5.h),
                Text("Choose Your Payment Method", style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700)),
                SizedBox(height: 5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), // Screenshot looks like black border
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: provider.paymentMethod.isNotEmpty && provider.availablePaymentMethods.contains(provider.paymentMethod) 
                          ? provider.paymentMethod 
                          : (provider.availablePaymentMethods.isNotEmpty ? provider.availablePaymentMethods[0] : null), // Safe fallback
                      icon: Icon(Icons.keyboard_arrow_down),
                      style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold),
                      items: provider.availablePaymentMethods.map((String value) {
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
                      hint: Text("Select Payment Method", style: TextStyle(color: Colors.grey)), 
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),
          
          // Navigation Buttons (Back | 3/3 | Place Order)
          Row(
            children: [
               // Back Button (Orange)
               Expanded(
                 flex: 3,
                 child: SizedBox(
                   height: 40.h,
                   child: ElevatedButton(
                     onPressed: () {
                        provider.previousStep();
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Color(0xFFF5A623), // Orange
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                       padding: EdgeInsets.zero,
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.arrow_back_ios, size: 14.sp, color: Colors.white),
                         Text(" Back", style: TextStyle(fontSize: 14.sp)),
                       ],
                     ),
                   ),
                 ),
               ),
               
               // 3/3 Indicator
               Expanded(
                 flex: 4,
                 child: Center(
                   child: Text("3/3", style: TextStyle(color: Color(0xFF0038FF), fontSize: 15.sp, fontWeight: FontWeight.bold)),
                 ),
               ),
               
               // Place Order Button (Orange)
               Expanded(
                 flex: 4,
                 child: SizedBox(
                   height: 40.h,
                   child: ElevatedButton(
                     onPressed: () {
                        if(provider.validatePaymentStep()) {
                            if(provider.isPreviewEnabled) {
                                provider.nextStep();
                            } else {
                                _submitOrder(context, provider);
                            }
                        } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppMessages.pleaseSelectPaymentMethod)));
                        }
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Color(0xFFF5A623), // Orange
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                       padding: EdgeInsets.zero,
                     ),
                     child: provider.isLoading 
                         ? SizedBox(width: 20.w, height: 20.w, child: const CustomLoaderWidget(size: 20)) 
                         : Text(provider.isPreviewEnabled ? "Review Order" : "Place Order", style: TextStyle(fontSize: 14.sp)),
                   ),
                 ),
               ),
            ],
          ),
          
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0038FF), // Blue
      ),
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
  
  void _submitOrder(BuildContext context, CheckoutProvider provider) async {
       final response = await provider.createOrder();
       if(!context.mounted) return;
       
       if(response != null && response['status'] == 200) {
           context.go(AppRoutes.orderSuccess, extra: response);
       } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage.isNotEmpty ? provider.errorMessage : "Order Failed")));
       }
  }
}
