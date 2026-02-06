import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'widgets/faq_category_item_widget.dart';
import 'faq_details_screen.dart';


class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchFAQCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "FAQ",
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DashboardScreen()));
          },
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isFetchingDrawerData && provider.faqCategoriesResponse == null) {
            return const Center(child: CircularProgressIndicator());
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
    );
  }
}
