import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../dashboard/dashboard_screen.dart';


class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillData();
    });
  }

  void _prefillData() {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final profile = provider.profileResponse?.results?.isNotEmpty == true
        ? provider.profileResponse!.results![0]
        : null;

    if (profile != null) {
      String fullName = profile.firstName ?? "";
      if (profile.lastName != null) fullName += " ${profile.lastName}";
      if (profile.lastName != null) fullName += " ${profile.lastName}";
      _nameController.text = fullName.trim();
      _emailController.text = profile.email ?? "";
      _mobileController.text = profile.mobile ?? "";
      // Email is not a field in the form? 
      // Android code: name, phone, subject, message. 
      // ViewModel also has email variable but XML only shows these 4 fields?
      // SendFeedbackActivity.kt line 103-114 checks name, phone, subject, message.
      // So UI only has these 4.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      
      final success = await provider.sendFeedback(
        name: _nameController.text,
        email: _emailController.text,
        phone: _mobileController.text,
        subject: _subjectController.text,
        message: _messageController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Your feedback has been sent successfully")),
           );
           // Navigate back to Dashboard
           Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (c) => const DashboardScreen()),
             (route) => false
           );
        }
      } else {
         if (mounted) {
            final error = provider.errorMsg ?? "Failed to send feedback";
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Send Feedback",
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Name", _nameController, "Please enter name"),
              SizedBox(height: 15.h),
              _buildTextField("Email", _emailController, "Please enter email key", keyboardType: TextInputType.emailAddress),
              SizedBox(height: 15.h),
              _buildTextField("Mobile Number", _mobileController, "Please enter mobile number", keyboardType: TextInputType.phone),
              SizedBox(height: 15.h),
              _buildTextField("Subject", _subjectController, "Please enter subject"),
              SizedBox(height: 15.h),
              _buildTextField("Message", _messageController, "Please enter message", maxLines: 5),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tealColor,
                    minimumSize: Size(double.infinity, 45.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? SizedBox(width: 20.w, height: 20.w, child: CircularProgressIndicator(color: Colors.white))
                    : Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String errorMsg, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
        ),
        SizedBox(height: 5.h),*/ 
        // Android typically uses Hint inside EditText.
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) return errorMsg;
            return null;
          },
          decoration: InputDecoration(
             labelText: label,
             alignLabelWithHint: true,
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
               borderSide: BorderSide(color: Colors.grey[400]!),
             ),
             enabledBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
               borderSide: BorderSide(color: Colors.grey[400]!),
             ),
             focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
               borderSide: BorderSide(color: AppTheme.primaryColor),
             ),
             filled: true,
             fillColor: Colors.grey[50],
             contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }
}
