import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/utils/common_methods.dart';
import '../../../../data/models/cart_models.dart';
import '../../../providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: "${UrlApiKey.mainUrl}${item.image}",
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            SizedBox(width: 10.w),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? "",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.brandName ?? "",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Price and Unit
                  Row(
                    children: [
                      Text(
                        "\$${CommonMethods.checkNullempty(item.salePrice)}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        "/ ${item.orderedAs ?? 'Each'}",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  
                  // Qty Controls & Delete
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Qty Control
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                int currentQty = int.tryParse(item.qty ?? "0") ?? 0;
                                if (currentQty > 0) {
                                  context.read<CartProvider>().updateCartItem(item, (currentQty - 1).toString());
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                child: Icon(Icons.remove, size: 16.sp),
                              ),
                            ),
                            Container(
                              width: 30.w,
                              alignment: Alignment.center,
                              color: Colors.grey[100],
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Text(
                                item.qty ?? "0",
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                int currentQty = int.tryParse(item.qty ?? "0") ?? 0;
                                context.read<CartProvider>().updateCartItem(item, (currentQty + 1).toString());
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                child: Icon(Icons.add, size: 16.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Delete
                      InkWell(
                        onTap: () {
                           context.read<CartProvider>().deleteCartItem(item);
                        },
                        child: Icon(Icons.delete_outline, color: Colors.red, size: 24.sp),
                      ),
                    ],
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
