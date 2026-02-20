import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_theme.dart';
import 'custom_loader_widget.dart';

class CustomProgressDialog extends StatelessWidget {
  const CustomProgressDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CustomProgressDialog(),
    );
     // Note: Caller must handle dismissal using Navigator.pop(context);
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Android: CardView (100dp) -> ProgressBar + TextView (Centered)
    // Background: Transparent
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: SizedBox(
          width: 100.w, // Match Android dimen_100
          height: 100.w, 
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating Loader matching anim1.xml -> ic_progress_bar.xml
              CustomLoaderWidget(size: 100.w),
              
              // Text "Please Wait" centered
              Text(
                "Please Wait",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primaryColor, // @color/blue
                  fontSize: 13.sp, // @dimen/_13sdp
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
