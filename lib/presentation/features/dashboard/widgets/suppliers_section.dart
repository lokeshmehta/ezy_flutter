import 'package:ezy_orders_flutter/presentation/features/dashboard/widgets/section_header_widget.dart';
import 'package:ezy_orders_flutter/presentation/features/dashboard/widgets/supplier_item_widget.dart';
import 'package:ezy_orders_flutter/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SuppliersSection extends StatelessWidget {
  const SuppliersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final supplierLogosResponse = provider.supplierLogosResponse;
        
        if (supplierLogosResponse?.results == null ||
            supplierLogosResponse!.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = supplierLogosResponse.results!;

        return Column(
          children: [
            SizedBox(height: 10.h),
            SectionHeaderWidget(
              title: "Suppliers", // Hardcoded as per Android code logic "Suppliers"
              onPrevTap: () {
                // TODO: Implement previous scroll logic
              },
              onNextTap: () {
                // TODO: Implement next scroll logic
              },
              showNavButtons: items.length > 2,
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 180.h, // Adjusted height to fit Card + Text (120image + text + padding + card margins)
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item == null) return const SizedBox.shrink();
                  
                  return SupplierItemWidget(
                    image: item.image,
                    brandName: item.brandName,
                    brandId: item.brandId?.toString() ?? item.companyId?.toString(),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        );
      },
    );
  }
}
