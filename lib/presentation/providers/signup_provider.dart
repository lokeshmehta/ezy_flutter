import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/service_locator.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/constants/storage_keys.dart';
import '../../config/routes/app_routes.dart';

import '../../core/constants/app_messages.dart';

class SignUpProvider extends ChangeNotifier {
  final AuthRepository _repository = getIt<AuthRepository>();

  // Text Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController orderEmailsController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _errorMsg;
  String? _titleVal;
  String _emailRequired = "No"; // Default from Android init
  
  // Options
  final List<String> titleOptions = ["Select Title", "Mr", "Ms.", "Mrs", "Miss"];

  bool get isLoading => _isLoading;
  String? get errorMsg => _errorMsg;
  String? get titleVal => _titleVal;
  String get emailRequired => _emailRequired;

  SignUpProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _emailRequired = prefs.getString(StorageKeys.emailRequired) ?? "No";
    notifyListeners();
  }

  void setTitle(String? value) {
    if (value != "Select Title") {
      _titleVal = value;
    } else {
      _titleVal = null;
    }
    notifyListeners();
  }

  Future<void> submitSignUp(BuildContext context) async {
    _errorMsg = null;

    // Validation matching Android saveEventClick
    if (_titleVal == null || _titleVal!.isEmpty) {
      _setError(AppMessages.pleaseSelectTitle);
      return;
    }
    if (firstNameController.text.trim().isEmpty) {
      _setError(AppMessages.pleaseEnterFirstName);
      return;
    }
    if (lastNameController.text.trim().isEmpty) {
      _setError(AppMessages.pleaseEnterLastName);
      return;
    }
    if (mobileController.text.trim().isEmpty) {
      _setError(AppMessages.pleaseEnterMobileNumber);
      return;
    }

    // Email Validation Logic
    final email = emailController.text.trim();
    if (_emailRequired == "No") {
      if (email.isNotEmpty && !_isValidEmail(email)) {
        _setError(AppMessages.pleaseEnterValidEmail);
        return;
      }
    } else {
      if (email.isEmpty) {
        _setError(AppMessages.pleaseEnterEmail);
        return;
      }
      if (!_isValidEmail(email)) {
        _setError(AppMessages.pleaseEnterValidEmail);
        return;
      }
    }

    // Order Emails Validation
    final orderEmails = orderEmailsController.text.trim();
    if (orderEmails.isNotEmpty) {
       final emails = orderEmails.split(',').map((e) => e.trim()).toList();
       for (var e in emails) {
         if (e.isNotEmpty && !_isValidEmail(e)) {
           _setError(AppMessages.enterValidOrderEmail);
           return;
         }
       }
    }

    // Password Validation
    final pass = passwordController.text;
    final confPass = confirmPasswordController.text;

    if (pass.isEmpty) {
      _setError(AppMessages.enterYourPassword);
      return;
    }
    if (confPass.isEmpty) {
      _setError(AppMessages.pleaseConfirmNewPassword);
      return;
    }
    if (pass != confPass) {
      _setError(AppMessages.pswdNotMatching);
      return;
    }

    // Proceed to API Call
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.signUp(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: mobileController.text.trim(),
        email: email,
        password: pass,
        receiptEmails: orderEmails,
        title: _titleVal!,
      );

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
         _showSuccessDialog(context);
      }

    } catch (e) {
      _isLoading = false;
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
      notifyListeners();
    }
  }

  void _setError(String msg) {
    _errorMsg = msg;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"), 
        content: const Text("Registered Successfully. Please Login."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.login);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

   @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    orderEmailsController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
