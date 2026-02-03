import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets.dart';
import '../../providers/splash_provider.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initialization after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashProvider>().init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or Theme color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Image.asset(
                AppAssets.splashLogo,
                height: 200.h,
                fit: BoxFit.contain, // match_parent width usually implies contain or fitWidth
                errorBuilder: (ctx, _, __) => const Icon(Icons.error), 
              ),
            ),
            SizedBox(height: 20.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
