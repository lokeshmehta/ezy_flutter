import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/signup_provider.dart';
import '../../../core/constants/app_theme.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor, // @color/blue
      body: SafeArea(
        child: Column(
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
                               margin: EdgeInsets.all(5.w), // @dimen/dimens_5dp
                               elevation: 5,
                               color: Colors.white,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                               child: Container(
                                 height: 55.h, // @dimen/dimen_55
                                 padding: EdgeInsets.symmetric(horizontal: 15.w),
                                 alignment: Alignment.centerLeft,
                                 child: Row(
                                   children: [
                                     GestureDetector(
                                       onTap: () {
                                          if (context.mounted) {
                                            context.go('/login');
                                          }
                                       },
                                       child: Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 24.sp), // Placeholder for @drawable/ic_leftarrow which might be an image
                                     ),
                                     Expanded(
                                       child: Text(
                                         "Sign Up", // @string/sign_up
                                         textAlign: TextAlign.center,
                                         style: TextStyle(
                                           color: AppTheme.textColor, // @color/text_color
                                           fontSize: 18.sp, // @dimen/_18sdp
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                     ),
                                     SizedBox(width: 45.w), // Balance spacing @dimen/dimen_45
                                   ],
                                 ),
                               ),
                             ),

                             // Form Content
                             Expanded(
                               child: Container(
                                 color: Colors.white,
                                 child: SingleChildScrollView(
                                   padding: EdgeInsets.all(15.w), // @dimen/dimen_15
                                   child: Consumer<SignUpProvider>(
                                     builder: (context, provider, child) {
                                       return Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                            // Title
                                            _buildLabel("Title *"), // @string/title_
                                            SizedBox(height: 5.h),
                                            Container(
                                              height: 45.h,
                                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade400), // Spinner style approximation
                                                borderRadius: BorderRadius.circular(4.r), // Standard spinner look
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  value: provider.titleVal ?? "Select Title",
                                                  icon: const Icon(Icons.arrow_drop_down),
                                                  items: provider.titleOptions.map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value, style: TextStyle(fontSize: 14.sp)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    provider.setTitle(newValue);
                                                  },
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: 10.h),

                                            // First Name
                                            _buildLabel("First Name *"), // @string/first_name
                                            _buildTextField(provider.firstNameController, "Enter First Name", TextInputType.name),
                                            
                                            SizedBox(height: 10.h),
                                            
                                            // Last Name
                                            _buildLabel("Last Name *"), // @string/last_name_
                                            _buildTextField(provider.lastNameController, "Enter Last Name", TextInputType.name),

                                            SizedBox(height: 10.h),

                                            // Mobile
                                            _buildLabel("Mobile Number *"), // @string/mobile_number
                                            _buildTextField(provider.mobileController, "Enter Mobile Number", TextInputType.phone),

                                            SizedBox(height: 10.h),

                                            // Email
                                            _buildLabel(provider.emailRequired == "Yes" ? "Email *" : "Email"), // Dynamic Label from Provider
                                            _buildTextField(provider.emailController, "Enter Email", TextInputType.emailAddress),

                                            SizedBox(height: 10.h),

                                            // Order Emails
                                            _buildLabel("Order Email(s)"), // @string/orderemail_n (Assuming not mandatory unless noted, but Logic checks valid format)
                                            _buildTextField(provider.orderEmailsController, "Enter Order Email", TextInputType.emailAddress),
                                            
                                            SizedBox(height: 5.h),
                                            Text(
                                              "Note: Use comma (,) to separate multiple emails.", // @string/note
                                              style: TextStyle(
                                                color: Colors.red, // @color/redcolor
                                                fontSize: 12.sp, // @dimen/padding_12
                                              ),
                                            ),

                                            SizedBox(height: 10.h),

                                            // Password
                                            _buildLabel("Password *"), // @string/password_m
                                            _buildTextField(provider.passwordController, "Enter Password", TextInputType.visiblePassword, isPassword: true),

                                            SizedBox(height: 10.h),

                                            // Confirm Password
                                            _buildLabel("Confirm Password *"), // @string/cnfpassword_m
                                            _buildTextField(provider.confirmPasswordController, "Enter Confirm Password", TextInputType.visiblePassword, isPassword: true),

                                            SizedBox(height: 30.h),

                                            // Error Message Display (if any)
                                            if (provider.errorMsg != null)
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 10.h),
                                                child: Text(
                                                  provider.errorMsg!,
                                                  style: TextStyle(color: Colors.red, fontSize: 13.sp),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),

                                            // Submit Button
                                            SizedBox(
                                              width: double.infinity,
                                              height: 45.h, // @dimen/dimen_45
                                              child: ElevatedButton(
                                                onPressed: provider.isLoading ? null : () {
                                                  provider.submitSignUp(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.tealColor, // @color/tealcolor
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)), // Match buttonbackground (assuming pill or small radius, checking graybg used pill, buttonbackground usually similar) -> Android xml says `buttonbackground` which usually is rounded. Let's use 20.r to match Select Button.
                                                ),
                                                child: provider.isLoading
                                                    ? const CircularProgressIndicator(color: Colors.white)
                                                    : Text(
                                                        "Submit", // @string/submit
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                              ),
                                            ),

                                            SizedBox(height: 10.h),

                                            // Login Link
                                            Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                    if (context.mounted) {
                                                      context.go('/login');
                                                    }
                                                },
                                                child: Text(
                                                  "Login", // @string/login_small
                                                  style: TextStyle(
                                                    color: AppTheme.textColor,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            SizedBox(height: 20.h),
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 3.w), // @dimen/dimen_3
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.primaryColor, // @color/blue
          fontSize: 14.sp, // @dimen/_14sdp
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType inputType, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.only(top: 5.h), // @dimen/dimens_5
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        style: TextStyle(
          color: AppTheme.textColor,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp), // @color/hint_color
          filled: true,
          fillColor: const Color(0xFFF2F2F2), // Light gray bg match @drawable/edittext_bg usually
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h), // @dimen/padding_12
          border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(4.r), // Standard border radius
             borderSide: BorderSide.none, // Remove default border
          ),
          enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(4.r),
             borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
