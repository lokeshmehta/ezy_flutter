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
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              children: [
                                SizedBox(height: 20.h),
                                // Company Name
                                Text(
                                  provider.companyName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFFADD8E6), // @color/lightblue (Assuming light blue hex)
                                    // Android: textColor="@color/lightblue"
                                    // Need exact hex? Let's assume standard light blue or check colors.xml later if strict.
                                    // For now using a close approximation or theme if defined.
                                    // Let's use Color(0xFF4FC3F7) for light blue material.
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                
                                // Logo
                                if (imageUrl.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    height: 120.h, // @dimen/dimen_120
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => const SizedBox(),
                                    errorWidget: (context, url, error) => Image.asset(
                                       AppAssets.splashLogo, // Fallback
                                       height: 120.h,
                                    ),
                                  )
                                else 
                                  Image.asset(
                                     AppAssets.splashLogo,
                                     height: 120.h,
                                  ),

                                SizedBox(height: 20.h),

                                // User ID Label
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 3.w),
                                    child: Text(
                                      "User Id", // @string/userid_
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.h),

                                // User ID Input
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    hintText: provider.userNameHint, // Dynamic Hint
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                ),

                                SizedBox(height: 20.h),

                                // Password Label
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 3.w),
                                    child: Text(
                                      "Password", // @string/passwordv
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.h),

                                // Password Input
                                TextField(
                                  controller: _passwordController,
                                  obscureText: !provider.isPasswordVisible, // Simplified, Android didn't have toggle in xml shown but good for UX. Assuming standard password field.
                                  // Android xml: android:inputType="textPassword"
                                  decoration: InputDecoration(
                                    hintText: "Enter Your Password",
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.r),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                ),

                                SizedBox(height: 20.h),

                                // Forgot Password
                                GestureDetector(
                                  onTap: () {
                                    // Navigation: ForgotPasswordActivity
                                    // context.push('/forgot_password');
                                  },
                                  child: Text(
                                    "Forgot Password?", // @string/forgotpw (Dynamic in Android but typically constant text)
                                    style: TextStyle(
                                      color: const Color(0xFFF59300), // @color/yellow
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16.h),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 45.h,
                                  child: ElevatedButton(
                                    onPressed: provider.isLoading
                                        ? null
                                        : () async {
                                            final success = await provider.login(
                                              _emailController.text.trim(),
                                              _passwordController.text.trim(),
                                            );
                                            
                                            if (success && context.mounted) {
                                               context.go('/dashboard/home');
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF008080), // @color/tealcolor
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.r),
                                      ),
                                    ),
                                    child: provider.isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            "Login",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: 20.h),

                                // Sign Up Link
                                if (provider.isSignupRequired)
                                  GestureDetector(
                                    onTap: () {
                                      // context.push('/signup');
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Don’t have an account? ",
                                        style: TextStyle(color: Colors.black, fontSize: 14.sp),
                                        children: [
                                          TextSpan(
                                            text: "Sign Up",
                                            style: TextStyle(
                                              color: const Color(0xFFF59300),
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
                                    padding: EdgeInsets.only(top: 10.h),
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
                       color: Colors.white, // Parent background of bottom layout
                       child: InkWell(
                        onTap: () async {
                          await provider.clearSession();
                          if (context.mounted) {
                             // Route to companies list (Pending)
                             // context.go('/companies');
                             if (Navigator.canPop(context)) {
                               Navigator.pop(context); // Or go to Splash?
                               // Actually best to go to default route or Splash which redirects to companies if no url?
                               // Android goes to `CompaniesListActivity`.
                               // We'll mimic this by going to a route we haven't made yet.
                               // Temporary:
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text("Navigate to Companies List (Pending)")),
                               );
                             }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50.h,
                          margin: EdgeInsets.only(bottom: 30.h),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0), // @drawable/lightgray_bg approximation
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list, size: 18.w, color: Colors.black), // @drawable/listview_icon placeholder
                              SizedBox(width: 10.w),
                              Text(
                                "Access Other Stores",
                                style: TextStyle(
                                  color: AppTheme.primaryColor, // @color/blue
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
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
