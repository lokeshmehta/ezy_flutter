
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      color: Colors.white, // or step_bgcolor
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
    
    // Icons matching Android: Cart, Shipping, Payment, Preview
    IconData icon;
    switch(stepIndex) {
      case 0: icon = Icons.shopping_cart; break;
      case 1: icon = Icons.local_shipping; break;
      case 2: icon = Icons.payment; break;
      case 3: icon = Icons.visibility; break; // or list_alt
      default: icon = Icons.circle;
    }

    return InkWell(
      onTap: () {
         // Optional: Allow tapping to go back?
         // onStepTapped(stepIndex);
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isActive || isCompleted) ? Colors.teal : Colors.grey.shade300,
          border: isActive ? Border.all(color: Colors.teal.shade800, width: 2.w) : null,
          boxShadow: isActive ? [BoxShadow(color: Colors.teal.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)] : null,
        ),
        child: Icon(
          icon,
          color: (isActive || isCompleted) ? Colors.white : Colors.grey.shade600,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildConnector(int stepIndex) {
    bool isCompleted = currentStep > stepIndex;
    return Container(
      height: 3.h,
      color: isCompleted ? Colors.teal : Colors.grey.shade300,
    );
  }
}
