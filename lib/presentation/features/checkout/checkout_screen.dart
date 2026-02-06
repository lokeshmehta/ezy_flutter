
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../../providers/checkout_provider.dart';
import 'widgets/step_address_widget.dart';
import 'widgets/step_payment_widget.dart';
import 'widgets/step_preview_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Initialize Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }
  
  Future<void> _initData() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.accessToken) ?? "";
      final userId = prefs.getString(StorageKeys.userId) ?? "";
      
      if(mounted) {
         context.read<CheckoutProvider>().initCheckout(userId, token);
      }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    
    // Sync PageController with Provider Step
    if (_pageController.hasClients && _pageController.page?.round() != provider.currentStep) {
       _pageController.jumpToPage(provider.currentStep);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildStepIndicator(provider.currentStep),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    StepAddressWidget(),
                    StepPaymentWidget(),
                    StepPreviewWidget(),
                  ],
                ),
              ),
            ],
          ),
          
          if (provider.isLoading)
            Container(
              color: Colors.black45,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    // Parity: Icons for Address, Payment, Preview (Cart is implicit/previous)
    // 0: Address, 1: Payment, 2: Preview
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepIcon(Icons.local_shipping, 0, currentStep), // Address
          _buildStepLine(0, currentStep),
          _buildStepIcon(Icons.payment, 1, currentStep), // Payment
          _buildStepLine(1, currentStep),
          _buildStepIcon(Icons.list_alt, 2, currentStep), // Preview
        ],
      ),
    );
  }

  Widget _buildStepIcon(IconData icon, int stepIndex, int currentStep) {
    bool isActive = currentStep >= stepIndex;
    bool isCurrent = currentStep == stepIndex;
    
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isActive ? Colors.teal : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: isCurrent ? Border.all(color: Colors.teal.shade800, width: 2.w) : null,
      ),
      child: Icon(icon, color: isActive ? Colors.white : Colors.grey.shade600, size: 24.sp),
    );
  }
  
  Widget _buildStepLine(int stepIndex, int currentStep) {
      bool isActive = currentStep > stepIndex;
      return Expanded(
          child: Container(
              height: 2.h,
              color: isActive ? Colors.teal : Colors.grey.shade300,
          )
      );
  }
}
