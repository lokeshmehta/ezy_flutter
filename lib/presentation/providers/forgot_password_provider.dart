import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final AuthRepository _repository = getIt<AuthRepository>();
  
  final TextEditingController userIdController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMsg;

  bool get isLoading => _isLoading;
  String? get errorMsg => _errorMsg;

  Future<void> submit(BuildContext context) async {
    _errorMsg = null;
    final userId = userIdController.text.trim();

    if (userId.isEmpty) {
      _errorMsg = "Enter your user id"; // @string/enter_your_user_id
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.forgotPassword(userId);
      
      _isLoading = false;
      notifyListeners();

      // Check response status
      if (response is Map<String, dynamic>) {
        if (response['status'] == 200) {
           if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Success")), // @string/successmsg
             );
             context.go('/login');
           }
        } else {
           _errorMsg = response['error'] ?? "Unknown Error";
        }
      } else {
         _errorMsg = "Unexpected response format";
      }
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _errorMsg = e.toString();
      notifyListeners();
    }
  }

  void backClick(BuildContext context) {
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    userIdController.dispose();
    super.dispose();
  }
}
