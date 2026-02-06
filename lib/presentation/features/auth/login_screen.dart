import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/assets.dart';
import '../../../core/constants/url_api_key.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load Company Data (Name, Logo, Configs)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadCompanyData();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine Company Image URL logic from Android
    // if(prefs.Company_image.toString().contains("http")){ load direct }
    // else { load UrlApiKey.COMPANYMAIN_URL + prefs.Company_image }
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor, // @color/blue
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            String imageUrl = provider.companyImage;
            if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
               imageUrl = UrlApiKey.companyMainUrl + imageUrl;
            }

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.white, // Inner LinearLayout background
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                  // Company Name
                                Text(
                                  provider.companyName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.lightBlue, // @color/lightblue matches Android
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                
                                // Logo
                                if (imageUrl.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    height: 120, // @dimen/dimen_120
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const SizedBox(),
                                    errorWidget: (context, url, error) => Image.asset(
                                       AppAssets.logo, // Fallback
                                       height: 120,
                                    ),
                                  )
                                else 
                                  Image.asset(
                                     AppAssets.logo,
                                     height: 120,
                                  ),

                                SizedBox(height: 20),

                                // User ID Label
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 3),
                                    child: Text(
                                      "Username *", // @string/userid_
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),

                                // User ID Input
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: provider.userNameHint, // Dynamic Hint
                                    hintStyle: TextStyle(color: AppTheme.hintColor, fontSize: 14),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14, color: AppTheme.textColor),
                                ),

                                SizedBox(height: 20),

                                // Password Label
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 3),
                                    child: Text(
                                      "Password *", // @string/passwordv
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),

                                // Password Input
                                TextField(
                                  controller: _passwordController,
                                  obscureText: !provider.isPasswordVisible, 
                                  decoration: InputDecoration(
                                    hintText: "Enter Your Password",
                                    hintStyle: TextStyle(color: AppTheme.hintColor, fontSize: 14),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        provider.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: provider.togglePasswordVisibility,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14, color: AppTheme.textColor),
                                ),

                                SizedBox(height: 20),

                                // Forgot Password
                                GestureDetector(
                                  onTap: () {
                                    if (context.mounted) {
                                      context.push('/forgot_password');
                                    }
                                  },
                                  child: Align(
                                     alignment: AlignmentGeometry.centerLeft,
                                    child: Text(
                                      "Forgot Password?", // @string/forgotpw
                                      style: TextStyle(
                                        color: AppTheme.yellow, // @color/yellow
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16.h),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: provider.isLoading
                                        ? null
                                        : () async {
                                            final success = await provider.login(
                                              _emailController.text.trim(),
                                              _passwordController.text.trim(),
                                            );
                                            
                                            if (success && context.mounted) {
                                               context.go('/dashboard');
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.tealColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: provider.isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            "Login",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: 20),

                                // Sign Up Link
                                if (provider.isSignupRequired)
                                  GestureDetector(
                                    onTap: () {
                                      if (context.mounted) {
                                         context.push('/signup');
                                      }
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Don’t have an account? ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: "Sign Up",
                                            style: TextStyle(
                                              color: const Color(0xFFF59300),
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Error Message Display
                                if (provider.errorMessage != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      provider.errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom Section: Access Other Stores
                    Container(
                      width: double.infinity,
                      color: Colors.white, // Parent background
                      padding: const EdgeInsets.only(bottom: 30 , left: 90 , right: 90),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          await provider.clearSession();
                          if (context.mounted) {
                            context.go('/companies');
                          }
                        },
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.list,
                                size: 20,
                                color: Colors.black,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Access Other Stores",
                                style: TextStyle(
                                  color: AppTheme.primaryColor, // Blue text
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                
                // Loading Overlay (Global)
                if (provider.isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
