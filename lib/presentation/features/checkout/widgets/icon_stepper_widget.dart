
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_theme.dart';

class IconStepperWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int) onStepTapped;

  const IconStepperWidget({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      color: Colors.white, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isEven) {
            // Step Icon
            int stepIndex = index ~/ 2;
            return _buildStepIcon(stepIndex);
          } else {
            // Connector Line
            int stepIndex = (index - 1) ~/ 2;
            return Expanded(child: _buildConnector(stepIndex));
          }
        }),
      ),
    );
  }

  Widget _buildStepIcon(int stepIndex) {
    bool isActive = currentStep == stepIndex;
    bool isCompleted = currentStep > stepIndex;
    
    // Icons matching Android: Cart, Shipping(Address), Payment, Preview
    IconData icon;
    switch(stepIndex) {
      case 0: icon = Icons.shopping_cart; break;
      case 1: icon = Icons.local_shipping; break;
      case 2: icon = Icons.payment; break;
      case 3: icon = Icons.list_alt; break; // Preview
      default: icon = Icons.circle;
    }

    return InkWell(
      onTap: () {
         // onStepTapped(stepIndex);
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isActive || isCompleted) ? AppTheme.tealColor : AppTheme.lightGrayBg,
          border: isActive ? Border.all(color: AppTheme.tealColor, width: 2.w) : null,
          boxShadow: isActive ? [BoxShadow(color: AppTheme.tealColor.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)] : null,
        ),
        child: Icon(
          icon,
          color: (isActive || isCompleted) ? Colors.white : AppTheme.darkGrayColor,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildConnector(int stepIndex) {
    bool isCompleted = currentStep > stepIndex;
    return Container(
      height: 3.h,
      color: isCompleted ? AppTheme.tealColor : AppTheme.lightGrayBg,
    );
  }
}
