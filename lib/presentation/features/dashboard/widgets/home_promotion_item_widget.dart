import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';

class HomePromotionItemWidget extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double width;

  const HomePromotionItemWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: EdgeInsets.only(right: 10.w, bottom: 5.h),
      padding: EdgeInsets.only(bottom: 5.h), // Extra padding for shadow/elevation
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(5.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                SizedBox(
                  height: 120.h, // @dimen/dimen_120
                  width: double.infinity,
                  child: _buildImage(imageUrl),
                ),
                SizedBox(height: 5.h),
                
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp, // _13sdp approx
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                
                // Subtitle (Date or Count)
                SizedBox(height: 5.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),

                // Shop Now Section
                const Spacer(),
                Row(
                  children: [
                    Text(
                      "Shop Now",
                      style: TextStyle(
                        fontSize: 14.sp, // _13sdp
                        color: Colors.blue, // @color/blue
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Transform.rotate(
                       angle: -1.5708, // 270 degrees in radians (Android rotation="270")
                       child: Icon(Icons.arrow_drop_down, color: Colors.blue, size: 16.sp),
                    )
                  ],
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
      if (path == null || path.isEmpty) {
        return Container(color: Colors.grey[200]);
      }
      String finalUrl = path;
      if (!path.startsWith("http")) {
          finalUrl = "${UrlApiKey.mainUrl}$path";
      }

      return CachedNetworkImage(
        imageUrl: finalUrl,
        fit: BoxFit.fill, // fitXY
        cacheManager: ImageCacheManager(),
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
      );
  }
}
