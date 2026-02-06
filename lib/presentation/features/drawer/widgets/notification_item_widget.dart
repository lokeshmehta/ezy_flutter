import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/url_api_key.dart';

import '../../../../data/models/drawer_models.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = item.image ?? "";
    if (imageUrl.isNotEmpty && !imageUrl.startsWith("http")) {
      imageUrl = "${UrlApiKey.mainUrl}$imageUrl";
    }

    bool hasImage = imageUrl.isNotEmpty;
    bool isBeforeImage = item.imagePosition == "Before Message"; // Check Android constant string

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.only(bottom: 10.h),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Before
              if (hasImage && isBeforeImage)
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 40.w),
                    ),
                  ),
                ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? "",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (item.status == "UnRead")
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              "New",
                              style: TextStyle(color: Colors.white, fontSize: 10.sp),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      item.description ?? "",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Image After
              if (hasImage && !isBeforeImage)
                Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 40.w),
                    ),
                  ),
                ),
                
               // Delete Button
               InkWell(
                 onTap: onDelete,
                 child: Padding(
                   padding: EdgeInsets.only(left: 10.w),
                   child: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}
