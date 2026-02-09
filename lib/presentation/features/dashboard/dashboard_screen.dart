import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../core/constants/assets.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/url_api_key.dart';
// import '../../../data/models/home_models.dart'; // Unused
import '../../../core/network/image_cache_manager.dart';
import '../../providers/product_list_provider.dart';
import '../drawer/about_us_screen.dart';
import '../drawer/faq_screen.dart';
import '../drawer/help_support_screen.dart';
import '../drawer/notifications_screen.dart';
import '../drawer/promotions_screen.dart';
import '../drawer/send_feedback_screen.dart';
import 'widgets/suppliers_section.dart';
import 'widgets/promotions_section.dart';
import 'widgets/popular_categories_section.dart';
import 'widgets/home_blocks_section.dart';
import 'widgets/flash_deals_section.dart';
import 'widgets/popular_ads_section.dart';
import 'widgets/standard_product_sections.dart';
import 'widgets/logout_dialog.dart';
import '../products/products_list_screen.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>   with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;
  late AnimationController _marqueeController;
  late Animation<double> _marqueeAnimation;

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22), // Speed (increase = slower)
    )..repeat();
    _marqueeAnimation = Tween<double>(
      begin: 1.0,
      end: -1.0,
    ).animate(CurvedAnimation(
      parent: _marqueeController,
      curve: Curves.linear,
    ));
    _bannerController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().init();
      _startBannerTimer();
    });
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final provider = context.read<DashboardProvider>();
      if (provider.bannersResponse?.results != null && provider.bannersResponse!.results!.isNotEmpty) {
        int nextIndex = _currentBannerIndex + 1;
        if (nextIndex >= provider.bannersResponse!.results!.length) {
          nextIndex = 0;
        }
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _marqueeController.dispose();

    super.dispose();
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      debugPrint("Image URL Path is Null or Empty");
      return "";
    }
    debugPrint("Processing Image Path: $path");
    if (path.startsWith("http") || path.startsWith("https")) return path;
    return "${UrlApiKey.mainUrl}$path";
  }

  Widget _buildNetworkImage(String? path, {BoxFit fit = BoxFit.cover}) {
    final url = _getImageUrl(path);
    if (url.isEmpty) {
      return Image.asset(
        AppAssets.placeholder,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
      ); 
    }
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: ImageCacheManager(), // Use custom cache manager with SSL bypass
      fit: fit,
      errorWidget: (context, url, error) => Image.asset(
        AppAssets.placeholder,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
      ),
      placeholder: (context, url) => Container(color: Colors.grey[200]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, size: 24.sp, weight: 300 , color: AppTheme.primaryColor,), // Thinner menu icon
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.asset(AppAssets.appLogo, height: 36.h),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, size: 24.sp, weight: 300 , color: AppTheme.primaryColor,), // Thinner notification icon
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMsg != null) {
            // Android parity: Show toast/dialog but allow retry? For now simplified error screen
             return Center(child: Text(provider.errorMsg!));
          }

          return RefreshIndicator(
            onRefresh: () async {
               provider.init();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildMarquee(provider),
                   _buildBanners(provider),
                   _buildTopSuppliers(provider),
                  SizedBox(height: 15.h),
                   const HomeBlocksSection(),
                   _buildProductSections(provider),
                   _buildFooterBanners(provider),
                   const RecentlyAddedSection(), // Added Recently Added after footer banners
                   _buildBottomSuppliers(provider),
                   SizedBox(height: 100.h), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
           Consumer<DashboardProvider>(
             builder: (context, provider, _) {
                final user = provider.profileResponse?.results?.isNotEmpty == true 
                    ? provider.profileResponse!.results![0] 
                    : null;
                
                return InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    context.push('/my-profile');
                  },
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                     decoration: const BoxDecoration(color: AppTheme.secondaryColor), // Teal
                     child: SafeArea(
                       bottom: false,
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                            CircleAvatar(
                              radius: 30.r,
                              backgroundColor: Colors.white,
                              backgroundImage: user?.image != null && user!.image!.isNotEmpty
                                  ? CachedNetworkImageProvider(_getImageUrl(user.image)) as ImageProvider
                                  : const AssetImage(AppAssets.userIcon),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${user?.firstName ?? ''} ${user?.lastName ?? ''}", 
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user?.email ?? "user@example.com",
                                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Image.asset(AppAssets.menuCloseIcon, width: 20.w, height: 20.w, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            )
                         ],
                       ),
                     ),
                  ),
                );
             },
           ),
           Expanded(
             child: SingleChildScrollView(
               child: Column(
                 children: [
                    _buildDrawerItem(AppAssets.scanIcon, "Scan to Order", () {}),
                    _buildDrawerItem(AppAssets.favIcon, "My Wishlist", () {
                      context.pop(); // Close drawer
                      context.push('/my-wishlist');
                    }),
                    _buildDrawerItem(AppAssets.myOrdersIcon, "My Orders", () {
                      context.pop();
                      context.push('/my-orders');
                    }),
                    _buildDrawerItem(AppAssets.orderNowIcon, "Order Now", () {
                      context.pop();
                      final productProvider = context.read<ProductListProvider>();
                      productProvider.clearFilters();
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const ProductsListScreen()));
                    }),
                    _buildDrawerItem(AppAssets.promoIcon, "Promotions", () {
                      context.pop();
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const PromotionsScreen()));
                    }),
                    _buildDrawerItem(AppAssets.notifyIcon, "Notifications", () {
                      context.pop();
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsScreen()));
                    }),
                    _buildDrawerItem(AppAssets.faqIcon, "FAQ", () {
                      context.pop();
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const FAQScreen()));
                    }),
                    _buildDrawerItem(AppAssets.helpIcon, "Help & Support", () {
                      context.pop();
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const HelpSupportScreen()));
                    }),
                    _buildDrawerItem(AppAssets.feedbackIcon, "Send Feedback", () {
                      context.pop();
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const SendFeedbackScreen()));
                    }),
                    _buildDrawerItem(AppAssets.aboutIcon, "About Us", () {
                      context.pop();
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const AboutUsScreen()));
                    }),
                 ],
               ),
             ),
           ),
           // Footer Logout
            Container(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => LogoutDialog(
                        onYes: () async {
                           await context.read<DashboardProvider>().logout();
                           if (context.mounted) {
                             context.go('/login');
                           }
                        },
                      ),
                    );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppAssets.logoutMenuIcon, width: 20.w, height: 20.w, color: AppTheme.primaryColor),
                      SizedBox(width: 10.w),
                      Text("Logout", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    ],
                  ),
                ),
              ),
            ),
           const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String iconPath, String title, VoidCallback onTap) {
    return ListTile(
      leading: Image.asset(iconPath, width: 20, height: 20, color: AppTheme.primaryColor), // Blue tint
      title: Text(
        title, 
        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 0,
    );
  }


  Widget _buildMarquee(DashboardProvider provider) {
    return Container(
      height: 35.h,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
      ),
      clipBehavior: Clip.hardEdge, // ✅ now allowed
      child: AnimatedBuilder(
        animation: _marqueeAnimation,
        builder: (context, child) {
          return FractionalTranslation(
            translation: Offset(_marqueeAnimation.value, 0),
            child: child,
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            "Welcome to the EZY Orders",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w800,
              fontSize: 14.sp,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }


  Widget _buildBanners(DashboardProvider provider) {
     if (provider.bannersResponse?.results == null || provider.bannersResponse!.results!.isEmpty) {
       return const SizedBox.shrink();
     }
     return Column(
       children: [
         SizedBox(
           height: 180.h, // Adjusted height to match compact look
           child: PageView.builder(
             controller: _bannerController,
             onPageChanged: (index) {
               setState(() {
                 _currentBannerIndex = index;
               });
             },
             itemCount: provider.bannersResponse!.results!.length,
             itemBuilder: (context, index) {
                final banner = provider.bannersResponse!.results![index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w), // Matches Image 2 side margins
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                         _buildNetworkImage(banner?.image, fit: BoxFit.fill),
                         // Overlay Card (Bottom Left)
                         Positioned(
                           bottom: 50.h,
                           left: 15.w,
                           child: Container(
                             width: 140.w, // Approximate width from screenshot
                             padding: EdgeInsets.all(6.w),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(6.r),
                               border: Border.all(
                                 color: Colors.orange,
                                 width: 1.5,          // Adjust thickness if needed
                               ),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.black.withValues(alpha: 0.1),
                                   blurRadius: 10,
                                   offset: const Offset(0, 5),
                                 )
                               ],
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 if (banner?.topCaption != null && banner!.topCaption!.isNotEmpty)
                                   Text(
                                     banner.topCaption!,
                                     style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                                   ),
                                 Text(
                                   banner?.name ?? "",
                                   style: TextStyle(
                                     color: Colors.black,
                                     fontSize:10.sp,
                                     fontWeight: FontWeight.bold
                                   ),
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                                 SizedBox(height: 8.h),
                                 InkWell(
                                   onTap: () {
                                     final productProvider = context.read<ProductListProvider>();
                                     productProvider.clearFilters();
                                     
                                     if (banner?.groupId != null && banner?.groupId != "0") {
                                       productProvider.setGroup(banner!.groupId.toString());
                                     }
                                     if (banner?.products != null && banner!.products!.isNotEmpty) {
                                       productProvider.setSelectedProducts(banner.products!);
                                     }
                                     if (banner?.divisionId != null && banner?.divisionId != "0") {
                                       productProvider.setCategory(banner!.divisionId.toString());
                                     }
                                     
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(builder: (context) => const ProductsListScreen()),
                                     );
                                   },
                                   child: Container(
                                     padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                                     decoration: BoxDecoration(
                                       color: const Color(0xFFFCBD5F), // Orange color
                                       borderRadius: BorderRadius.circular(20.r),
                                     ),
                                     child: Text(
                                       "Shop Now",
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 10.sp,
                                         fontWeight: FontWeight.bold
                                       ),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         )
                      ],
                    ),
                  ),
                );
             },
           ),
         ),
         SizedBox(height: 8.h),
         DotsIndicator(
           dotsCount: provider.bannersResponse!.results!.length,
           position: _currentBannerIndex,
           decorator: DotsDecorator(
             size: Size.square(6.0.w), // Smaller dots
             activeSize: Size(12.0.w, 6.0.w), // Ellipse for active
             activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0.r)),
             activeColor: const Color(0xFF1B4E9B), // Dark blue from Image 2
             color: Colors.grey.withValues(alpha: 0.3),
           ),
         ),
         SizedBox(height: 10.h),
       ],
     );
  }

  Widget _buildTopSuppliers(DashboardProvider provider) {
    if (provider.supplierLogosPosition == "Top") {
      return const SuppliersSection();
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomSuppliers(DashboardProvider provider) {
    if (provider.supplierLogosPosition != "Top") {
      return const SuppliersSection();
    }
    return const SizedBox.shrink();
  }
   

  Widget _buildProductSections(DashboardProvider provider) {
     return Column(
       children: [
          PromotionsSection(),
          PopularCategoriesSection(),
          BestSellersSection(),
          FlashDealsSection(),
          HotSellingSection(),
          NewArrivalsSection(),
          PopularAdsSection(),
       ],
     );
  }

  Widget _buildFooterBanners(DashboardProvider provider) {
      if (provider.footerBannersResponse?.results == null ||
          provider.footerBannersResponse!.results!.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 150.h, // @dimen/dimen_150
        margin: EdgeInsets.symmetric(vertical: 10.h , ),
        child: PageView.builder(
           itemCount: provider.footerBannersResponse!.results!.length,
           itemBuilder: (context, index) {
             final banner = provider.footerBannersResponse!.results![index];
             if (banner?.image == null) return const SizedBox.shrink();

             return Padding(
               padding: const EdgeInsets.symmetric(horizontal: 5.0),
               child: InkWell(
                 onTap: () {
                    // Handle footer banner click
                 },
                 child: _buildNetworkImage(banner!.image, fit: BoxFit.contain),
               ),
             );
           },
        ),
      );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1B4E9B), // Dark blue
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      selectedLabelStyle: TextStyle(fontSize: 10.sp),
      unselectedLabelStyle: TextStyle(fontSize: 10.sp),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24.sp),
          activeIcon: Icon(Icons.home, size: 24.sp),
          label: "Home"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined, size: 24.sp),
          label: "Order Now"
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text("1", style: TextStyle(fontSize: 8.sp)),
            backgroundColor: Colors.red,
            child: Icon(Icons.shopping_cart_outlined, size: 24.sp),
          ),
          label: "My Cart"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24.sp),
          label: "My Account"
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
             // Already on Home
            break;
          case 1:
            // Order Now -> Products List
             final productProvider = context.read<ProductListProvider>();
             productProvider.clearFilters();
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const ProductsListScreen()),
             );
            break;
          case 2:
            // My Cart -> Proceed to Buy / Cart
            context.push('/cart'); 
            // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cart Feature Coming Soon")));
            break;
          case 3:
            // My Account
             context.push('/my-account');
             // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Feature Coming Soon")));
            break;
        }
      },
    );
  }
}
