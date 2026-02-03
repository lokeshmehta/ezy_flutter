import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/features/auth/login_screen.dart';
import '../../presentation/features/companies/companies_list_screen.dart';
import '../../presentation/features/auth/signup_screen.dart';
import '../../presentation/features/splash/splash_screen.dart';

class ForgotPasswordScreen extends StatelessWidget { const ForgotPasswordScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Forgot Password'))); }

class DashboardScreen extends StatelessWidget { final Widget child; const DashboardScreen({super.key, required this.child}); @override Widget build(BuildContext context) => Scaffold(body: child, bottomNavigationBar: BottomNavigationBar(items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart')])); }
class HomeScreen extends StatelessWidget { const HomeScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home Results'))); }
class OrdersScreen extends StatelessWidget { const OrdersScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Orders'))); }
class CartScreen extends StatelessWidget { const CartScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Cart'))); }
class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile'))); }
class ProductListScreen extends StatelessWidget { const ProductListScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Product List'))); }
class ProductDetailsScreen extends StatelessWidget { final String id; const ProductDetailsScreen({super.key, required this.id}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Product $id'))); }

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
      
      // Dashboard Shell
      ShellRoute(
        builder: (context, state, child) {
          return DashboardScreen(child: child);
        },
        routes: [
          GoRoute(path: '/dashboard/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/dashboard/orders', builder: (context, state) => const OrdersScreen()),
          GoRoute(path: '/dashboard/cart', builder: (context, state) => const CartScreen()),
          GoRoute(path: '/dashboard/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),

      // Products
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/product_details/:id',
        builder: (context, state) => ProductDetailsScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
}
