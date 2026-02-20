import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../data/models/drawer_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:provider/provider.dart';
import '../../../providers/product_list_provider.dart';
import '../../products/products_list_screen.dart';
import 'promotion_header.dart';
import '../../../widgets/custom_loader_widget.dart';

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
        final productProvider = context.read<ProductListProvider>();
        productProvider.clearFilters();
        
        // Extract product IDs
        if (item.products != null && item.products!.isNotEmpty) {
          final productIds = item.products!.map((p) => p.productId).whereType<String>().join(',');
          productProvider.setSelectedProducts(productIds);
        }
        
        if (item.divisionId != null && item.divisionId != "0") {
          productProvider.setCategory(item.divisionId!);
        }
        
        if (item.groupId != null && item.groupId != "0") {
          productProvider.setGroup(item.groupId!);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductsListScreen(
              pageTitle: "Promotions",
              headerWidget: PromotionHeader(
                imageUrl: item.image,
                title: item.displayName ?? "",
                dateRange: "${_formatDate(item.fromDate)} - ${_formatDate(item.toDate)}",
              ),
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 15.h),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(child: CustomLoaderWidget(size: 30.w)),
                    errorWidget: (context, url, error) => Container(
                      height: 180.h,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
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
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.displayName ?? "",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (item.fromDate != null && item.toDate != null)
                    Text(
                      "${_formatDate(item.fromDate)} - ${_formatDate(item.toDate)}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.darkGrayColor,
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
