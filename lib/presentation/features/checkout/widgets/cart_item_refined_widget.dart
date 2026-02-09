
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/models/cart_models.dart';
import 'package:provider/provider.dart';
import '../../../providers/checkout_provider.dart';

class CartItemRefinedWidget extends StatelessWidget {
  final CartProduct item;
  final bool showHeader;
  final String brandName;
  final String brandId;

  const CartItemRefinedWidget({
    super.key,
    required this.item,
    this.showHeader = false,
    required this.brandName,
    required this.brandId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) _buildHeader(context),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5.w),
                      child: Image.network(
                        item.image ?? "",
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  
                  // content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Trash
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Expanded(
                               child: Text(
                                 item.title ?? "",
                                 style: TextStyle(
                                   color: Color(0xFF0038FF), // Blue Title
                                   fontSize: 14.sp,
                                   fontWeight: FontWeight.bold,
                                 ),
                                 maxLines: 2,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                             InkWell(
                               onTap: () {
                                 context.read<CheckoutProvider>().deleteCartItem(item.productId!, brandId);
                               },
                               child: Padding(
                                 padding: EdgeInsets.all(5.w),
                                 child: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                               ),
                             ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        
                        // Price & Discount row
                        Row(
                          children: [
                            Text(
                              "\$${item.salePrice}", // Assuming salePrice is the display price
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            if((double.tryParse(item.discountAmount ?? "0") ?? 0) > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    "Save \$${item.discountAmount}",
                                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                                  ),
                                ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        
                        // Ordered As & Stocks
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Ordered As: ", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                              TextSpan(text: item.orderedAs ?? "", style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text.rich(
                           TextSpan(
                             children: [
                               TextSpan(text: "MOQ: ", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                               TextSpan(text: item.minimumOrderQty ?? "1", style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w500)),
                               TextSpan(text: " | ", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                               TextSpan(text: "Availability: ", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                               TextSpan(text: item.productAvailable ?? "In Stock", style: TextStyle(
                                  color: (item.productAvailable?.toLowerCase().contains("no") ?? false) ? Colors.red : Colors.green,
                                  fontSize: 12.sp, fontWeight: FontWeight.w500)
                               ),
                             ],
                           ),
                        ),

                         SizedBox(height: 10.h),
                         // Qty Control
                         Row(
                           children: [
                             _buildQtyBtn(Icons.remove, () {
                                int q = int.tryParse(item.qty?.toString() ?? "0") ?? 0;
                                if(q > 1) {
                                   context.read<CheckoutProvider>().updateCartItem(item.productId!, (q-1).toString(), brandId, item.salePrice ?? "0", item.orderedAs ?? "");
                                }
                             }),
                             Container(
                               width: 40.w,
                               alignment: Alignment.center,
                               child: Text(
                                 item.qty?.toString() ?? "0",
                                 style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                               ),
                             ),
                             _buildQtyBtn(Icons.add, () {
                                int q = int.tryParse(item.qty?.toString() ?? "0") ?? 0;
                                context.read<CheckoutProvider>().updateCartItem(item.productId!, (q+1).toString(), brandId, item.salePrice ?? "0", item.orderedAs ?? "");
                             }),
                           ],
                         ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if(item.notAvailableDaysMessage != null && item.notAvailableDaysMessage!.isNotEmpty)
                 Padding(
                   padding: EdgeInsets.only(top: 8.h),
                   child: Text(
                     item.notAvailableDaysMessage!,
                     style: TextStyle(color: Colors.red, fontSize: 11.sp, fontStyle: FontStyle.italic),
                   ),
                 ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Text(
        brandName,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4.r),
          ),
          padding: EdgeInsets.all(2.w),
          child: Icon(icon, size: 16.sp, color: Colors.grey.shade700),
        ),
      );
  }
}
