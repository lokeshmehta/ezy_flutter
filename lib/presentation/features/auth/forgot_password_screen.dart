import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/forgot_password_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/assets.dart';

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
                         color: Colors.white,
                         child: Column(
                           children: [
                             // Header Card
                             Card(
                               margin: const EdgeInsets.all(5),
                               elevation: 5,
                               color: Colors.white,
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
                                            context.go('/login');
                                         }
                                       },
                                       child: const Icon(Icons.arrow_back, color: Colors.black, size: 30), // @drawable/ic_leftarrow
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
                                                 "User Id", // @string/userid_
                                                 style: TextStyle(
                                                   color: AppTheme.primaryColor,
                                                   fontSize: 14,
                                                 ),
                                               ),
                                             ),
                                             const SizedBox(height: 5), // top_10 (padding inside was top_10) margin top 5

                                             // Input Field
                                             TextField(
                                               controller: provider.userIdController,
                                               decoration: InputDecoration(
                                                 hintText: "Enter Your User Id", // @string/enter_your_user_id
                                                 hintStyle: const TextStyle(color: AppTheme.hintColor, fontSize: 14),
                                                 filled: true,
                                                 fillColor: const Color(0xFFF2F2F2), // @drawable/edittext_bg usually light gray or white? Android xml says edittext_bg. Let's stick to standard gray/white.
                                                 contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                 border: OutlineInputBorder(
                                                   borderRadius: BorderRadius.circular(5),
                                                   borderSide: BorderSide.none,
                                                 ),
                                                 enabledBorder: OutlineInputBorder(
                                                   borderRadius: BorderRadius.circular(5),
                                                   borderSide: BorderSide.none,
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
                                                     borderRadius: BorderRadius.circular(5), // buttonbackground usually rounded rect
                                                   ),
                                                 ),
                                                 child: provider.isLoading 
                                                  ? const CircularProgressIndicator(color: Colors.white)
                                                  : const Text(
                                                     "Submit",
                                                     style: TextStyle(color: Colors.white, fontSize: 15),
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
