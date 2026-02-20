import 'dart:async';

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
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) {
          if (!_pageController.hasClients) return;

          final provider = context.read<DashboardProvider>();
          final suppliers = provider.supplierLogosResponse?.results ?? [];

          if (suppliers.isEmpty) return;

          final totalPages = (suppliers.length / 2).ceil();

          int nextPage = _currentPage + 1;
          if (nextPage >= totalPages) {
            nextPage = 0;
          }

          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
  }

  void _goToPage(bool forward, int totalPages) {
    int nextPage = forward ? _currentPage + 1 : _currentPage - 1;

    if (nextPage < 0) nextPage = totalPages - 1;
    if (nextPage >= totalPages) nextPage = 0;

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final response = provider.supplierLogosResponse;

        if (response == null ||
            response.results == null ||
            response.results!.isEmpty) {
          return const SizedBox.shrink();
        }

        final suppliers = response.results!;
        final totalPages = (suppliers.length / 2).ceil();

        return Column(
          children: [
            SectionHeaderWidget(
              title: "Suppliers",
              onPrevTap: totalPages > 1
                  ? () => _goToPage(false, totalPages)
                  : null,
              onNextTap: totalPages > 1
                  ? () => _goToPage(true, totalPages)
                  : null,
            ),
            SizedBox(
              height: 140.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  final firstIndex = pageIndex * 2;
                  final secondIndex = firstIndex + 1;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: SupplierItemWidget(
                            image: suppliers[firstIndex]?.image,
                            brandName: suppliers[firstIndex]?.brandName,
                            brandId: suppliers[firstIndex]?.brandId
                                ?.toString() ??
                                suppliers[firstIndex]?.companyId
                                    ?.toString(),
                          ),
                        ),

                        Expanded(
                          child: secondIndex < suppliers.length
                              ? SupplierItemWidget(
                            image: suppliers[secondIndex]?.image,
                            brandName:
                            suppliers[secondIndex]?.brandName,
                            brandId: suppliers[secondIndex]?.brandId
                                ?.toString() ??
                                suppliers[secondIndex]?.companyId
                                    ?.toString(),
                          )
                              : const SizedBox(),
                        ),
                      ],
                    ),
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
