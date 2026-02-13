import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/routes/app_routes.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/products/products_list_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/account/my_account_screen.dart';
import '../providers/dashboard_provider.dart';
import '../../core/constants/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // GlobalKeys to control state if needed (e.g., popping to root)
  // For now, IndexedStack handles state preservation.

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: dashboardProvider.currentIndex,
            children: const [
              DashboardScreen(),
              ProductsListScreen(), 
              SizedBox(),
              MyAccountScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = constraints.maxWidth / 4;

                return Stack(
                  children: [
                    BottomNavigationBar(
                      onTap: (index) {
                        if (index == 2) {
                          // Cart Tab -> Open Checkout Screen (Step 0)
                          // Keeping current index as is (visually staying on previous tab)
                          // or maybe we should just push?
                          context.push(AppRoutes.checkout, extra: {'initialStep': 0});
                          return;
                        }

                        if (index == 0 && dashboardProvider.currentIndex == 0) {
                          // Reset Home logic if needed
                        }
                        dashboardProvider.setIndex(index);
                      },
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: AppTheme.primaryColor,
                      unselectedItemColor: AppTheme.primaryColor,
                      currentIndex: dashboardProvider.currentIndex,
                      selectedLabelStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      items: [
                        BottomNavigationBarItem(
                          icon: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/homeicon_new.png",
                                width: 30.sp,
                                height: 30.sp,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(height: 2.h), // ✅ vertical space
                            ],
                          ),
                          label: "Home",
                        ),
                        BottomNavigationBarItem(
                          icon: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/order_now.png",
                                width: 30.sp,
                                height: 30.sp,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                          label: "Order Now",
                        ),
                        BottomNavigationBarItem(
                          icon: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Badge(
                                label: Text(
                                  dashboardProvider.cartQuantity,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                                isLabelVisible:
                                dashboardProvider.cartQuantity != "0",
                                child: Image.asset(
                                  "assets/images/carticon_new.png",
                                  width: 30.sp,
                                  height: 30.sp,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                          label: "My Cart",
                        ),
                        BottomNavigationBarItem(
                          icon: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/profile_tab.png",
                                width: 24.sp,
                                height: 24.sp,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                          label: "My Account",
                        ),
                      ],/*
                      onTap: (index) {
                        if (index == 0 &&
                            dashboardProvider.currentIndex == 0) {}
                        dashboardProvider.setIndex(index);
                      },*/
                    ),

                    /// ✅ Vertical Dividers
                    Positioned(
                      left: itemWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Positioned(
                      left: itemWidth * 2,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Positioned(
                      left: itemWidth * 3,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),

                  ],
                );
              },
            ),
          ),

        );
      },
    );
  }


}
