import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

// If flutter_html is not available, I will use simple text parsing or a WebView for About Us content 
// if it contains complex HTML. About Us usually has HTML content.
// AboutUsAdapter suggests a list of items. Let's see if it's text.
// Assuming simple text for now or simple HTML.


import '../../../../data/models/drawer_models.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/custom_loader_widget.dart';
import '../../../../core/utils/common_methods.dart';
import '../../../../config/theme/app_theme.dart';


class AboutUsItemWidget extends StatelessWidget {
  final AboutUsItem item;

  const AboutUsItemWidget({super.key, required this.item});



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
                Html(
                  data: CommonMethods.decodeHtmlEntities(item.description),
                  style: {
                    "body": Style(
                      fontSize: FontSize(14.sp),
                      color: Colors.grey[700],
                      lineHeight: LineHeight(1.5),
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                  },
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
          style: TextStyle(color: Colors.black, fontSize: 18.sp),
        ),
        backgroundColor: Colors.white,
        elevation: 4, // 👈 controls shadow intensity
        shadowColor: Colors.black.withOpacity(0.25),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back , color: Colors.black,),
          onPressed: () {
             Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              if (provider.isFetchingDrawerData && provider.aboutUsResponse == null) {
                return const SizedBox.shrink(); // Overlay handles it
              }

              final list = provider.aboutUsResponse?.results;

              if (list == null || list.isEmpty) {
                return Center(
                  child: Text(
                    "No Data Found",
                    style: TextStyle(fontSize: 16.sp, color: Colors.black ,fontWeight: FontWeight.bold),
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
          Consumer<DashboardProvider>(
             builder: (context, provider, child) {
                if (provider.isFetchingDrawerData && provider.aboutUsResponse == null) {
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
