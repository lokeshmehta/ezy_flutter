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
        title: const Text("Profile", style: TextStyle(color: AppTheme.white)),
        backgroundColor: AppTheme.orangeColor, // Teal color
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
                            color: AppTheme.orangeColor,
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
                        ),

                      Positioned(
                        bottom: 80.w,
                        right: 150.w,
                        child: GestureDetector(
                          onTap: () {
                            context.push(AppRoutes.myProfile);
                          },
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.white,
                              border: Border.all(color: AppTheme.white, width: 2),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 14.sp,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                ),
                
                SizedBox(height: 20.h),
                
                // Menu Items
                _buildMenuItem(context, 'assets/images/my_fav.png', "My Favourites", () {
                  context.push(AppRoutes.myWishlist);
                }),
                _buildMenuItem(context, 'assets/images/my_orders.png', "My Orders", () {
                   context.push(AppRoutes.myOrders);
                }),

                _buildMenuItem(context, 'assets/images/changepasswordicon.png', "Change Password", () {
                   context.push(AppRoutes.changePassword);
                }),
                _buildMenuItem(context, 'assets/images/addressesicon.png', "Address List", () {
                  // TODO: Navigate to Address Book
                  context.push(AppRoutes.myAddresses);
                }),
                _buildMenuItem(context, 'assets/images/my_logout.png', "Logout", () {
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

  Widget _buildMenuItem(BuildContext context, String assetPath, String title, VoidCallback onTap) {
      return Column(
        children: [
          ListTile(
              leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                      color: AppTheme.white, // Light Teal
                      borderRadius: BorderRadius.circular(8.r)
                  ),
                  child: Image.asset(
                    assetPath,
                    height: 24.sp,
                    width: 26.sp,
                    fit: BoxFit.contain,
                    color: AppTheme.primaryColor,
                  ),
              ),
              title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold , color: AppTheme.primaryColor )),
              trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppTheme.primaryColor),
              onTap: onTap,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.lightGrayBg,
            ),
          ),

        ],
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
