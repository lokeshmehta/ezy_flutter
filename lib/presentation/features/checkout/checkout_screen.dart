
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../../providers/checkout_provider.dart';
import 'widgets/step_cart_widget.dart';
import 'widgets/step_address_widget.dart';
import 'widgets/step_payment_widget.dart';
import 'widgets/step_preview_widget.dart';
import 'widgets/icon_stepper_widget.dart';
import '../../../../core/constants/app_theme.dart';

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
    
    String title = "My Cart";
    if(provider.currentStep == 1) title = "Shipping Address";
    if(provider.currentStep == 2) title = "Payment Method";
    if(provider.currentStep == 3) title = "Preview Order";

    return PopScope(
      canPop: provider.currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
         if(didPop) return;
         if(provider.currentStep > 0) {
            provider.previousStep();
         }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(title, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)), 
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
               if(provider.currentStep > 0) {
                  provider.previousStep();
               } else {
                  Navigator.pop(context);
               }
            },
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                IconStepperWidget(
                  currentStep: provider.currentStep,
                  totalSteps: provider.totalSteps,
                  onStepTapped: (step) {
                     // provider.setStep(step); // Strict flow - no jumping
                  },
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(), // Disable swipe
                    children: [
                      StepCartWidget(),
                      StepAddressWidget(),
                      StepPaymentWidget(),
                      if(provider.isPreviewEnabled)
                          StepPreviewWidget(),
                    ],
                  ),
                ),
              ],
            ),
            
            if (provider.isLoading)
              Container(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator(color: AppTheme.tealColor)),
              ),
          ],
        ),
      ),
    );
  }
}
