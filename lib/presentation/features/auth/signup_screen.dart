import 'package:flutter/material.dart';
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
                                         "Sign Up", // @string/sign_up
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
                                            _buildLabel("Title *"), // @string/title_
                                            SizedBox(height: 5),
                                            Container(
                                              height: 45,
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey.shade400), // Spinner style approximation
                                                borderRadius: BorderRadius.circular(4), // Standard spinner look
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
                                            _buildLabel("First Name *"), // @string/first_name
                                            _buildTextField(provider.firstNameController, "Enter Your First Name", TextInputType.name),
                                            
                                            SizedBox(height: 10),
                                            
                                            // Last Name
                                            _buildLabel("Last Name *"), // @string/last_name_
                                            _buildTextField(provider.lastNameController, "Enter Your Last Name", TextInputType.name),

                                            SizedBox(height: 10),

                                            // Mobile
                                            _buildLabel("Mobile Number *"), // @string/mobile_number
                                            _buildTextField(provider.mobileController, "Enter Your Mobile Number", TextInputType.phone),

                                            SizedBox(height: 10),

                                            // Email
                                            _buildLabel(provider.emailRequired == "Yes" ? "Email *" : "Email"), // Dynamic Label from Provider
                                            _buildTextField(provider.emailController, "Enter Your Email", TextInputType.emailAddress),

                                            SizedBox(height: 10),

                                            // Order Emails
                                            _buildLabel("Order Receipt Email(s)"), // @string/orderemail_n (Assuming not mandatory unless noted, but Logic checks valid format)
                                            _buildTextField(provider.orderEmailsController, "Enter Your Order Receipt Email(s)", TextInputType.emailAddress),
                                            
                                            SizedBox(height: 5),
                                            Text(
                                              "Note : Please add Email(s) in comma separated", // @string/note
                                              style: TextStyle(
                                                color: Colors.red, // @color/redcolor
                                                fontSize: 12, // @dimen/padding_12
                                              ),
                                            ),

                                            SizedBox(height: 10),

                                            // Password
                                            _buildLabel("Password *"), // @string/password_m
                                            _buildTextField(provider.passwordController, "Enter Your Password", TextInputType.visiblePassword, isPassword: true),

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
                                                  style: TextStyle(color: Colors.red, fontSize: 13),
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
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Match buttonbackground (assuming pill or small radius, checking graybg used pill, buttonbackground usually similar) -> Android xml says `buttonbackground` which usually is rounded. Let's use 20.r to match Select Button.
                                                ),
                                                child: provider.isLoading
                                                    ? const CircularProgressIndicator(color: Colors.white)
                                                    : Text(
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
                                                      context.go('/login');
                                                    }
                                                },
                                                child: RichText(
                                                  text: TextSpan(
                                                    text: "Already have an account? ",
                                                    style: TextStyle(
                                                      color: Colors.black, // Match screenshot text color
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
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFFFFFFF), // White background
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

          // Black rectangular border
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
    );
  }
}
