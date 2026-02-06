import 'package:ezy_orders_flutter/presentation/features/drawer/widgets/faq_detail_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../providers/dashboard_provider.dart';


class FAQDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const FAQDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<FAQDetailsScreen> createState() => _FAQDetailsScreenState();
}

class _FAQDetailsScreenState extends State<FAQDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _expandedIndex = -1; // -1 means none expanded

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(page: 1);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData({required int page}) {
    _currentPage = page;
     // Note: DashboardProvider needs to handle specific category fetching.
     // Android: fetchFAQDetails(page, categoryId as global/param).
     // My DashboardProvider method signature needs check.
     final provider = Provider.of<DashboardProvider>(context, listen: false);
     provider.fetchFAQDetails(widget.categoryId, page);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
       final provider = Provider.of<DashboardProvider>(context, listen: false);
       if (!provider.isFetchingDrawerData) {
          _loadData(page: _currentPage + 1);
       }
    }
  }

  String _parseHtmlTitle(String htmlString) {
      if (htmlString.isEmpty) return "";
      final document = parse(htmlString);
      return document.body?.text ?? htmlString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _parseHtmlTitle(widget.categoryName),
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isFetchingDrawerData && provider.faqDetailsResponse == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final details = provider.faqDetailsResponse?.results;

          if (details == null || details.isEmpty) {
             // Android shows "No Data Found" text
            return Center(
              child: Text(
                "No Details Found",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            itemCount: details.length + (provider.isFetchingDrawerData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == details.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ));
              }

              final item = details[index];
              final isExpanded = _expandedIndex == index;

              return FAQDetailItemWidget(
                question: item.name ?? "",
                answer: item.description ?? "",
                isExpanded: isExpanded,
                onTap: () {
                  setState(() {
                    if (_expandedIndex == index) {
                      _expandedIndex = -1; // Collapse
                    } else {
                      _expandedIndex = index; // Expand
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
