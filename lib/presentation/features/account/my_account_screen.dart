import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/url_api_key.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account", style: TextStyle(color: AppTheme.white)),
        backgroundColor: AppTheme.orderSuccessTeal, // Teal color
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          // If profile is not loaded, we might show loading or use cached data
          // But typically Dashboard loads profile on init.
          
          final user = provider.profileResponse?.results?.firstOrNull;
          final userName = "${user?.firstName ?? ''} ${user?.lastName ?? ''}".trim();
          final userEmail = user?.email ?? '';
          final userImage = user?.image ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Profiler (Overlapping style like Android)
                Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                        Container(
                            height: 80.h,
                            color: AppTheme.orderSuccessTeal,
                        ),
                        // Card with User Info
                             Container(
                               margin: EdgeInsets.only(top: 40.h, left: 16.w, right: 16.w),
                               padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 16.h),
                               decoration: BoxDecoration(
                                   color: AppTheme.white,
                                   borderRadius: BorderRadius.circular(10.r),
                                   boxShadow: [
                                       BoxShadow(
                                           color: AppTheme.shadowBlack, // Using standard constant or AppTheme.shadowBlack if available
                                           blurRadius: 5,
                                           offset: const Offset(0, 2)
                                       )
                                   ]
                               ),
                               child: Column(
                                   children: [
                                       Text(userName.isEmpty ? "Guest User" : userName, 
                                           style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                                       SizedBox(height: 4.h),
                                       Text(userEmail, 
                                           style: TextStyle(fontSize: 14.sp, color: AppTheme.darkGrayColor)),
                                       SizedBox(height: 16.h),
                                       // Edit Profile Button (Small)
                                       InkWell(
                                           onTap: () {
                                             context.push(AppRoutes.myProfile);
                                           },
                                           child: Container(
                                               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                                               decoration: BoxDecoration(
                                                   color: AppTheme.orangeColor,
                                                   borderRadius: BorderRadius.circular(20.r)
                                               ),
                                               child: Text("Edit Profile", 
                                                   style: TextStyle(color: AppTheme.white, fontSize: 12.sp)),
                                           ),
                                       )
                                   ],
                               ),
                           ),
                        // Profile Image (Circle)
                        Positioned(
                            top: 10.h,
                            child: Container(
                                width: 70.w,
                                height: 70.w,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.white, width: 3),
                                    color: AppTheme.lightGrayBg,
                                    image: (userImage.isNotEmpty && !userImage.contains("default"))
                                        ? DecorationImage(
                                            image: NetworkImage(userImage.startsWith("http") ? userImage : "${UrlApiKey.mainUrl}$userImage"),
                                            fit: BoxFit.cover
                                        )
                                        : null
                                ),
                                child: (userImage.isEmpty || userImage.contains("default")) 
                                     ? Icon(Icons.person, size: 40.w, color: AppTheme.darkGrayColor)
                                     : null,
                            ),
                        )
                    ],
                ),
                
                SizedBox(height: 20.h),
                
                // Menu Items
                _buildMenuItem(context, Icons.inventory_2_outlined, "My Orders", () {
                   context.push(AppRoutes.myOrders);
                }),
                _buildMenuItem(context, Icons.favorite_border, "My Favourites", () {
                   context.push(AppRoutes.myWishlist);
                }),
                _buildMenuItem(context, Icons.location_on_outlined, "Manage Addresses", () {
                     // TODO: Navigate to Address Book
                     context.push(AppRoutes.myAddresses);
                }),
                _buildMenuItem(context, Icons.lock_outline, "Change Password", () {
                   context.push(AppRoutes.changePassword);
                }),
                _buildMenuItem(context, Icons.logout, "Logout", () {
                    _showLogoutDialog(context, provider);
                }),
                
                 SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
      return Card(
          elevation: 1, // Soft shadow as per audit
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: ListTile(
              leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                      color: AppTheme.lightTealBg, // Light Teal
                      borderRadius: BorderRadius.circular(8.r)
                  ),
                  child: Icon(icon, color: AppTheme.orderSuccessTeal, size: 24.sp),
              ),
              title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppTheme.darkGrayColor),
              onTap: onTap,
          ),
      );
  }
  
  void _showLogoutDialog(BuildContext context, DashboardProvider provider) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
              title: const Text("Logout"),
              content: const Text("Are you sure you want to logout?"),
              actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                  ),
                  TextButton(
                      onPressed: () {
                          Navigator.pop(ctx);
                          provider.logout(); // No context argument
                          context.go(AppRoutes.login);
                      },
                      child: const Text("Logout"),
                  ),
              ],
          )
      );
  }
}
