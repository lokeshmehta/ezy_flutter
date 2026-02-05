import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_theme.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onPrevTap;
  final VoidCallback? onNextTap;
  final bool showNavButtons;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.onPrevTap,
    this.onNextTap,
    this.showNavButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 10.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          if (showNavButtons)
            Row(
              children: [
                if (onPrevTap != null)
                  _buildNavButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: onPrevTap!,
                  ),
                SizedBox(width: 10.w),
                if (onNextTap != null)
                  _buildNavButton(
                    icon: Icons.arrow_forward_ios,
                    onTap: onNextTap!,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: Color(0xFFFCBD5F), // Orange/Amber from screenshot
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
