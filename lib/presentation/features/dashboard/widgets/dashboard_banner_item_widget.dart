import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/network/image_cache_manager.dart';
import '../../../../data/models/home_models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardBannerItemWidget extends StatelessWidget {
  final SupplierItem item;
  final VoidCallback? onTap;

  const DashboardBannerItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      width: MediaQuery.of(context).size.width - 30, 
      child: GestureDetector(
        onTap: () {
           if (item.externalLink != null && item.externalLink!.isNotEmpty) {
              _launchUrl(item.externalLink!);
           } else {
              onTap?.call();
           }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(item.image),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error
    }
  }

  Widget _buildImage(String? path) {
      if (path == null || path.isEmpty) {
        return Container(color: Colors.grey[200], height: 220.h); // Updated height to 220.h
      }
      String finalUrl = path;
      if (!path.startsWith("http")) {
          finalUrl = "${UrlApiKey.mainUrl}$path";
      }

      return CachedNetworkImage(
        imageUrl: finalUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.fill, // fitXY
        cacheManager: ImageCacheManager(),
        placeholder: (context, url) => Container(color: Colors.grey[200], height: 220),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
      );
  }
}
