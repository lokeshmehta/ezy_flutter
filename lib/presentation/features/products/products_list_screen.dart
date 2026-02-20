import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/common_methods.dart';
import '../../providers/product_list_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../dashboard/widgets/wishlist_category_dialog.dart';
import './widgets/product_list_item.dart';
import './widgets/product_grid_item.dart';
import './widgets/sort_dialog.dart';
import './widgets/filter_dialog.dart';
import './widgets/product_details_bottom_sheet.dart';
import '../../widgets/custom_loader_widget.dart';

class ProductsListScreen extends StatefulWidget {
  final String? supplierId;
  final String? backNav;
  final String? pageTitle;
  final Widget? headerWidget;

  const ProductsListScreen({
    super.key,
    this.supplierId,
    this.backNav,
    this.pageTitle,
    this.headerWidget,
  });

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductListProvider>().init();
    });
    
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<ProductListProvider>();
      if (!provider.isLoading && provider.productsResponse?.results?.isNotEmpty == true) {
         provider.fetchProducts(page: provider.pageCount + 1, isLoadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => const SortDialog(),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const FilterDialog(),
    );
  }

  void _onAddToCart(dynamic product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsBottomSheet(product: product),
    );
  }

  void _onFavorite(dynamic product) async {
    final dashboardProvider = context.read<DashboardProvider>();
    await dashboardProvider.fetchWishlistCategories(product.productId!);
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => WishlistCategoryDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.pageTitle ?? "Products",
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4, // 👈 controls shadow intensity
        shadowColor: Colors.black.withOpacity(0.25),
        surfaceTintColor: Colors.transparent,
        leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.secondaryColor),
              onPressed: () => Navigator.pop(context),
            )
          : null,

      ),
      body: Column(
        children: [
          if (widget.headerWidget != null) widget.headerWidget!,
          SizedBox(height: 12.h,),

          // Product Count Here
          Consumer<ProductListProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    provider.productsResponse?.totalRecords != null
                        ? "${provider.productsResponse!.totalRecords} ${provider.productsResponse!.totalRecords == '1' ? 'Product' : 'Products'} found"
                        : "Products",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),

          // Toggle Bar (Sort, Filter, Grid/List)
          _buildToggleBar(),

          // Search Bar
          _buildSearchBar(),

          // Main List/Grid
          Expanded(
            child: Consumer<ProductListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return Center(child: CustomLoaderWidget(size: 50.w));
                }
                
                if (provider.products.isEmpty && !provider.isLoading) {
                  return const Center(child: Text("No products found"));
                }

                return provider.isGridView 
                    ? _buildGridView(provider) 
                    : _buildListView(provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Icon(Icons.search, color: Colors.grey, size: 20.sp),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search Product",
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      style: TextStyle(fontSize: 14.sp),
                      onSubmitted: (value) {
                        context.read<ProductListProvider>().setSearchText(value);
                        context.read<ProductListProvider>().fetchProducts(page: 1);
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey, size: 20.sp),
                      onPressed: () {
                        setState(() {
                           _searchController.clear();
                        });
                        context.read<ProductListProvider>().setSearchText("");
                        context.read<ProductListProvider>().fetchProducts(page: 1);
                      },
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            height: 45.h,
            width: 45.h,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.white, size: 24.sp),
              onPressed: () {
                context.read<ProductListProvider>().setSearchText(_searchController.text);
                context.read<ProductListProvider>().fetchProducts(page: 1);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToggleBar() {
    return Consumer<ProductListProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 2.h),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 10.h),
              Row(
                children: [
                  // Availability Spinner
                  Expanded(
                    flex: 48,
                    child: Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: CommonMethods.filterSelected == "All Products" && !["Show Products", "Available Products", "Not Available Products"].contains(CommonMethods.filterSelected) 
                              ? "Show Products" 
                              : (["Show Products", "All Products", "Available Products", "Not Available Products"].contains(CommonMethods.filterSelected) ? CommonMethods.filterSelected : "All Products"),
                          isExpanded: true,
                          items: ["Show Products", "All Products", "Available Products", "Not Available Products"]
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 12.sp, color: AppTheme.blackColor , fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              provider.onProductAvaSelected(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Sort, Filter, Grid Toggles
                  Expanded(
                    flex: 52,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildIconButton(
                          iconPath: "assets/images/sort_icon.png",
                          fallbackIcon: Icons.sort,
                          onTap: _showSortDialog,
                          isActive: provider.isSortApplied,
                        ),
                        SizedBox(width: 8.w),
                        _buildIconButton(
                          iconPath: "assets/images/filter_icon.png",
                          fallbackIcon: Icons.filter_list,
                          onTap: _showFilterDialog,
                          isActive: provider.isFilterApplied,
                        ),
                        SizedBox(width: 8.w),
                        _buildIconButton(
                          iconPath: provider.isGridView ? "assets/images/listview_icon.png" : "assets/images/gridview_icon.png",
                          fallbackIcon: provider.isGridView ? Icons.view_list : Icons.grid_view,
                          onTap: () => provider.setGridView(!provider.isGridView),
                          isActive: false, // Toggle button doesn't use "Active" style in Android, acts as toggle
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    String? iconPath,
    required IconData fallbackIcon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: 38.w,
        height: 38.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.white,
          border: Border.all(
            color: isActive
                ? AppTheme.primaryColor
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: iconPath != null
            ? Image.asset(
          iconPath,
          fit: BoxFit.contain,
          color: isActive
              ? Colors.white
              : AppTheme.primaryColor, // applies tint if png is single-color
        )
            : Icon(
          fallbackIcon,
          color: isActive
              ? Colors.white
              : AppTheme.primaryColor,
          size: 20.sp,
        ),
      ),
    );
  }


  Widget _buildListView(ProductListProvider provider) {
    final dashboardProvider = context.read<DashboardProvider>();
    final showSoldAs = dashboardProvider.profileResponse?.results?[0]?.showSoldAs == "Yes";

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      itemCount: provider.products.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.products.length) {
          return Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomLoaderWidget(size: 30.w),
          ));
        }
        final product = provider.products[index];
        return ProductListItem(
          item: product,
          showSoldAs: showSoldAs,
          onAddToCart: (qty) => _onAddToCart(product), // Pass qty if we update logic later, currently just trigger
          onFavorite: () => _onFavorite(product),
        );
      },
    );
  }

  Widget _buildGridView(ProductListProvider provider) {
    final dashboardProvider = context.read<DashboardProvider>();
    final showSoldAs = dashboardProvider.profileResponse?.results?[0]?.showSoldAs == "Yes";

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 300.h, // Increased height for Quantity Row
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: provider.products.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
         if (index == provider.products.length) {
           return Center(child: CustomLoaderWidget(size: 30.w));
         }
         final product = provider.products[index];
         return ProductGridItem(
            item: product, 
            showSoldAs: showSoldAs, // Now available in method scope since I added it above ListView
            onAddToCart: (qty) => _onAddToCart(product),
            onFavorite: () => _onFavorite(product),
         );
      },
    );
  }
}
