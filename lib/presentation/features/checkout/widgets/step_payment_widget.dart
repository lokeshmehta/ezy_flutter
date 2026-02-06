
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/checkout_provider.dart';


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
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5.r),
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
                      borderRadius: BorderRadius.circular(5.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
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
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coupon Applied!")));
                       }
                 },
                style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.teal,
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                   padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w)
                ),
                child: provider.isLoading 
                    ? SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text("Apply"),
              )
            ],
          ),
          if(provider.errorMessage.isNotEmpty)
             Padding(
               padding: EdgeInsets.only(top: 5.h),
               child: Text(provider.errorMessage, style: TextStyle(color: Colors.red, fontSize: 12.sp)),
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
                borderRadius: BorderRadius.circular(5.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          Divider(),
          // Price Breakdown
          _buildPriceRow("Sub Total", provider.subTotal),
          if (double.tryParse(provider.discount) != 0)
              _buildPriceRow("Discount", "- ${provider.discount}", color: Colors.green),
          
          if (double.tryParse(provider.couponDiscount) != 0)
              _buildPriceRow("Coupon (${provider.couponName})", "- ${provider.couponDiscount}", color: Colors.green),

          if (double.tryParse(provider.shippingCharge) != 0)
              _buildPriceRow("Shipping", provider.shippingCharge),
          
          if (double.tryParse(provider.supplierCharge) != 0)
              _buildPriceRow("Supplier Surcharge", provider.supplierCharge),

          if (double.tryParse(provider.taxTotal) != 0)
              _buildPriceRow("Tax (GST)", provider.taxTotal),
          
          Divider(thickness: 1),
          _buildPriceRow("Total Amount", provider.totalAmount, isBold: true, size: 16.sp),
          
          SizedBox(height: 30.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                      provider.previousStep();
                  },
                  style: OutlinedButton.styleFrom(
                     padding: EdgeInsets.symmetric(vertical: 16.h),
                     side: BorderSide(color: Colors.teal),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                  ),
                  child: Text("BACK", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.teal)),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                      if(provider.validatePaymentStep()) {
                          provider.nextStep();
                      } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a payment method")));
                      }
                  },
                  style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.teal,
                     foregroundColor: Colors.white,
                     padding: EdgeInsets.symmetric(vertical: 16.h),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                  ),
                  child: Text("NEXT", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          SizedBox(height: 80.h),
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
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color color = Colors.black, double? size}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: size ?? 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: size ?? 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
