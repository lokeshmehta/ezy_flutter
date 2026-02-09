import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../config/routes/app_routes.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  const OrderSuccessScreen({super.key, required this.orderData});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  
  @override
  void initState() {
    super.initState();
    // Clear cart on success? 
    // Usually done by Provider after CreateOrder success, but we can ensure it here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
         context.read<CheckoutProvider>().clearCartLocal();
         // Also refresh My Orders?
         // context.read<OrdersProvider>().fetchOrders(1);
    });
  }
  
  void _showSendReceiptDialog() {
      final emailController = TextEditingController();
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
              title: const Text("Send Receipt"),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      const Text("Enter email addresses separated by comma"),
                      SizedBox(height: 10.h),
                      TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                              hintText: "example@email.com, test@email.com",
                              border: OutlineInputBorder()
                          ),
                      )
                  ],
              ),
              actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                  ),
                  TextButton(
                      onPressed: () async {
                          final emails = emailController.text.trim();
                          if (emails.isNotEmpty) {
                              Navigator.pop(ctx);
                              final success = await context.read<CheckoutProvider>().sendOrderReceipt(
                                   widget.orderData['order_id'], 
                                   emails
                              );
                              if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Email has been sent successfully"))
                                  );
                              }
                          }
                      },
                      child: const Text("Send"),
                  ),
              ],
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderData['order_id'] ?? "";
    final transId = widget.orderData['transaction_id'] ?? "";
    // final paymentType = widget.orderData['payment_type'] ?? "";
    
    // Payment Status handling (if passed)
    // Assuming successful order placement gets us here.

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text("Congratulations", style: TextStyle(color: AppTheme.white)),
        backgroundColor: AppTheme.orderSuccessTeal,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.check_circle, color: AppTheme.successGreen, size: 80.sp),
               SizedBox(height: 20.h),
               Text(
                   "Thank You!", 
                   style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppTheme.orderSuccessTeal)
               ),
               SizedBox(height: 10.h),
               Text(
                   "Your Order Placed Successfully",
                   style: TextStyle(fontSize: 18.sp, color: AppTheme.textColor),
                   textAlign: TextAlign.center,
               ),
               SizedBox(height: 20.h),
               Text(
                   "Order ID : #$orderId",
                   style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
               ),
               if (transId.isNotEmpty && transId != "null") ...[
                   SizedBox(height: 8.h),
                   Text(
                       "Transaction ID : $transId",
                       style: TextStyle(fontSize: 14.sp, color: AppTheme.darkGrayColor),
                   ),
               ],
               SizedBox(height: 40.h),
               
               // Buttons
               SizedBox(
                   width: double.infinity,
                   height: 45.h,
                   child: ElevatedButton(
                       onPressed: () {
                           context.read<DashboardProvider>().setIndex(1);
                           context.go(AppRoutes.dashboard); 
                       },
                       style: ElevatedButton.styleFrom(
                           backgroundColor: AppTheme.orderSuccessTeal,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                       ),
                       child: const Text("Continue Shopping", style: TextStyle(color: AppTheme.white)),
                   ),
               ),
               SizedBox(height: 16.h),
               SizedBox(
                   width: double.infinity,
                   height: 45.h,
                   child: OutlinedButton.icon(
                       onPressed: _showSendReceiptDialog,
                       icon: const Icon(Icons.email_outlined, color: AppTheme.orderSuccessTeal),
                       label: const Text("Send Receipt", style: TextStyle(color: AppTheme.orderSuccessTeal)),
                       style: OutlinedButton.styleFrom(
                           side: const BorderSide(color: AppTheme.orderSuccessTeal),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                       ),
                   ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
