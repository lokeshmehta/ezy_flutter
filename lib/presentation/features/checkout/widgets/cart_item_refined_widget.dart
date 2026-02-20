
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/models/cart_models.dart';
import '../../../../core/constants/app_theme.dart';
import 'package:ezy_orders_flutter/core/utils/common_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/url_api_key.dart';
import '../../../widgets/custom_loader_widget.dart';

class CartItemRefinedWidget extends StatelessWidget {
  final CartProduct item;
  final bool showHeader;
  final String brandName;
  final String brandId;
  final Function(String newQty) onUpdateQty;
  final VoidCallback onDelete;

  const CartItemRefinedWidget({
    super.key,
    required this.item,
    this.showHeader = false,
    required this.brandName,
    required this.brandId,
    required this.onUpdateQty,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Parsing Qty safely
    int qty = int.tryParse(item.qty?.toString() ?? "0") ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) _buildHeader(context),
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(5.w),
          color: Colors.white,
          child: Column(
            children: [
              Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                margin: EdgeInsets.all(5.w),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           // Supplier Title
                           Expanded(
                             child: Text(
                               brandName,
                               style: TextStyle(color: Color(0xFF0038FF), fontSize: 13.sp, fontWeight: FontWeight.bold),
                             ),
                           ),
                           // Delete Icon (Top Right)
                           InkWell(
                             onTap: onDelete,
                             child: Icon(Icons.delete, color: AppTheme.redColor, size: 20.sp),
                           ),
                         ],
                       ),
                       SizedBox(height: 10.h),
                       
                       Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            // Image
                            Container(
                              width: 70.w,
                              height: 100.h,
                              margin: EdgeInsets.only(right: 10.w),
                              alignment: Alignment.center,
                              child: _buildImage(item.image),
                            ),
                            
                            // Center Details
                            Expanded(
                              flex: 5, 
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                     item.title?.toUpperCase() ?? "",
                                     style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.bold),
                                     maxLines: 2,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                   SizedBox(height: 5.h),
                                   
                                   // Price Section
                                   if((double.tryParse(item.discountAmount ?? "0") ?? 0) > 0) ...[
                                      Text(
                                        "AUD ${item.normalPrice ?? "0.00"}",
                                        style: TextStyle(color: Colors.grey, fontSize: 13.sp, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold),
                                      ),
                                   ],
                                   Text(
                                     "AUD ${(double.tryParse(item.salePrice ?? "0") ?? 0) > 0 ? item.salePrice : (item.normalPrice ?? "0.00")}",
                                      style: TextStyle(color: AppTheme.darkGrayColor, fontSize: 14.sp, fontWeight: FontWeight.bold), // Dark Grey or Black based on screenshot? Looks Grey/Black.
                                   ),
                                   
                                    if((double.tryParse(item.discountAmount ?? "0") ?? 0) > 0)
                                      Container(
                                        margin: EdgeInsets.only(top: 5.h),
                                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                                        color: AppTheme.redColor,
                                        child: Text(
                                          "-${CommonMethods.checkNullempty(item.discountPercent)}%", // Using percent if available, screenshot shows %
                                          style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            
                            // Right Actions (Qty)
                            Expanded(
                              flex: 4, 
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                   SizedBox(height: 40.h), // Push to bottom roughly
                                   // Qty Control Box
                                   Container(
                                     width: 100.w,
                                     height: 35.h,
                                     decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(5.r),
                                     ),
                                     child: Row(
                                       children: [
                                         Expanded(
                                           child: InkWell(
                                             onTap: () {
                                                if(qty > 1) {
                                                   onUpdateQty((qty-1).toString());
                                                }
                                             },
                                             child: Center(child: Text("-", style: TextStyle(fontSize: 20.sp, color: Colors.grey))),
                                           ),
                                         ),
                                         Container(width: 1.w, color: Colors.grey.shade400),
                                         Expanded(
                                           child: Center(child: Text("$qty", style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold))),
                                         ),
                                         Container(width: 1.w, color: Colors.grey.shade400),
                                         Expanded(
                                           child: InkWell(
                                             onTap: () {
                                                 onUpdateQty((qty+1).toString());
                                             },
                                             child: Center(child: Text("+", style: TextStyle(fontSize: 20.sp, color: Colors.grey))),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                ],
                              ),
                            ),
                         ],
                       ),
                       
                       // Ordered As
                       if(item.orderedAs != null && item.orderedAs!.isNotEmpty)
                       Padding(
                         padding: EdgeInsets.only(top: 10.h),
                         child: Row(
                           children: [
                             Text("Ordered As : ", style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                             Text(item.orderedAs ?? item.soldAs ?? "Each", style: TextStyle(color: Color(0xFF0038FF), fontSize: 13.sp, fontWeight: FontWeight.bold)),
                           ],
                         ),
                       ),
                     ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox.shrink(); 
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Icon(Icons.image_not_supported, color: Colors.grey);
    }
    String finalUrl = path;
    if (!path.startsWith("http")) {
      finalUrl = "${UrlApiKey.mainUrl}$path";
    }

    return CachedNetworkImage(
      imageUrl: finalUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => Center(child: CustomLoaderWidget(size: 30.w)),
      errorWidget: (context, url, error) => Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
