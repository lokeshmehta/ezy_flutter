import 'package:go_router/go_router.dart';
import '../../presentation/features/cart/cart_screen.dart';
import '../../presentation/features/auth/login_screen.dart';
import '../../presentation/features/companies/companies_list_screen.dart';
import '../../presentation/features/auth/signup_screen.dart';
import '../../presentation/features/auth/forgot_password_screen.dart';
import '../../presentation/features/splash/splash_screen.dart';


import '../../presentation/screens/main_screen.dart';
import '../../presentation/features/checkout/checkout_screen.dart';
import '../../presentation/features/orders/my_orders_screen.dart';
import '../../presentation/features/dashboard/my_wishlist_screen.dart';
import '../../presentation/features/profile/my_profile_screen.dart';
import '../../presentation/features/account/change_password_screen.dart';
import '../../presentation/features/account/my_account_screen.dart';
import '../../presentation/features/account/my_addresses_screen.dart';
import '../../presentation/features/account/add_address_screen.dart';
import '../../data/models/profile_models.dart';
import '../../presentation/features/checkout/order_success_screen.dart';

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
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/my-wishlist',
        builder: (context, state) => const MyWishlistScreen(),
      ),

      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/my-orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/my-profile',
        builder: (context, state) => const MyProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/my-account',
        builder: (context, state) => const MyAccountScreen(),
      ),
      GoRoute(
        path: '/my-addresses',
        builder: (context, state) => const MyAddressesScreen(),
      ),
      GoRoute(
        path: '/add-address',
        builder: (context, state) {
            final address = state.extra as AddressItem?;
            return AddAddressScreen(addressToEdit: address);
        },
      ),
      GoRoute(
        path: '/order-success',
        builder: (context, state) {
            final orderData = state.extra as Map<String, dynamic>;
            return OrderSuccessScreen(orderData: orderData);
        },
      ),
    ],
  );
}
