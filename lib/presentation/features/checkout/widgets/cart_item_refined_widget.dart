
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/models/cart_models.dart';
import 'package:provider/provider.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../core/constants/app_theme.dart';

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
                elevation: 5,
                color: Colors.white,
                margin: EdgeInsets.all(5.w),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       // Supplier Title (Using brandName passed down)
                       if(showHeader)
                       Padding(
                         padding: EdgeInsets.only(bottom: 5.h),
                         child: Text(
                           brandName,
                           style: TextStyle(color: Color(0xFF0038FF), fontSize: 14.sp, fontWeight: FontWeight.bold),
                         ),
                       ),
                       
                       Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            // Image
                            Container(
                              width: 78.w,
                              height: 78.w,
                              margin: EdgeInsets.only(right: 8.w),
                              child: Image.network(
                                item.image ?? "",
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                            
                            // Center Details
                            Expanded(
                              flex: 48, // weight 0.48
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                     item.title?.toUpperCase() ?? "",
                                     style: TextStyle(color: AppTheme.textColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                   ),
                                   SizedBox(height: 2.h),
                                   Text(
                                     "INR ${item.salePrice ?? "0.00"}",
                                     style: TextStyle(color: AppTheme.darkGrayColor, fontSize: 13.sp),
                                   ),
                                   // Promo/Discount Logic
                                   if((double.tryParse(item.discountAmount ?? "0") ?? 0) > 0) ...[
                                      Text(
                                        "INR ${item.normalPrice ?? "0.00"}", // Original Price
                                        style: TextStyle(color: AppTheme.darkGrayColor, fontSize: 13.sp, decoration: TextDecoration.lineThrough),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(3.w),
                                        color: AppTheme.redColor,
                                        child: Text(
                                          "Save ${item.discountAmount}",
                                          style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                        ),
                                      )
                                   ]
                                ],
                              ),
                            ),
                            
                            // Right Actions (Delete & Qty)
                            Expanded(
                              flex: 52, // weight 0.52
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                   // Delete Icon
                                   InkWell(
                                     onTap: () {
                                        context.read<CheckoutProvider>().deleteCartItem(item.productId!, brandId);
                                     },
                                     child: Padding(
                                       padding: EdgeInsets.all(2.w),
                                       child: Icon(Icons.delete, color: AppTheme.redColor, size: 28.w),
                                     ),
                                   ),
                                   SizedBox(height: 5.h), // margin top 15 in xml roughly
                                   
                                   // Qty Control Box
                                   Container(
                                     width: 110.w,
                                     height: 32.h,
                                     decoration: BoxDecoration(
                                        color: Colors.white, // edittext_bg usually white with border
                                        border: Border.all(color: AppTheme.darkGrayColor),
                                        borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
                                     ),
                                     child: Row(
                                       children: [
                                         // Decrease
                                         Expanded(
                                           child: InkWell(
                                             onTap: () {
                                                if(qty > 1) {
                                                   context.read<CheckoutProvider>().updateCartItem(item.productId!, (qty-1).toString(), brandId, item.salePrice ?? "0", item.orderedAs ?? "");
                                                }
                                             },
                                             child: Center(child: Text("-", style: TextStyle(fontSize: 22.sp, color: AppTheme.darkGrayColor))),
                                           ),
                                         ),
                                         Container(width: 1.w, color: AppTheme.darkGrayColor),
                                         // Qty Text
                                         Expanded(
                                           child: Center(child: Text("$qty", style: TextStyle(fontSize: 13.sp, color: AppTheme.darkGrayColor))),
                                         ),
                                         Container(width: 1.w, color: AppTheme.darkGrayColor),
                                         // Increase
                                         Expanded(
                                           child: InkWell(
                                             onTap: () {
                                                 context.read<CheckoutProvider>().updateCartItem(item.productId!, (qty+1).toString(), brandId, item.salePrice ?? "0", item.orderedAs ?? "");
                                             },
                                             child: Center(child: Text("+", style: TextStyle(fontSize: 22.sp, color: AppTheme.darkGrayColor))),
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
                       
                       // Ordered As (Optional)
                       if(item.orderedAs != null && item.orderedAs!.isNotEmpty)
                       Padding(
                         padding: EdgeInsets.only(top: 3.h),
                         child: Row(
                           children: [
                             Text("Ordered As : ", style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                             Text(item.orderedAs!, style: TextStyle(color: Color(0xFF0038FF), fontSize: 13.sp)),
                           ],
                         ),
                       ),
                       
                       // Verification / Min Order (Simulated)
                       Padding(
                         padding: EdgeInsets.only(top: 5.h),
                         child: Text(
                           item.productAvailable ?? "In Stock",
                           style: TextStyle(color: AppTheme.redColor, fontSize: 13.sp, fontWeight: FontWeight.bold),
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
    // Header logic moved inside Card or maintained here? 
    // In XML, Supplier Title is INSIDE the Card view's LinearLayout.
    // So I moved it inside above. This method might be redundant if we strictly follow XML where title is part of the card content.
    // But `cart_listitem.xml` shows `supplierTitleTxt` inside the main `LinearLayout` inside `CardView`.
    // So it is inside.
    return SizedBox.shrink(); 
  }
}
