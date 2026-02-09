import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/forgot_password_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/assets.dart';
import '../../../config/routes/app_routes.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor, // @color/blue
      body: SafeArea(
        child: Column(
          children: [
             // Outer Layout
             Expanded(
               child: Container(
                 color: AppTheme.primaryColor,
                 child: Column(
                   children: [
                     Expanded(
                       child: Container(
                         color: AppTheme.white,
                         child: Column(
                           children: [
                             // Header Card
                             Card(
                               margin: const EdgeInsets.all(5),
                               elevation: 5,
                               color: AppTheme.white,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                               child: Container(
                                 height: 55,
                                 padding: const EdgeInsets.symmetric(horizontal: 10),
                                 alignment: Alignment.centerLeft,
                                 child: Row(
                                   children: [
                                     GestureDetector(
                                       onTap: () {
                                         if (context.mounted) {
                                            context.go(AppRoutes.login);
                                         }
                                       },
                                       child: const Icon(Icons.arrow_back, color: AppTheme.blackColor, size: 30), 
                                     ),
                                     const Expanded(
                                       child: Text(
                                         "Forgot Password",
                                         textAlign: TextAlign.center,
                                         style: TextStyle(
                                           color: AppTheme.textColor,
                                           fontSize: 18,
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                     ),
                                     const SizedBox(width: 45), // Balance spacing
                                   ],
                                 ),
                               ),
                             ),

                             // Content
                             Expanded(
                               child: SingleChildScrollView(
                                 padding: const EdgeInsets.all(20),
                                 child: Consumer<ForgotPasswordProvider>(
                                   builder: (context, provider, child) {
                                     return Column(
                                       children: [
                                         // Logo
                                         const SizedBox(height: 20),
                                         Image.asset(
                                            AppAssets.forgotIcon,
                                            height: 200,
                                            width: 200,
                                         ),
                                         const SizedBox(height: 30),

                                         // Form Container
                                         Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: [
                                             // Label
                                             const Padding(
                                               padding: EdgeInsets.only(left: 3),
                                               child: Text(
                                                 "Username *", 
                                                 style: TextStyle(
                                                   color: AppTheme.primaryColor,
                                                   fontSize: 14,
                                                 ),
                                               ),
                                             ),
                                             const SizedBox(height: 5), 

                                             // Input Field
                                             TextField(
                                               controller: provider.userIdController,
                                               decoration: InputDecoration(
                                                 hintText: "Enter your Email ID/Mobile Number", 
                                                 hintStyle: const TextStyle(color: AppTheme.hintColor, fontSize: 14),
                                                 filled: true,
                                                 fillColor: AppTheme.white,
                                                 contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                 border: OutlineInputBorder(
                                                   borderRadius: BorderRadius.circular(4),
                                                   borderSide: const BorderSide(color: AppTheme.blackColor, width: 1),
                                                 ),
                                                 enabledBorder: OutlineInputBorder(
                                                   borderRadius: BorderRadius.circular(4),
                                                   borderSide: const BorderSide(color: AppTheme.blackColor, width: 1),
                                                 ),
                                                 focusedBorder: OutlineInputBorder(
                                                   borderRadius: BorderRadius.circular(4),
                                                   borderSide: const BorderSide(color: AppTheme.blackColor, width: 2),
                                                 ),
                                               ),
                                               style: const TextStyle(
                                                 color: AppTheme.textColor,
                                                 fontSize: 14,
                                               ),
                                             ),

                                             const SizedBox(height: 50),

                                             // Submit Button
                                             SizedBox(
                                               width: double.infinity,
                                               height: 45,
                                               child: ElevatedButton(
                                                 onPressed: provider.isLoading ? null : () => provider.submit(context),
                                                 style: ElevatedButton.styleFrom(
                                                   backgroundColor: AppTheme.tealColor,
                                                   shape: RoundedRectangleBorder(
                                                     borderRadius: BorderRadius.circular(5), 
                                                   ),
                                                 ),
                                                 child: provider.isLoading 
                                                  ? const CircularProgressIndicator(color: AppTheme.white)
                                                  : const Text(
                                                     "Submit",
                                                     style: TextStyle(color: AppTheme.white, fontSize: 14),
                                                   ),
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     );
                                   },
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
