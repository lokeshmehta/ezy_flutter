import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../core/constants/assets.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/url_api_key.dart';
import '../../../data/models/home_models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().init();
    });
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
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
      backgroundColor: AppTheme.primaryColor, // @color/blue
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // if (provider.errorMsg != null) {
                    //   return Center(child: Text(provider.errorMsg!));
                    // }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMarqueeText(provider),
                          _buildBanners(provider),
                          _buildTopSuppliers(provider), // Best Sellers text in Android but ID says topsuppliers
                          _buildHomeCategories(provider),
                          _buildSection(
                            context,
                            "Best Sellers", // Title from layout xml ID: promotionTitle (Text "Best Sellers") - Wait, duplicates?
                            // Android XML has multiple "Best Sellers" titles hardcoded for different sections.
                            // We should check what the section actually is.
                            // ID: promotionsLlay -> "Promotions"
                            "Promotions",
                            provider.promotionsResponse?.results,
                          ),
                           _buildPopularCategoriesSection(context, provider),
                          _buildSection(
                            context,
                            "Best Sellers",
                            "Best Sellers",
                            provider.bestSellersResponse?.results,
                          ),
                          _buildSection(
                            context,
                            "Flash Deals",
                            "Flash Deals",
                            provider.flashDealsResponse?.results,
                          ),
                          _buildSection(
                            context,
                            "Hot Selling",
                            "Hot Selling",
                            provider.hotSellingResponse?.results,
                          ),
                           _buildSection(
                            context,
                            "New Arrivals",
                            "New Arrivals",
                            provider.newArrivalsResponse?.results,
                          ),
                           _buildSection(
                            context,
                            "Recently Added",
                            "Recently Added",
                            provider.recentlyAddedResponse?.results,
                          ),
                          _buildFooterBanners(provider),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.primaryColor),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Spacer(),
          // Logo
          Consumer<DashboardProvider>(
            builder: (context, provider, _) { 
                 final logoUrl = provider.companyImage;
                 
                  if (logoUrl != null && logoUrl.isNotEmpty) {
                    return CachedNetworkImage(
                      imageUrl: logoUrl.contains("http") ? logoUrl : "${UrlApiKey.companyMainUrl}$logoUrl",
                      height: 50,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => Image.asset(AppAssets.splashLogo, height: 50),
                    );
                  }
                  return Image.asset(AppAssets.splashLogo, height: 50);
            }
          ),
          const Spacer(),
          // Notification & Cart
           IconButton(
            icon: const Icon(Icons.notifications, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          ListTile(
            leading: const Icon(Icons.home, color: AppTheme.primaryColor),
            title: const Text('Home', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {
               Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code, color: AppTheme.primaryColor),
            title: const Text('Scan to Order', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.local_offer, color: AppTheme.primaryColor),
            title: const Text('Promotions', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.notifications, color: AppTheme.primaryColor),
            title: const Text('Notifications', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.shopping_cart, color: AppTheme.primaryColor),
            title: const Text('Order Now', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.favorite, color: AppTheme.primaryColor),
            title: const Text('My Favorites', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.list_alt, color: AppTheme.primaryColor),
            title: const Text('My Orders', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.question_answer, color: AppTheme.primaryColor),
            title: const Text('FAQ', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryColor),
            title: const Text('About', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {},
          ),
           ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.primaryColor),
            title: const Text('Logout', style: TextStyle(color: AppTheme.primaryColor)),
            onTap: () {
               // Implement Logout
               context.go('/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
      return Consumer<DashboardProvider>(
          builder: (context, provider, _) { 
              final profile = provider.profileResponse?.results?.isNotEmpty == true ? provider.profileResponse!.results![0] : null;
              return Container(
                 color: AppTheme.secondaryColor, // @color/tealcolor
                 padding: const EdgeInsets.all(20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const SizedBox(height: 30),
                     CircleAvatar(
                       radius: 30,
                       backgroundImage: (profile?.image != null && profile!.image!.isNotEmpty)
                           ? CachedNetworkImageProvider(profile.image!.contains("http") ? profile.image! : "${UrlApiKey.companyMainUrl}${profile.image}")
                           : null,
                       child: (profile?.image == null || profile!.image!.isEmpty) ? const Icon(Icons.person, size: 40) : null,
                     ),
                     const SizedBox(height: 10),
                     Text(
                       "${profile?.firstName ?? 'Guest'} ${profile?.lastName ?? ''}",
                       style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                     ),
                     Text(
                       profile?.email ?? '',
                       style: const TextStyle(color: Colors.white70, fontSize: 14),
                     ),
                   ],
                 ),
              );
          });
  }

  Widget _buildMarqueeText(DashboardProvider provider) {
    // Logic from Android: if (datalist.results?.get(0)?.show_marque_text=="Yes")
    final profile = provider.profileResponse?.results?.isNotEmpty == true ? provider.profileResponse!.results![0] : null;
    if (profile?.showMarqueText == "Yes" && profile?.marqueText != null) {
      return Container(
        color: Colors.yellow[100], // Default or parse from profile.marqueTextBackgroundColor
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          profile!.marqueText!,
           style: TextStyle(
             color: Colors.red, // parse profile.marqueTextColor
             fontSize: 16, // parse profile.marqueTextSize
             fontStyle: FontStyle.italic, // parse format
           ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBanners(DashboardProvider provider) {
     if (provider.bannersResponse?.results == null || provider.bannersResponse!.results!.isEmpty) {
       return const SizedBox.shrink();
     }
     return SizedBox(
       height: 220,
       child: PageView.builder(
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
     );
  }

  Widget _buildTopSuppliers(DashboardProvider provider) {
      // Android ID: topsuppliersRv (Horizontal)
      // Logic: show if supplier_logos == "Show" (Wait, this might be separate from Suppliers List section?)
      // Android line 330: id topSuppliersLay
      // Check ViewModel: viewmodel?.supplierLogosApiCall()
      if (provider.supplierLogosResponse?.results == null || provider.supplierLogosResponse!.results!.isEmpty) {
        return const SizedBox.shrink();
      }
      return _buildSectionLayout("Suppliers",
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.supplierLogosResponse!.results!.length,
              itemBuilder: (context, index) {
                  final item = provider.supplierLogosResponse!.results![index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                     child: _buildNetworkImage(item?.image),
                  );
              },
            ),
          )
      );
  }

  Widget _buildHomeCategories(DashboardProvider provider) {
      if (provider.homeBlocksResponse?.results == null || provider.homeBlocksResponse!.results!.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 80,
         child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.homeBlocksResponse!.results!.length,
              itemBuilder: (context, index) {
                  final item = provider.homeBlocksResponse!.results![index];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                     child: _buildNetworkImage(item?.image),
                  );
              },
         ),
      );
  }

  // Updated to support ProductItem
  Widget _buildSection(BuildContext context, String title, String categoryKey, List<ProductItem?>? items) {
      if (items == null || items.isEmpty) return const SizedBox.shrink();

      return _buildSectionLayout(title,
        SizedBox(
          height: 180, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildNetworkImage(item?.image),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        item?.title ?? '',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                       "\$${item?.price ?? '0.00'}",
                       style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              );
            },
          ),
        )
      );
  }

  // New method for Popular Categories
  Widget _buildPopularCategoriesSection(BuildContext context, DashboardProvider provider) {
       final items = provider.popularCategoriesResponse?.results;
       if (items == null || items.isEmpty) return const SizedBox.shrink();

       return _buildSectionLayout("Popular Categories",
        SizedBox(
          height: 120, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: _buildNetworkImage(item?.image),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        item?.popularCategory ?? '', 
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      );
  }

  Widget _buildSectionLayout(String title, Widget content) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                   const Icon(Icons.arrow_back_ios, size: 16),
                   const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              )
            ],
          ),
        ),
        content,
      ],
    );
  }
  
  Widget _buildFooterBanners(DashboardProvider provider) {
       if (provider.footerBannersResponse?.results == null || provider.footerBannersResponse!.results!.isEmpty) {
       return const SizedBox.shrink();
     }
     return SizedBox(
       height: 150,
       child: PageView.builder(
         itemCount: provider.footerBannersResponse!.results!.length,
         itemBuilder: (context, index) {
            final banner = provider.footerBannersResponse!.results![index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildNetworkImage(banner?.image),
            );
         },
       ),
     );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomItem(Icons.home, "Home", true),
          _buildBottomItem(Icons.list_alt, "My Orders", false),
          _buildBottomItem(Icons.shopping_cart, "My Cart", false),
          _buildBottomItem(Icons.person, "My Account", false),
        ],
      ),
    );
  }

  Widget _buildBottomItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey),
        Text(label, style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey,
          fontSize: 12
        ))
      ],
    );
  }
}
