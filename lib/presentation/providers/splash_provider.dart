import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/service_locator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/url_api_key.dart';
import '../../domain/entities/companies_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/constants/storage_keys.dart';

class SplashProvider extends ChangeNotifier {
  bool _isLoading = true;
  String? _errorMsg;
  
  bool get isLoading => _isLoading;
  String? get errorMsg => _errorMsg;

  final AuthRepository _repository = getIt<AuthRepository>();

  Future<void> init(BuildContext context) async {
    // 1. Check & Request Permissions (Strictly matching Android)
    final hasPermissions = await _checkAndRequestPermissions();
    if (!hasPermissions) {
       return; 
    }
    
    if (!context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final String? companyUrl = prefs.getString(StorageKeys.companyUrl); 
    final String? userId = prefs.getString(StorageKeys.userId);

    if (companyUrl == null || companyUrl.isEmpty) {
      if (!context.mounted) return;
      await _fetchCompanies(context, prefs);
    } else {
      await Future.delayed(const Duration(seconds: 3));
      
      if (!context.mounted) return;

      if (userId == null || userId == "0") {
         _setBaseUrl(companyUrl);
         context.go('/login');
      } else {
         _setBaseUrl(companyUrl);
         context.go('/dashboard');
      }
    }
  }

  void _setBaseUrl(String companyUrl) {
      if (companyUrl.isNotEmpty) {
          UrlApiKey.baseUrl = "$companyUrl/api/";
      }
  }

  Future<bool> _checkAndRequestPermissions() async {
      await [
        Permission.camera,
        Permission.notification, 
        Permission.storage, 
        Permission.photos, 
      ].request();
      
      return true; 
  }

  Future<void> _fetchCompanies(BuildContext context, SharedPreferences prefs) async {
    try {
      final response = await _repository.getCompanies();
      
      if (response.status == 200) {
        final results = response.results;
        if (results != null && results.isNotEmpty) {
           if (response.resultsCount == 1) {
              final company = results[0];
              await _saveCompanyPrefs(prefs, company);
              _setBaseUrl(company.companyUrl ?? "");
              
              if (context.mounted) {
                 context.go('/login');
              }
           } else {
              if (context.mounted) {
                 context.go('/companies');
                 _errorMsg = "Multiple companies found. Feature pending.";
                 _isLoading = false;
                 notifyListeners();
              }
           }
        } else {
           _isLoading = false;
           _errorMsg = "No data";
           notifyListeners();
        }
      } else {
         _isLoading = false;
         _errorMsg = response.message ?? "Error fetching companies";
         notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMsg = e.toString();
      notifyListeners();
    }
  }

  Future<void> _saveCompanyPrefs(SharedPreferences prefs, CompanyResult company) async {
     await prefs.setString(StorageKeys.companyId, company.companyId?.toString() ?? "");
     await prefs.setString(StorageKeys.companyToken, company.accessToken ?? "");
     await prefs.setString(StorageKeys.companyUrl, company.companyUrl ?? "");
     await prefs.setString(StorageKeys.companyName, company.name ?? "");
     await prefs.setString(StorageKeys.companyImage, company.image ?? "");
     await prefs.setString(StorageKeys.paymentMethods, company.availablePaymentMethods ?? "");
     await prefs.setString(StorageKeys.emailRequired, company.emailRequiredForCustomerSignup ?? "");
     await prefs.setString(StorageKeys.razorSecretKey, company.razorPaySecret ?? "");
     await prefs.setString(StorageKeys.razorServerKey, company.razorPayKey ?? "");
     await prefs.setString(StorageKeys.companyRegisterNeeded, company.allowNewUserSignUp ?? "");
     await prefs.setString(StorageKeys.userNamePlaceholder, company.loginScreenUsernamePlaceholder ?? "");
  }
}
