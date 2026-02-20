import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../widgets/custom_loader_widget.dart';

class PromotionHeader extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String dateRange;
  
  const PromotionHeader({super.key, required this.imageUrl, required this.title, required this.dateRange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Image Stack
            Stack(
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                 ClipRRect(
                   borderRadius: BorderRadius.circular(8.r),
                   child: CachedNetworkImage(
                      imageUrl: imageUrl!.contains("http") ? imageUrl! : "${UrlApiKey.mainUrl}$imageUrl",
                       width: double.infinity,
                       height: 150.h,
                       fit: BoxFit.cover,
                       placeholder: (context, url) => Center(child: CustomLoaderWidget(size: 30.w)),
                       errorWidget: (context, url, error) => const Icon(Icons.error),
                   ),
                 ),
                 // Tag Overlay
                 Positioned(
                   top: 10.h,
                   left: 10.w,
                   child: Container(
                     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                     decoration: BoxDecoration(
                       color: Colors.orange,
                       borderRadius: BorderRadius.circular(4.r),
                     ),
                     child: Text("Promotion", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                   ),
                 ),
              ],
            ),
             SizedBox(height: 10.h),
             // Title and Date Row
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.start, // Align to top in case of multiline title
               children: [
                 Expanded(
                   child: Text(
                     title, 
                     style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),
                   ),
                 ),
                 SizedBox(width: 10.w),
                 Text(dateRange, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
               ],
             ),
        ],
      )
    );
  }
}
