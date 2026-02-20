import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/signup_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_messages.dart';
import '../../widgets/custom_loader_widget.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor, // @color/blue
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppTheme.primaryColor,
                child: Column(
                   children: [
                     Expanded(
                       child: Container(
                         width: double.infinity,
                         color: Colors.white,
                         child: Column(
                           children: [
                             // Header Card
                             Card(
                               margin: EdgeInsets.all(5), // @dimen/dimens_5dp
                               elevation: 5,
                               color: Colors.white,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                               child: Container(
                                 height: 55, // @dimen/dimen_55
                                 padding: EdgeInsets.symmetric(horizontal: 15),
                                 alignment: Alignment.centerLeft,
                                 child: Row(
                                   children: [
                                     GestureDetector(
                                       onTap: () {
                                          if (context.mounted) {
                                            context.go('/login');
                                          }
                                       },
                                       child: Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 24), // Placeholder for @drawable/ic_leftarrow which might be an image
                                     ),
                                     Expanded(
                                       child: Text(
                                         AppMessages.signUp, // @string/sign_up
                                         textAlign: TextAlign.center,
                                         style: TextStyle(
                                           color: AppTheme.textColor, // @color/text_color
                                           fontSize: 18, // @dimen/_18sdp
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                     ),
                                     SizedBox(width: 45), // Balance spacing @dimen/dimen_45
                                   ],
                                 ),
                               ),
                             ),

                             // Form Content
                             Expanded(
                               child: Container(
                                 color: Colors.white,
                                 child: SingleChildScrollView(
                                   padding: EdgeInsets.all(15), // @dimen/dimen_15
                                   child: Consumer<SignUpProvider>(
                                     builder: (context, provider, child) {
                                       return Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                             // Title
                                            _buildLabel(AppMessages.titleMsg), // @string/title_
                                            SizedBox(height: 5),
                                            Container(
                                              height: 45,
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: AppTheme.hintColor),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  value: provider.titleVal ?? "Select Title",
                                                  icon: const Icon(Icons.arrow_drop_down),
                                                  items: provider.titleOptions.map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value, style: TextStyle(fontSize: 14)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    provider.setTitle(newValue);
                                                  },
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: 10),

                                             // First Name
                                            _buildLabel(AppMessages.firstName), // @string/first_name
                                            _buildTextField(provider.firstNameController, AppMessages.firstNameHint, TextInputType.name),
                                            
                                            SizedBox(height: 10),
                                            
                                            // Last Name
                                            _buildLabel(AppMessages.lastName), // @string/last_name_
                                            _buildTextField(provider.lastNameController, AppMessages.lastNameHint, TextInputType.name),

                                            SizedBox(height: 10),

                                            // Mobile
                                            _buildLabel(AppMessages.mobileNumber), // @string/mobile_number
                                            _buildTextField(provider.mobileController, AppMessages.mobileHint, TextInputType.phone),

                                            SizedBox(height: 10),

                                            // Email
                                            _buildLabel("${AppMessages.email}${provider.emailRequired == "Yes" ? " *" : ""}"), 
                                            _buildTextField(provider.emailController, AppMessages.emailHint, TextInputType.emailAddress),

                                            SizedBox(height: 10),

                                            // Order Emails
                                            _buildLabel(AppMessages.orderReceiptEmails), 
                                            _buildTextField(provider.orderEmailsController, AppMessages.orderEmailsHint, TextInputType.emailAddress),
                                            
                                            SizedBox(height: 5),
                                            Text(
                                              "Note : Please add Email(s) in comma separated", // @string/note
                                              style: TextStyle(
                                                color: AppTheme.redColor,
                                                fontSize: 12,
                                              ),
                                            ),

                                            SizedBox(height: 10),

                                            // Password
                                            _buildLabel(AppMessages.password), // @string/password_m
                                            _buildTextField(provider.passwordController, AppMessages.passwordHint, TextInputType.visiblePassword, isPassword: true),

                                            SizedBox(height: 10),

                                            // Confirm Password
                                            _buildLabel("Confirm Password *"), // @string/cnfpassword_m
                                            _buildTextField(provider.confirmPasswordController, "Enter Your Password Again", TextInputType.visiblePassword, isPassword: true),

                                            SizedBox(height: 30),

                                            // Error Message Display (if any)
                                            if (provider.errorMsg != null)
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                  provider.errorMsg!,
                                                  style: TextStyle(color: AppTheme.redColor, fontSize: 13),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),

                                            // Submit Button
                                            SizedBox(
                                              width: double.infinity,
                                              height: 45, // @dimen/dimen_45
                                              child: ElevatedButton(
                                                onPressed: provider.isLoading ? null : () {
                                                  provider.submitSignUp(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.tealColor, // @color/tealcolor
                                                  minimumSize: Size(double.infinity, 45.h),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius)),
                                                ),
                                                child: Text(
                                                        "Submit", // @string/submit
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                              ),
                                            ),

                                            SizedBox(height: 10),

                                            // Login Link
                                            Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                    if (context.mounted) {
                                                      context.go(AppRoutes.login);
                                                    }
                                                },
                                                child: RichText(
                                                  text: TextSpan(
                                                    text: "Already have an account? ",
                                                    style: TextStyle(
                                                      color: AppTheme.blackColor, // Match screenshot text color
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Roboto', 
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: "Login",
                                                        style: TextStyle(
                                                          color: AppTheme.tealColor, // Orange/Gold
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            SizedBox(height: 20),
                                         ],
                                       );
                                     },
                                   ),
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
            // Loading Overlay
            // Loading Overlay
            Consumer<SignUpProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Container(
                    color: Colors.black54,
                    child: Center(
                      child: SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                             CustomLoaderWidget(size: 100.w),
                             Text(
                               "Please Wait",
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                 color: AppTheme.primaryColor,
                                 fontSize: 13.sp,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 3), // @dimen/dimen_3
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.primaryColor, // @color/blue
          fontSize: 14, // @dimen/_14sdp
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType inputType, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.only(top: 5), // @dimen/dimens_5
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        style: TextStyle(
          color: AppTheme.textColor,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.hintColor, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFFFFFFF), // White background
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

          // Black rectangular border
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
            borderSide: const BorderSide(color: AppTheme.blackColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
            borderSide: const BorderSide(color: AppTheme.blackColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
            borderSide: const BorderSide(color: AppTheme.blackColor, width: 2),
          ),
        ),
      ),
    );
  }
}
