import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

// If flutter_html is not available, I will use simple text parsing or a WebView for About Us content 
// if it contains complex HTML. About Us usually has HTML content.
// AboutUsAdapter suggests a list of items. Let's see if it's text.
// Assuming simple text for now or simple HTML.


import '../../../../data/models/drawer_models.dart';
import '../../../config/theme/app_theme.dart';
import '../../providers/dashboard_provider.dart';


class AboutUsItemWidget extends StatelessWidget {
  final AboutUsItem item;

  const AboutUsItemWidget({super.key, required this.item});

  String _parseHtml(String htmlString) {
      if (htmlString.isEmpty) return "";
      final document = parse(htmlString);
      return document.body?.text ?? htmlString;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             if (item.pageBlockName != null && item.pageBlockName!.isNotEmpty)
              Text(
                item.pageBlockName!,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
             if (item.description != null && item.description!.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  _parseHtml(item.description!),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
             ]
          ],
        ),
      ),
    );
  }
}

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchAboutUs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "About Us",
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
          if (provider.isFetchingDrawerData && provider.aboutUsResponse == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.aboutUsResponse?.results;

          if (list == null || list.isEmpty) {
            return Center(
              child: Text(
                "No Information Available",
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return AboutUsItemWidget(item: list[index]);
            },
          );
        },
      ),
    );
  }
}
