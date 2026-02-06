import 'package:go_router/go_router.dart';
import '../../presentation/features/auth/login_screen.dart';
import '../../presentation/features/companies/companies_list_screen.dart';
import '../../presentation/features/auth/signup_screen.dart';
import '../../presentation/features/auth/forgot_password_screen.dart';
import '../../presentation/features/splash/splash_screen.dart';

import '../../presentation/features/dashboard/dashboard_screen.dart';
import '../../presentation/features/dashboard/my_wishlist_screen.dart';
import '../../presentation/features/cart/cart_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/companies',
        builder: (context, state) => const CompaniesListScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/my-wishlist',
        builder: (context, state) => const MyWishlistScreen(),
      ),

      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
    ],
  );
}
