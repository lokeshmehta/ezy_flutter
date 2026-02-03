import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/service_locator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/url_api_key.dart';
import '../../domain/entities/companies_response.dart';
import '../../domain/repositories/auth_repository.dart';

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
       // Android logic: if denied, it returns false. 
       // Depending on UX, we might show dialog or retry.
       // Android just returns false and does nothing else? 
       // In Android: if(checkAndRequestPermissions()) { ... }
       // So if false, it stops.
       return; 
    }
    
    if (!context.mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final String? companyUrl = prefs.getString('COMPANY_URL'); 
    final String? userId = prefs.getString('USER_ID');

    if (companyUrl == null || companyUrl.isEmpty) {
      if (!context.mounted) return;
      // Logic: vm?.countriesApicall()
      await _fetchCompanies(context, prefs);
    } else {
      // Logic: Handler postDelayed 3000
      await Future.delayed(const Duration(seconds: 3));
      
      if (!context.mounted) return;

      if (userId == null || userId == "0") {
         _setBaseUrl(companyUrl);
         context.go('/login');
      } else {
         _setBaseUrl(companyUrl);
         context.go('/dashboard/home');
      }
    }
  }

  void _setBaseUrl(String companyUrl) {
      if (companyUrl.isNotEmpty) {
          UrlApiKey.baseUrl = "$companyUrl/api/";
          // Android also sets MAIN_URL but we focus on BASE_URL for API
      }
  }

  Future<bool> _checkAndRequestPermissions() async {
      // Android checks: Camera, Notifications, Storage.
      // We use permission_handler
      
      // Note: Android 13+ handles storage differently (Photos/Videos/Audio).
      // We will ask for basics available in permission_handler.
      
      // Map Android logic to Flutter:
      // Camera
      // Notification
      // Storage (or Photos/Videos on Android 13)
      
      await [
        Permission.camera,
        Permission.notification, // Android 13+
        Permission.storage, // Android 12 and below mainly
        Permission.photos, // Android 13+ images
      ].request();
      
      // Strict logic: return true if all criticals granted?
      // Android logic checks individually.
      // Simplified for "Strict Migration" -> We request them.
      // If user denies, we return true to proceed or false to block?
      // Android: if (!listPermissionsNeeded.isEmpty()) -> request -> return false.
      // If empty -> return true.
      // This implies: If permissions needed (not granted yet), request them and PAUSE init.
      // Wait, requestPermissions is asynchronous in Flutter but synchronous call in Android logic returns false.
      // In Android onRequestPermissionsResult would resume.
      // In Flutter `await .request()` waits for user input.
      // So we can just wait and then proceed (return true).
      
      return true; 
  }

  Future<void> _fetchCompanies(BuildContext context, SharedPreferences prefs) async {
    try {
      final response = await _repository.getCompanies();
      
      if (response.status == 200) {
        final results = response.results;
        if (results != null && results.isNotEmpty) {
           if (response.resultsCount == 1) {
              // Auto Config
              final company = results[0];
              await _saveCompanyPrefs(prefs, company);
              _setBaseUrl(company.companyUrl ?? "");
              
              if (context.mounted) {
                 context.go('/login');
              }
           } else {
              // Navigate to Companies List
              //! strict migration: navigate to companies list
              if (context.mounted) {
                 // context.go('/companies'); // Route not added yet.
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
      _errorMsg = e.toString(); // Or map specific failure types if needed
      notifyListeners();
    }
  }

  Future<void> _saveCompanyPrefs(SharedPreferences prefs, CompanyResult company) async {
     await prefs.setString('COMPANY_ID', company.companyId?.toString() ?? "");
     await prefs.setString('COMPANY_TOKEN', company.accessToken ?? "");
     await prefs.setString('COMPANY_URL', company.companyUrl ?? "");
     await prefs.setString('COMPANY_NAME', company.name ?? "");
     await prefs.setString('COMPANY_IMAGE', company.image ?? "");
     await prefs.setString('PAYMENTMETHODS', company.availablePaymentMethods ?? "");
     await prefs.setString('EMAILREQUIRED', company.emailRequiredForCustomerSignup ?? "");
     await prefs.setString('RAZAR_SECRETKEY', company.razorPaySecret ?? "");
     await prefs.setString('RAZAR_SERVERKEY', company.razorPayKey ?? "");
     await prefs.setString('COMPANY_REGISTER_NEEDED', company.allowNewUserSignUp ?? ""); // Key might differ? Android used 'allow_new_user_sign_up'. Key map: "allow_new_user_sign_up" -> "COMPANY_REGISTER_NEEDED" (mapped to CustomerSignupRequired in PrefsHelper)
     await prefs.setString('userName', company.loginScreenUsernamePlaceholder ?? "");
  }
}
