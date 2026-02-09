
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/models/order_models.dart';
import '../../../../core/constants/app_theme.dart';

class OrderListItemWidget extends StatelessWidget {
  final OrderHistoryResult order;
  final VoidCallback onViewDetails;
  final VoidCallback onReorder;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onDownload;

  const OrderListItemWidget({
    super.key,
    required this.order,
    required this.onViewDetails,
    required this.onReorder,
    required this.onDuplicate,
    required this.onDelete,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = order.orderStatus?.toLowerCase() == "cancelled";

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID Section
          Padding(
            padding: EdgeInsets.only(left: 10.w, top: 10.h),
            child: Row(
              children: [
                Text(
                  "Order ID :",
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  order.refNo ?? "",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Order Amount Section
          Padding(
            padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 5.h),
            child: Row(
              children: [
                Text(
                  "Order Amount :",
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  "AUD ${order.orderAmount ?? '0.00'}",
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Qty and Status Row
          Padding(
            padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 5.h),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Qty :",
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "${order.quantity ?? 0}",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.orderStatus ?? "",
                      style: TextStyle(
                        color: isCancelled ? AppTheme.redColor : Colors.green,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      isCancelled ? Icons.cancel : Icons.check_circle,
                      color: isCancelled ? AppTheme.redColor : Colors.green,
                      size: 18.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Email and Date Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            child: Column(
              children: [
                // Email Row
                Row(
                  children: [
                    Icon(Icons.email_outlined, color: AppTheme.primaryColor, size: 14.sp),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        order.email ?? "",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                // Date Row
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor, size: 14.sp),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        order.orderDate ?? "",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              children: [
                // Action Buttons Group
                _buildActionButton(
                  icon: Icons.shopping_cart_outlined,
                  color: AppTheme.tealColor, // Synchronized Orange
                  onTap: onReorder,
                  visible: true, // Controlled by provider/config usually
                ),
                _buildActionButton(
                  icon: Icons.description_outlined,
                  color: AppTheme.primaryColor,
                  onTap: onDuplicate,
                  visible: true,
                ),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: AppTheme.redColor,
                  onTap: onDelete,
                  visible: !isCancelled,
                ),
                _buildActionButton(
                  icon: Icons.download_outlined,
                  color: Colors.lightBlueAccent,
                  onTap: onDownload,
                  visible: true,
                ),

                const Spacer(),

                // View Details Button
                ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFADD8E6), // Light blue
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    minimumSize: Size(0, 32.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    "View Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool visible,
  }) {
    if (!visible) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r),
          ),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }
}
