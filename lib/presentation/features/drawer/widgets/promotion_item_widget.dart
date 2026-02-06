import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../data/models/drawer_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PromotionItemWidget extends StatelessWidget {
  final PromotionsItem item;
  final int index;

  const PromotionItemWidget({super.key, required this.item, required this.index});

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    // Android uses CommonMethods.getDate which likely parses "2023-01-01" to "01 Jan 2023"
    // Keeping it simple for now or implementing a utility later.
    // Assuming format YYYY-MM-DD
    try {
      final date = DateTime.parse(dateStr);
      // Format: dd MMM yyyy
      const List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = item.image ?? "";
    if (!imageUrl.startsWith("http")) {
      imageUrl = "${UrlApiKey.mainUrl}$imageUrl";
    }

    return GestureDetector(
      onTap: () {
        // Navigate to PromotionProductsScreen
        // Navigator.push(context, MaterialPageRoute(builder: (c) => PromotionProductsScreen(item: item, index: index)));
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 15.h),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Container(
                  height: 180.h,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor, // Blue color commonly used
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      "Promotion",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    item.displayName ?? "",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  if (item.fromDate != null && item.toDate != null)
                    Text(
                      "${_formatDate(item.fromDate)} - ${_formatDate(item.toDate)}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
