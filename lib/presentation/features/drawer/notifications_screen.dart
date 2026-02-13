import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/url_api_key.dart';

import '../../../../data/models/drawer_models.dart';

import '../../../config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/notification_item_widget.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

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
     final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.fetchNotifications(page);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
       final provider = Provider.of<DashboardProvider>(context, listen: false);
       if (!provider.isFetchingDrawerData) {
          _loadData(page: _currentPage + 1);
       }
    }
  }

  void _showNotificationDetails(NotificationItem item) {
    if (item.status == "UnRead" && item.notificationId != null) {
      Provider.of<DashboardProvider>(context, listen: false).changeNotificationStatus(item.notificationId!);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String imageUrl = item.image ?? "";
        if (imageUrl.isNotEmpty && !imageUrl.startsWith("http")) {
          imageUrl = "${UrlApiKey.mainUrl}$imageUrl";
        }
        bool hasImage = imageUrl.isNotEmpty;
        bool isBeforeImage = item.imagePosition == "Before Message";
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // Header with Close
               Align(
                 alignment: Alignment.topRight,
                 child: IconButton(
                   icon: Icon(Icons.close, color: Colors.grey),
                   onPressed: () => Navigator.pop(context),
                 ),
               ),
               
               Padding(
                 padding: EdgeInsets.symmetric(horizontal: 16.w),
                 child: Column(
                   children: [
                     if (hasImage && isBeforeImage)
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl, 
                            height: 150.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                     
                     Text(
                       item.title ?? "",
                       style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                       textAlign: TextAlign.center,
                     ),
                     SizedBox(height: 10.h),
                     Text(
                       item.description ?? "",
                       style: TextStyle(fontSize: 14.sp),
                       textAlign: TextAlign.center,
                     ),

                     if (hasImage && !isBeforeImage)
                        Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl, 
                            height: 150.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                     
                     SizedBox(height: 20.h),
                     
                     ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppTheme.primaryColor,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                       ),
                       onPressed: () => Navigator.pop(context),
                       child: Text("OK", style: TextStyle(color: Colors.white)),
                     ),
                     SizedBox(height: 10.h),
                   ],
                 ),
               )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Notifications",
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
             if (context.canPop()) {
               context.pop();
             } else {
               context.go(AppRoutes.dashboard);
             }
          },
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
           if (provider.isFetchingDrawerData && provider.notificationsResponse == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final notifications = provider.notificationsResponse?.results;

          if (notifications == null || notifications.isEmpty) {
            return Center(
              child: Text(
                "No Notifications Available",
                style: TextStyle(fontSize: 16.sp, color: AppTheme.secondaryColor , fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(10.w),
            itemCount: notifications.length + (provider.isFetchingDrawerData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == notifications.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ));
              }
              final item = notifications[index];
              return NotificationItemWidget(
                item: item,
                onTap: () => _showNotificationDetails(item),
                onDelete: () {
                   if (item.notificationId != null) {
                      provider.deleteNotification(item.notificationId!);
                   }
                },
              );
            },
          );
        },
      ),
    );
  }
}
