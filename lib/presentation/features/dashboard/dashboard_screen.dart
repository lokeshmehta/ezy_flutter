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
import 'widgets/suppliers_section.dart';
import 'widgets/promotions_section.dart';
import 'widgets/popular_categories_section.dart';
import 'widgets/home_blocks_section.dart';
import 'widgets/flash_deals_section.dart';
import 'widgets/popular_ads_section.dart';
import 'widgets/standard_product_sections.dart';
import '../products/products_list_screen.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
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
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.asset(AppAssets.headerLogo, height: 40),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
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
                   const HomeBlocksSection(),
                   _buildProductSections(provider),
                   _buildFooterBanners(provider),
                   const RecentlyAddedSection(), // Added Recently Added after footer banners
                   _buildBottomSuppliers(provider),
                   const SizedBox(height: 100), // Bottom padding
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
                
                return Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                   decoration: const BoxDecoration(color: AppTheme.secondaryColor), // Teal
                   child: SafeArea(
                     bottom: false,
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: user?.image != null && user!.image!.isNotEmpty
                                ? CachedNetworkImageProvider(_getImageUrl(user.image)) as ImageProvider
                                : const AssetImage(AppAssets.userIcon),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${user?.firstName ?? ''} ${user?.lastName ?? ''}", // Fixed: ProfileResult has firstName/lastName
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user?.email ?? "user@example.com",
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Image.asset(AppAssets.menuCloseIcon, width: 20, height: 20, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          )
                       ],
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
                    _buildDrawerItem(AppAssets.favIcon, "My Wishlist", () {}),
                    _buildDrawerItem(AppAssets.myOrdersIcon, "My Orders", () {}),
                    _buildDrawerItem(AppAssets.orderNowIcon, "Order Now", () {}),
                    _buildDrawerItem(AppAssets.promoIcon, "Promotions", () {}),
                    _buildDrawerItem(AppAssets.notifyIcon, "Notifications", () {}),
                    _buildDrawerItem(AppAssets.faqIcon, "FAQ", () {}),
                    _buildDrawerItem(AppAssets.helpIcon, "Help & Support", () {}),
                    _buildDrawerItem(AppAssets.feedbackIcon, "Send Feedback", () {}),
                    _buildDrawerItem(AppAssets.aboutIcon, "About Us", () {}),
                 ],
               ),
             ),
           ),
           // Footer Logout
            Container(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                    // Logic to Clear Prefs and Logout
                    context.go('/login');
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
                      Image.asset(AppAssets.logoutMenuIcon, width: 20, height: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 10),
                      const Text("Logout", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
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
       color: Colors.yellow[100],
       padding: const EdgeInsets.all(10),
       child: const Text(
         "Welcome to the EZY Orders",
         style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 16),
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
           height: 220,
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
                  padding: const EdgeInsets.symmetric(horizontal: 0.0), // Android had margins, but let's check visual
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                       _buildNetworkImage(banner?.image, fit: BoxFit.fill),
                       Container( // Dark overlay for text readability if needed, or just layout
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.3)],
                            ),
                          ),
                       ),
                       Positioned(
                         bottom: 20,
                         left: 20,
                         right: 20,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start, 
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             if (banner?.topCaption != null && banner!.topCaption!.isNotEmpty)
                               Text(
                                 banner.topCaption!,
                                 style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                               ),
                             if (banner?.name != null && banner!.name!.isNotEmpty)
                               Text(
                                 banner.name!, // Android uses Html.fromHtml
                                 style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), 
                               ),
                              if (banner?.bottomCaption != null && banner!.bottomCaption!.isNotEmpty)
                               Text(
                                 banner.bottomCaption!,
                                 style: const TextStyle(color: Colors.white, fontSize: 14),
                               ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle Shop Now Click matching Android Logic
                                  // CommonMethods.groupIDs = banner.groupId
                                  // CommonMethods.categoryIDs = banner.divisionId
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Shop Now: ${banner?.name}")));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor, // Verify Color
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("SHOP NOW"),
                              )
                           ],
                         ),
                       )
                    ],
                  ),
                );
             },
           ),
         ),
         const SizedBox(height: 10),
         DotsIndicator(
           dotsCount: provider.bannersResponse!.results!.length,
           position: _currentBannerIndex,
           decorator: DotsDecorator(
             size: const Size.square(9.0),
             activeSize: const Size(18.0, 9.0),
             activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
             activeColor: AppTheme.primaryColor,
             color: Colors.grey.withValues(alpha: 0.5),
           ),
         ),
         const SizedBox(height: 10),
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
        height: 150, // @dimen/dimen_150
        margin: const EdgeInsets.symmetric(vertical: 10),
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
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      currentIndex: 0, // Always home for Dashboard
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Order Now"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "My Cart"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "My Account"),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
             // Already on Home
            break;
          case 1:
            // Order Now -> Products List
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const ProductsListScreen()),
             );
            break;
          case 2:
            // My Cart -> Proceed to Buy / Cart
            // context.push('/cart'); // Example
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cart Feature Coming Soon")));
            break;
          case 3:
            // My Account
             // Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountScreen()));
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Feature Coming Soon")));
            break;
        }
      },
    );
  }
}
