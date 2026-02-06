
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
  bool _isAddingNewList = false;

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Orange Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.orangeColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add To Wishlist",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 24.sp, color: Colors.white),
                )
              ],
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Product Name (Blue)
                Text(
                  widget.product.title ?? "Product Name",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),

                // Note (Red) for Remove
                Text(
                  "Note : To remove product from Wishlist then unselect and save",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.redColor,
                  ),
                ),
                SizedBox(height: 16.h),

                // Categories List
                Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    final categories = provider.wishlistCategories;
                    if (categories == null || categories.isEmpty) {
                      return const SizedBox();
                    }
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 180.h),
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

                SizedBox(height: 12.h),

                // Add New List Toggle Logic
                if (!_isAddingNewList)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAddingNewList = true;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        "+ Add New List",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.orangeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newCategoryController,
                          decoration: InputDecoration(
                            hintText: "Enter Category Name",
                            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Cancel (X) Button aka 'removefav_lay' logic
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isAddingNewList = false;
                            _newCategoryController.clear();
                          });
                        },
                         child: Container(
                           padding: EdgeInsets.all(5.w),
                           decoration: BoxDecoration(
                             color: AppTheme.redColorOpacity10,
                             shape: BoxShape.circle, 
                           ),
                           child: Icon(Icons.close, size: 16.sp, color: AppTheme.redColor),
                         ),
                      ),
                    ],
                  ),
                SizedBox(height: 16.h),

                // Buttons: Save (Orange) & Close (Grey)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Save Button
                    SizedBox(
                      width: 100.w,
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
                          "Save",
                          style: TextStyle(fontSize: 13.sp, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Close Button
                    SizedBox(
                      width: 100.w,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400], // Grey fill
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        child: Text(
                          "Close",
                          style: TextStyle(fontSize: 13.sp, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitUpdate(BuildContext context) async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    
    // Calculate expected favorite status based on selection
    bool hasSelected = provider.wishlistCategories?.any((c) => c?.isSelected == true) ?? false;
    bool hasNew = _newCategoryController.text.trim().isNotEmpty;
    bool isFav = hasSelected || hasNew;

    final success = await provider.submitWishlistUpdate(
      widget.product.productId!,
      _newCategoryController.text.trim(),
    );
    
    if (!context.mounted) return;

    if (success) {
       Navigator.pop(context, isFav); // Close Category Selection Dialog with result
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
