import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/splash_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize ServiceLocator (GetIt) here
  setupLocator(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Standard Android design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider(getIt<AuthRepository>())), // From ServiceLocator
            ChangeNotifierProvider(create: (_) => SplashProvider()),
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
  }
}
