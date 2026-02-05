import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          if (showNavButtons)
            Row(
              children: [
                if (onPrevTap != null)
                  InkWell(
                    onTap: onPrevTap,
                    child: Transform.rotate(
                      angle: 3.14159 / 2, // 90 degrees
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_back_ios, size: 16, color: AppTheme.primaryColor), // Placeholder for custom drawable
                      ),
                    ),
                  ),
                 if (onNextTap != null)
                  InkWell(
                    onTap: onNextTap,
                    child: Transform.rotate(
                      angle: -3.14159 / 2, // -90 degrees
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_back_ios, size: 16, color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
