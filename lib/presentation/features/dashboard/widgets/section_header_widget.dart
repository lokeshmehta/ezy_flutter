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
      padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 5.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (showNavButtons)
            Row(
              children: [
                _buildNavButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: onPrevTap,
                  isActive: onPrevTap != null,
                ),
                SizedBox(width: 12.w),
                _buildNavButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: onNextTap,
                  isActive: onNextTap != null,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isActive,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.productButtonRadius.r),
      child: Container(
        width: AppTheme.arrowSize.w,
        height: AppTheme.arrowSize.w,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.secondaryColor : AppTheme.lightSecondaryColor,
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
