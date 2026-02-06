import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/assets.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onYes;

  const LogoutDialog({super.key, required this.onYes});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (Teal)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
            color: AppTheme.secondaryColor, // Teal
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    AppAssets.menuCloseIcon,
                    width: 18.w,
                    height: 18.w,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
            child: Text(
              "Do you want to logout?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // Actions
          Padding(
            padding: EdgeInsets.only(bottom: 30.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(
                  context: context,
                  text: "Yes",
                  color: AppTheme.secondaryColor,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                    onYes();
                  },
                ),
                SizedBox(width: 20.w),
                _buildButton(
                  context: context,
                  text: "No",
                  color: const Color(0xFFD3D3D3), // Grey (hint_color)
                  textColor: AppTheme.primaryColor,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 110.w,
        height: 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
