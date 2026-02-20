import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/products/products_list_screen.dart';
import '../features/account/my_account_screen.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';


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
          bottomNavigationBar: const CustomBottomNavBar(),
        );
      },
    );
  }


}
