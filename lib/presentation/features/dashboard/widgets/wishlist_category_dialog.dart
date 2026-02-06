
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../data/models/home_models.dart';
import '../../../providers/dashboard_provider.dart';

class WishlistCategoryDialog extends StatefulWidget {
  final ProductItem product;

  const WishlistCategoryDialog({super.key, required this.product});

  @override
  State<WishlistCategoryDialog> createState() => _WishlistCategoryDialogState();
}

class _WishlistCategoryDialogState extends State<WishlistCategoryDialog> {
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.product.title ?? "Product Name",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 24.sp, color: AppTheme.darkGrayColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              "Select Wishlist Categories",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                final categories = provider.wishlistCategories;
                if (categories == null || categories.isEmpty) {
                  return const SizedBox();
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CheckboxListTile(
                        title: Text(
                          category?.categoryName ?? "",
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        value: category?.isSelected ?? false,
                        onChanged: (val) {
                          provider.toggleWishlistCategory(category?.categoryId);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: AppTheme.orangeColor,
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    decoration: InputDecoration(
                      hintText: "Add New Category",
                      hintStyle: TextStyle(fontSize: 12.sp),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    if (_newCategoryController.text.trim().isNotEmpty) {
                      _submitUpdate(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.orangeColor,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    minimumSize: Size(0, 35.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  child: Text(
                    "Add",
                    style: TextStyle(fontSize: 11.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      side: const BorderSide(color: AppTheme.darkGrayColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 13.sp, color: AppTheme.darkGrayColor),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _submitUpdate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeColor,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    child: Text(
                      "Add To List",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitUpdate(BuildContext context) async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final success = await provider.submitWishlistUpdate(
      widget.product.productId!,
      _newCategoryController.text.trim(),
    );
    
    if (!context.mounted) return;

    if (success) {
       Navigator.pop(context); // Close Category Selection Dialog
       _showSuccessDialog(context, provider.errorMsg ?? "Wishlist Updated Successfully");
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(provider.errorMsg ?? "Failed to update wishlist")),
       );
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
         // Auto-dismiss logic
         Future.delayed(const Duration(seconds: 2), () {
            if (ctx.mounted) Navigator.of(ctx).pop();
         });

         return Dialog(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
           child: Container(
             padding: EdgeInsets.all(20.w),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Align(
                   alignment: Alignment.topRight,
                   child: InkWell(
                     onTap: () => Navigator.pop(ctx),
                     child: Icon(Icons.close, size: 24.sp, color: Colors.grey),
                   ),
                 ),
                 SizedBox(height: 10.h),
                 Text(
                   message,
                   textAlign: TextAlign.center,
                   style: TextStyle(
                     fontSize: 16.sp,
                     fontWeight: FontWeight.bold,
                     color: AppTheme.primaryColor,
                   ),
                 ),
                 SizedBox(height: 20.h),
                 ElevatedButton(
                   onPressed: () => Navigator.pop(ctx),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppTheme.primaryColor,
                     padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
                   ),
                   child: Text("Close", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                 )
               ],
             ),
           ),
         );
      }
    );
  }
}
