import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';


class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  UserEntity? _user;
  UserEntity? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // UI State
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  // Company Config loaded from Prefs (for Login UI)
  String _companyName = "";
  String _companyImage = "";
  String _userNameHint = "User ID";
  String _customerSignupRequired = "No";
  
  String get companyName => _companyName;
  String get companyImage => _companyImage;
  String get userNameHint => _userNameHint;
  bool get isSignupRequired => _customerSignupRequired == "Yes";


  Future<void> loadCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    _companyName = prefs.getString('COMPANY_NAME') ?? "";
    _companyImage = prefs.getString('COMPANY_IMAGE') ?? "";
    // Note: Android uses 'userName' key for hint.
    _userNameHint = prefs.getString('userName') ?? "User ID";
    _customerSignupRequired = prefs.getString('COMPANY_REGISTER_NEEDED') ?? "No"; // We mapped 'allow_new_user_sign_up' to this key
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
        _errorMessage = "Please enter Valid Credentials";
        notifyListeners();
        return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;

    try {
      final user = await _repository.login(email, password);
      
      _user = user;
      _isLoading = false;
      notifyListeners();
      
      // Save Session
      if (user.status == 200) {
         final prefs = await SharedPreferences.getInstance();
         await prefs.setString('USER_ID', user.customerId ?? "");
         await prefs.setString('ACCESSTOKEN', user.accessToken);
         await prefs.setString('USER_PASSWORD', password);
         success = true;
      } else {
         _errorMessage = user.message ?? "Login Failed";
         notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString(); // Or check if e is Failure
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<void> clearSession() async {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('USER_ID', "0");
      await prefs.setString('ACCESSTOKEN', "");
      
      await prefs.remove('COMPANY_ID');
      await prefs.remove('COMPANY_TOKEN');
      await prefs.remove('COMPANY_URL');
      await prefs.remove('COMPANY_NAME');
      await prefs.remove('COMPANY_IMAGE');
      await prefs.remove('COMPANY_REGISTER_NEEDED');
      await prefs.remove('userName');
      
      // Update UrlApiKey implicitly via next Splash load or manually if we had a reset method.
  }
}
