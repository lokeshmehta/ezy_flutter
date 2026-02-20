import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'widgets/faq_category_item_widget.dart';
import '../../widgets/custom_loader_widget.dart';
import 'faq_details_screen.dart';
import '../../../../config/theme/app_theme.dart';


class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      await provider.fetchFAQCategories();
      
      if (mounted) {
        final categories = provider.faqCategoriesResponse?.results;
        if (categories != null && categories.length == 1) {
          // If only one category, skip selection and go directly to details
          if (mounted) {
             Navigator.pushReplacement(
               context,
               MaterialPageRoute(builder: (c) => FAQDetailsScreen(
                 categoryId: categories.first.categoryId ?? "",
                 categoryName: categories.first.categoryName ?? "",
               )),
             );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "FAQ",
          style: TextStyle(color: Colors.black, fontSize: 18.sp ,),
        ),
        backgroundColor: Colors.white,
        elevation: 4, // 👈 controls shadow intensity
        shadowColor: Colors.black.withOpacity(0.25),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              if (provider.isFetchingDrawerData && provider.faqCategoriesResponse == null) {
                return const SizedBox.shrink(); // Overlay handles it
              }

              final categories = provider.faqCategoriesResponse?.results;

              if (categories == null || categories.isEmpty) {
                return Center(
                  child: Text(
                    "No FAQ Categories Found",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return FAQCategoryItemWidget(
                    item: item,
                    onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (c) => FAQDetailsScreen(
                           categoryId: item.categoryId ?? "",
                           categoryName: item.categoryName ?? "",
                         )),
                       );
                    },
                  );
                },
              );
            },
          ),
          Consumer<DashboardProvider>(
             builder: (context, provider, child) {
                if (provider.isFetchingDrawerData && provider.faqCategoriesResponse == null) {
                   return Container(
                      color: Colors.black54,
                      child: Center(
                        child: SizedBox(
                          width: 100.w,
                          height: 100.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                               CustomLoaderWidget(size: 100.w),
                               Text(
                                 "Please Wait",
                                 textAlign: TextAlign.center,
                                 style: TextStyle(
                                   color: AppTheme.primaryColor,
                                   fontSize: 13.sp,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                            ],
                          ),
                        ),
                      ),
                    );
                }
                return const SizedBox.shrink();
             },
          ),
        ],
      ),
    );
  }
}
