import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/products/products_list_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/account/my_account_screen.dart';
import '../providers/dashboard_provider.dart';

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
              CartScreen(), 
              MyAccountScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1B4E9B), // Dark blue
            unselectedItemColor: Colors.grey,
            currentIndex: dashboardProvider.currentIndex,
            selectedLabelStyle: TextStyle(fontSize: 10.sp),
            unselectedLabelStyle: TextStyle(fontSize: 10.sp),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24.sp),
                activeIcon: Icon(Icons.home, size: 24.sp),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined, size: 24.sp),
                label: "Order Now",
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text(
                    dashboardProvider.cartQuantity, 
                    style: TextStyle(fontSize: 8.sp),
                  ),
                  backgroundColor: Colors.red,
                  isLabelVisible: dashboardProvider.cartQuantity != "0",
                  child: Icon(Icons.shopping_cart_outlined, size: 24.sp),
                ),
                label: "My Cart",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24.sp),
                label: "My Account",
              ),
            ],
            onTap: (index) {
              if (index == 0 && dashboardProvider.currentIndex == 0) {
                 // Reset Home? Or do nothing?
                 // Usually popping to root of stack if nested.
              }
              dashboardProvider.setIndex(index);
            },
          ),
        );
      },
    );
  }
}
