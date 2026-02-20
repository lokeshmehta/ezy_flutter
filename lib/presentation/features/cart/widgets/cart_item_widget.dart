import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../../core/utils/common_methods.dart';
import '../../../../data/models/cart_models.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../widgets/custom_loader_widget.dart';

class CartItemWidget extends StatelessWidget {
  final CartProduct item;

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
                  child: Center(child: CustomLoaderWidget(size: 30.w)),
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
                    CommonMethods.decodeHtmlEntities(item.title),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.brandName ?? "",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.darkerGrayColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Price and Unit
                  Row(
                    children: [
                      Text(
                        "\$${(double.tryParse(item.salePrice ?? "0") ?? 0) > 0 ? item.salePrice : (item.normalPrice ?? "0.00")}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        "/ ${item.orderedAs ?? item.soldAs ?? 'Each'}",
                        style: TextStyle(fontSize: 12.sp, color: AppTheme.darkGrayColor),
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
                              onTap: () async {
                                int currentQty = item.qty ?? 0;
                                if (currentQty > 0) {
                                  await context.read<CartProvider>().updateCartItem(item, (currentQty - 1).toString());
                                  if (context.mounted) {
                                     context.read<DashboardProvider>().setCartCount(CommonMethods.cartCount);
                                  }
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
                                item.qty?.toString() ?? "0",
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                int currentQty = item.qty ?? 0;
                                await context.read<CartProvider>().updateCartItem(item, (currentQty + 1).toString());
                                if (context.mounted) {
                                   context.read<DashboardProvider>().setCartCount(CommonMethods.cartCount);
                                }
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
                        onTap: () async {
                           await context.read<CartProvider>().deleteCartItem(item);
                           if (context.mounted) {
                              context.read<DashboardProvider>().setCartCount(CommonMethods.cartCount);
                           }
                        },
                        child: Icon(Icons.delete_outline, color: AppTheme.redColor, size: 24.sp),
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
