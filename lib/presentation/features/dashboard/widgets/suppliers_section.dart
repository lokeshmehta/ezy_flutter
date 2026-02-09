import 'package:ezy_orders_flutter/presentation/features/dashboard/widgets/section_header_widget.dart';
import 'package:ezy_orders_flutter/presentation/features/dashboard/widgets/supplier_item_widget.dart';
import 'package:ezy_orders_flutter/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SuppliersSection extends StatefulWidget {
  const SuppliersSection({super.key});

  @override
  State<SuppliersSection> createState() => _SuppliersSectionState();
}

class _SuppliersSectionState extends State<SuppliersSection> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    setState(() {
      _canScrollLeft = currentScroll > 0;
      _canScrollRight = currentScroll < maxScroll;
    });
  }

  void _scroll(bool forward) {
    if (!_scrollController.hasClients) return;
    const double scrollAmount = 200;
    final double target = forward
        ? _scrollController.offset + scrollAmount
        : _scrollController.offset - scrollAmount;

    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollState);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.supplierLogosResponse;
        if (response == null || response.results == null || response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final suppliers = response.results!;

        return Column(
          children: [
             SectionHeaderWidget(
              title: "Suppliers",
              onPrevTap: _canScrollLeft ? () => _scroll(false) : null,
              onNextTap: _canScrollRight ? () => _scroll(true) : null,
            ),
            SizedBox(
              height: 140.h, 
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                scrollDirection: Axis.horizontal,
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  final item = suppliers[index];
                  if (item == null) return const SizedBox.shrink();

                  return SupplierItemWidget(
                    image: item.image,
                    brandName: item.brandName,
                    brandId: item.brandId?.toString() ?? item.companyId?.toString(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
