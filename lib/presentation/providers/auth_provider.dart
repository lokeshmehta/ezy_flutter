import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/constants/storage_keys.dart';


import '../../core/constants/app_messages.dart';

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
    _companyName = prefs.getString(StorageKeys.companyName) ?? "";
    _companyImage = prefs.getString(StorageKeys.companyImage) ?? "";
    // Note: Android uses 'userName' key for hint.
    _userNameHint = prefs.getString(StorageKeys.userNamePlaceholder) ?? "User ID";
    _customerSignupRequired = prefs.getString(StorageKeys.companyRegisterNeeded) ?? "No"; 
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty) {
        _errorMessage = AppMessages.enterYourUserId;
        notifyListeners();
        return false;
    }
    if (password.isEmpty) {
        _errorMessage = AppMessages.enterYourPassword;
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
         await prefs.setString(StorageKeys.userId, user.customerId ?? "");
         await prefs.setString(StorageKeys.accessToken, user.accessToken);
         await prefs.setString(StorageKeys.userPassword, password);
         success = true;
      } else {
         _errorMessage = user.message ?? "Login Failed";
         notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString(); 
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<void> clearSession() async {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(StorageKeys.userId, "0");
      await prefs.setString(StorageKeys.accessToken, "");
      
      await prefs.remove(StorageKeys.companyId);
      await prefs.remove(StorageKeys.companyToken);
      await prefs.remove(StorageKeys.companyUrl);
      await prefs.remove(StorageKeys.companyName);
      await prefs.remove(StorageKeys.companyImage);
      await prefs.remove(StorageKeys.companyRegisterNeeded);
      await prefs.remove(StorageKeys.userNamePlaceholder);
      
      // Update UrlApiKey implicitly via next Splash load or manually if we had a reset method.
  }
}
