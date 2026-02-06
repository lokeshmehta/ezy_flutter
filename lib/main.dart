import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/splash_provider.dart';
import 'presentation/providers/companies_provider.dart';
import 'presentation/providers/signup_provider.dart';
import 'presentation/providers/forgot_password_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/product_list_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'data/datasources/auth_remote_data_source.dart';

import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides(); // Bypass SSL verification
  
  // TODO: Initialize ServiceLocator (GetIt) here
  setupLocator(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple breakpoint for tablet detection
        final isTablet = constraints.maxWidth >= 600;
        
        return ScreenUtilInit(
          // Use distinct design sizes for Phone vs Tablet to ensure 12.sp looks like 12px on both
          designSize: isTablet ? const Size(768, 1024) : const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => AuthProvider(getIt<AuthRepository>())),
                ChangeNotifierProvider(create: (_) => SplashProvider()),
                ChangeNotifierProvider(create: (_) => CompaniesProvider()),
                ChangeNotifierProvider(create: (_) => SignUpProvider()),
                ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
                ChangeNotifierProvider(create: (_) => DashboardProvider(getIt<AuthRemoteDataSource>())),
                ChangeNotifierProvider(create: (_) => ProductListProvider(getIt<AuthRemoteDataSource>())),
                ChangeNotifierProvider(create: (_) => CartProvider(getIt<AuthRemoteDataSource>())),
              ],
              child: MaterialApp.router(
                title: 'EzyOrders',
                theme: AppTheme.lightTheme,
                routerConfig: AppRouter.router,
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        );
      },
    );
  }
}
