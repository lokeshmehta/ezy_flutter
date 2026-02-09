
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/checkout_provider.dart';



class StepPreviewWidget extends StatefulWidget {
  const StepPreviewWidget({super.key});

  @override
  State<StepPreviewWidget> createState() => _StepPreviewWidgetState();
}

class _StepPreviewWidgetState extends State<StepPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    // Parity Filter: supplier_available == "Yes" && product_available == "Yes" (or "1" / "Yes" depending on API)
    // Android: items are filtered in Adapter or View? 
    // Android logic: It shows all items in Cart, but maybe filters for Preview? 
    // Actually Android ProceedToBuyActivity (Step 4 Preview) shows "Review Items".
    // I shall use provider.cartItems.
    
    final validItems = provider.cartItems; // Show all items for now, or filter if checked against API
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Review Items"),
          SizedBox(height: 10.h),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: validItems.length,
            itemBuilder: (ctx, i) {
                final item = validItems[i];
                return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                        leading: Image.network(item.image ?? "", width: 50.w, height: 50.w, errorBuilder: (_,__,___) => Icon(Icons.image)),
                        title: Text(item.title ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp)),
                        subtitle: Text("Qty: ${item.qty} | ${item.orderedAs}", style: TextStyle(fontSize: 12.sp)),
                        trailing: Text("\$${item.salePrice}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    ),
                );
            },
          ),
          
          SizedBox(height: 20.h),
          _buildSectionTitle("Order Summary"),
          SizedBox(height: 10.h),
          // Price Breakdown (Duplicated from Payment Step for Parity)
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
                  onPressed: provider.isLoading 
                     ? null 
                     : () async {
                         final response = await provider.createOrder();
                         if(!context.mounted) return;
                         
                         if(response != null) {
                            // Success Logic
                            // Navigate to Success Screen passing response data
                            // response contains 'order_id', 'transaction_id', etc.
                            // We construct the data map needed.
                            final orderData = {
                                'order_id': response['order_id'], // Adjust key based on API actual response
                                'transaction_id': response['transaction_id'], 
                                'payment_type': provider.paymentMethod,
                                'success_msg': response['message']
                            };
                            
                            // Also provider.clearCartLocal() should be called?
                            // OrderSuccessScreen does it in initState.
                            
                            context.go('/order-success', extra: orderData);
                         } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red)
                             );
                         }
                  },
                  style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.teal,
                     foregroundColor: Colors.white,
                     padding: EdgeInsets.symmetric(vertical: 16.h),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                  ),
                  child: provider.isLoading 
                      ? CircularProgressIndicator(color: Colors.white) 
                      : Text("SUBMIT ORDER", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
