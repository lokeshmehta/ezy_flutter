import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/dashboard_provider.dart';

import 'package:lottie/lottie.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
         context.read<CheckoutProvider>().clearCartLocal();
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
                          decoration: InputDecoration(
                              hintText: "example@email.com, test@email.com",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r))
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
    final orderId = widget.orderData['order_id'] ?? widget.orderData['refNo'] ?? ""; // Handle both keys

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            "Order Success", 
            style: TextStyle(color: const Color(0xFF0038FF), fontWeight: FontWeight.bold, fontSize: 18.sp)
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // Blue Circle Icon / Lottie Animation
             SizedBox(
                 width: 220.w, // Matching android dimens_220
                 height: 220.w,
                 child: Lottie.asset(
                    'assets/animations/congrats_check.json',
                    repeat: true,
                    reverse: false,
                    animate: true,
                 ),
             ),


             // Main Message
             Text(
                 "Thank you for submitting your order.\nWe will validate with the supplier\nand give you the order delivery\nconfirmation.",
                 style: TextStyle(
                     fontSize: 16.sp, 
                     color: const Color(0xFF1D2671), // Dark Blue text
                     fontWeight: FontWeight.w600,
                     height: 1.5
                 ),
                 textAlign: TextAlign.center,
             ),
             SizedBox(height: 40.h),

             // Order ID
             Text(
                 "Order ID : #$orderId",
                 style: TextStyle(
                     fontSize: 16.sp, 
                     fontWeight: FontWeight.bold,
                     color: const Color(0xFF2E7D32) // Green color
                 ),
             ),
             
             SizedBox(height: 50.h),
             
             // Send Order Receipt Email Button (Orange)
             SizedBox(
                 width: double.infinity,
                 height: 45.h,
                 child: ElevatedButton(
                     onPressed: _showSendReceiptDialog,
                     style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFFF5A623), // Orange
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                         elevation: 2,
                     ),
                     child: Text("Send Order Receipt Email", style: TextStyle(fontSize: 14.sp)),
                 ),
             ),
             SizedBox(height: 15.h),

             // Back to Home Button (Dark Blue)
             SizedBox(
                 width: double.infinity,
                 height: 45.h,
                 child: ElevatedButton(
                     onPressed: () {
                         context.read<DashboardProvider>().setIndex(0); // Home Tab
                         context.go(AppRoutes.dashboard); 
                     },
                     style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF1D2671), // Dark Blue
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                         elevation: 2,
                     ),
                     child: Text("Back to Home", style: TextStyle(fontSize: 14.sp)),
                 ),
             ),
          ],
        ),
      ),
    );
  }
}
