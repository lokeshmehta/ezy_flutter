import 'package:go_router/go_router.dart';

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
import '../../presentation/features/products/product_details_screen.dart';
import '../../presentation/features/drawer/notifications_screen.dart';

import 'app_routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.companies,
        builder: (context, state) => const CompaniesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppRoutes.myWishlist,
        builder: (context, state) => const MyWishlistScreen(),
      ),

      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CheckoutScreen(initialStep: 0),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) {
           final extra = state.extra as Map<String, dynamic>?;
           final int initialStep = extra?['initialStep'] ?? 0;
           return CheckoutScreen(initialStep: initialStep);
        },
      ),
      GoRoute(
        path: AppRoutes.myOrders,
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.myProfile,
        builder: (context, state) => const MyProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.myAccount,
        builder: (context, state) => const MyAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.myAddresses,
        builder: (context, state) => const MyAddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        builder: (context, state) {
            final address = state.extra as AddressItem?;
            return AddAddressScreen(addressToEdit: address);
        },
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        builder: (context, state) {
            final orderData = state.extra as Map<String, dynamic>;
            return OrderSuccessScreen(orderData: orderData);
        },
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) {
           final productId = state.extra as String; // Expecting ID string or object? 
           // ProductItemWidget passes productId. Let's check ProductDetailsScreen constructor.
           // It takes productId String.
           // If we pass object, we need to extract ID. 
           // Let's standardise to passing String ID for now or check usage.
           return ProductDetailsScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
