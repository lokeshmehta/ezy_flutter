import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart'; // Using DashboardProvider for now as per logic

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Visibility toggles
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
      final provider = context.read<DashboardProvider>();
      final oldPw = _oldPasswordController.text.trim();
      final newPw = _newPasswordController.text.trim();
      final confirmPw = _confirmPasswordController.text.trim();
      
      // Validation Logic matching Android (ChangePasswordActivity.kt)
      // 1. Check Empty
      if (oldPw.isEmpty) {
          _showError("Please enter your current password");
          return;
      }
      
      // 2. Check Match with Preference (Handled by API in Flutter, or we can check local prefs)
      // Android checks: `(!viewmodel?.old_pw?.get()!!.toString().trim().equals(prefs.User_Password))`
      // Since we don't expose raw password in Prefs (security risk), we rely on API or if we stored it (bad practice).
      // Assuming API handles validation of old password. 
      // ANDROID CODE REVEAL: It checks `prefs.User_Password`. This implies app stores password locally.
      // I will skip local check for security best practice unless strictly required. 
      // Flow: API will return error if old password wrong.
      
      if (newPw.isEmpty) {
           _showError("Please enter a new password");
           return;
      }
      
      if (confirmPw.isEmpty) {
           _showError("Please confirm your new password");
           return;
      }
      
      if (newPw != confirmPw) {
           _showError("Password does not match");
           return;
      }
      
      if (oldPw == newPw) {
           _showError("New password cannot be the same as old password");
           return;
      }
      
      // Call API
      bool success = await provider.changePassword(oldPw, newPw);
      
      if (!mounted) return;
      
      if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Password has been updated successfully")),
          );
          context.pop(); // Go back
      } else {
          _showError(provider.errorMsg ?? "An error occurred");
      }
  }
  
  void _showError(String message) {
      if(message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    // Replicating Layout from Android XML likely (Simple form)
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF008080), // Teal color
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
                SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                             SizedBox(height: 20.h),
                             // Old Password
                             _buildLabel("Current Password"),
                             _buildPasswordField(_oldPasswordController, _oldPasswordVisible, (val) {
                                 setState(() => _oldPasswordVisible = val);
                             }),
                             SizedBox(height: 20.h),
                             
                             // New Password
                             _buildLabel("New Password"),
                             _buildPasswordField(_newPasswordController, _newPasswordVisible, (val) {
                                 setState(() => _newPasswordVisible = val);
                             }),
                             SizedBox(height: 20.h),
                             
                             // Confirm Password
                             _buildLabel("Confirm Password"),
                             _buildPasswordField(_confirmPasswordController, _confirmPasswordVisible, (val) {
                                 setState(() => _confirmPasswordVisible = val);
                             }),
                             SizedBox(height: 40.h),
                             
                             // Submit Button
                             SizedBox(
                                 width: double.infinity,
                                 height: 50.h,
                                 child: ElevatedButton(
                                     onPressed: provider.isLoading ? null : _onSubmit,
                                     style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF008080),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                     ),
                                     child: Text(
                                        "Save",
                                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)
                                     ),
                                 ),
                             ),
                        ],
                    ),
                ),
                if(provider.isLoading)
                   Container(
                       color: Colors.black12,
                       child: const Center(child: CircularProgressIndicator()),
                   )
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildLabel(String text) {
      return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(text, style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
      );
  }
  
  Widget _buildPasswordField(TextEditingController controller, bool isVisible, Function(bool) onToggle) {
      return TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey[300]!)
              ),
              enabledBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8.r),
                   borderSide: BorderSide(color: Colors.grey[300]!)
              ),
              focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8.r),
                   borderSide: const BorderSide(color: Color(0xFF008080))
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              suffixIcon: IconButton(
                  icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  onPressed: () => onToggle(!isVisible),
              ),
          ),
      );
  }
}
