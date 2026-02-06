import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../data/models/product_models.dart';
import '../../../providers/product_list_provider.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductListProvider>(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "Filter by",
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        "assets/images/closeicon.png",
                        width: 20.w,
                        height: 20.w,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories (Divisions)
                    if (provider.divisionslist.isNotEmpty) ...[
                      _buildSectionHeader("Categories"),
                      _buildDivisionList(provider),
                      SizedBox(height: 15.h),
                    ],

                    // Groups
                    if (provider.groupslist.isNotEmpty) ...[
                      _buildSectionHeader("Categories"), // Re-uses "Categories" title for Groups in Android
                      if (provider.divisionName.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            provider.divisionName,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      _buildGroupList(provider),
                      SizedBox(height: 15.h),
                    ],

                    // Suppliers
                    if (provider.supplierslist.isNotEmpty) ...[
                      _buildSectionHeader("Suppliers"),
                      _buildSupplierList(provider),
                      SizedBox(height: 15.h),
                    ],

                    // Tags
                    if (provider.tagslist.isNotEmpty) ...[
                      _buildSectionHeader("Tags"),
                      _buildTagGrid(provider),
                      SizedBox(height: 15.h),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.onFilterSubmit();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      child: Text(
                        "Apply Filter",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    flex: 4,
                    child: OutlinedButton(
                      onPressed: () {
                        provider.onFilterClear();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        backgroundColor: Colors.grey[100],
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                      child: Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDivisionList(ProductListProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.divisionslist.length,
      itemBuilder: (context, index) {
        final item = provider.divisionslist[index];
        final isSelected = item.selected == "Yes";
        return _buildFilterItem(
          item.groupLevel1 ?? "",
          isSelected,
          () => provider.toggleDivisionSelection(index),
        );
      },
    );
  }

  Widget _buildGroupList(ProductListProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.groupslist.length,
      itemBuilder: (context, index) {
        final item = provider.groupslist[index];
        final isSelected = item.groupSelected == "Yes";
        return _buildFilterItem(
          item.groupLevel2 ?? "",
          isSelected,
          () => provider.toggleGroupSelection(index),
        );
      },
    );
  }

  Widget _buildSupplierList(ProductListProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.supplierslist.length,
      itemBuilder: (context, index) {
        final item = provider.supplierslist[index];
        final isSelected = item.selected == "Yes";
        return _buildFilterItem(
          item.brandName ?? "",
          isSelected,
          () => provider.toggleSupplierSelection(index),
        );
      },
    );
  }

  Widget _buildTagGrid(ProductListProvider provider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 5.h,
      ),
      itemCount: provider.tagslist.length,
      itemBuilder: (context, index) {
        final item = provider.tagslist[index];
        final isSelected = item.tagSelected == "Yes";
        return _buildFilterItem(
          item.tagName ?? "",
          isSelected,
          () => provider.toggleTagSelection(index),
        );
      },
    );
  }

  Widget _buildFilterItem(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Image.asset(
              isSelected ? "assets/images/checked.png" : "assets/images/unchecked.png",
              width: 18.w,
              height: 18.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
