import 'package:cached_network_image/cached_network_image.dart';
import 'package:ezy_orders_flutter/core/constants/app_theme.dart';
import 'package:ezy_orders_flutter/core/constants/url_api_key.dart';
import 'package:ezy_orders_flutter/presentation/features/products/products_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SupplierItemWidget extends StatelessWidget {
  final String? image;
  final String? brandName;
  final String? brandId;

  const SupplierItemWidget({
    super.key,
    this.image,
    this.brandName,
    this.brandId,
  });

  @override
  Widget build(BuildContext context) {
    // Width calculation logic from Android:
    // double buttonWidth = width / 2;
    // LayoutParams(buttonWidth - 40, wrap_content)
    double itemWidth = (1.sw / 2) - 25.w;

    return GestureDetector(
      onTap: () {
        // Navigate to Products List with supplier filter
        if (brandId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
               builder: (context) => ProductsListScreen(
                   supplierId: brandId!,
                   backNav: "suppliers",
               ),
            ),
          );
        }
      },
      child: Container(
        width: itemWidth,
        margin: EdgeInsets.only(right: 10.w), // android:layout_marginRight="@dimen/top_10" (approx 10dp)
        child: Card(
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r), // Default card radius
          ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppTheme.darkGrayColor, width: 1.5),
                         borderRadius: BorderRadius.circular(1.r), // supplier_bg.xml radius
                      ),
                      child: Padding(
                         padding: EdgeInsets.all(1.5.w), // android:layout_margin="@dimen/dimen_1_5"
                         child: _buildImage(image),
                      ),
                    ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                child: Text(
                  brandName ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                    fontSize: 10.sp, 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(color: Colors.grey[200], height: 120.h);
    }
    String finalUrl = path;
    if (!path.startsWith("http")) {
      finalUrl = "${UrlApiKey.mainUrl}$path";
    }

    return CachedNetworkImage(
      imageUrl: finalUrl,
      height: 120.h, // android:layout_height="@dimen/dimen_120"
      width: double.infinity,
      fit: BoxFit.fill, // android:scaleType="fitXY"
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error, size: 24.sp),
    );
  }
}
