import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.only(right: 10, bottom: 5),
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                SizedBox(
                  height: 120, // @dimen/dimen_120
                  width: double.infinity,
                  child: _buildImage(imageUrl),
                ),
                const SizedBox(height: 5),
                
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14, // _13sdp approx
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                
                // Subtitle (Date or Count)
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                // Shop Now Section
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      "Shop Now",
                      style: TextStyle(
                        fontSize: 14, // _13sdp
                        color: Colors.blue, // @color/blue
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Transform.rotate(
                       angle: -1.5708, // 270 degrees in radians (Android rotation="270")
                       child: const Icon(Icons.arrow_drop_down, color: Colors.blue, size: 16),
                    )
                  ],
                ),
                const SizedBox(height: 5),
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
