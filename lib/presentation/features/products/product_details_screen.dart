import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_theme.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/url_api_key.dart';
import '../../../core/network/image_cache_manager.dart';
import '../../providers/product_list_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../dashboard/widgets/wishlist_category_dialog.dart';
import './widgets/product_details_bottom_sheet.dart';
import '../../../data/models/product_models.dart';
import '../../../data/models/home_models.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductListProvider>().fetchProductDetails(widget.productId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAddToCart(ProductDetailItem product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsBottomSheet(product: product),
    );
  }

  void _onFavorite(ProductDetailItem product) async {
    final dashboardProvider = context.read<DashboardProvider>();
    await dashboardProvider.fetchWishlistCategories(product.productId!);
    if (!mounted) return;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WishlistCategoryDialog(product: product),
    );

    if (result != null && mounted) {
       context.read<ProductListProvider>().updateProductFavoriteStatus(
         product.productId!, 
         result ? "Yes" : "No"
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          "Product Details",
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<DashboardProvider>(
            builder: (context, dashboardProvider, child) {
              return Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: IconButton(
                  icon: Badge(
                    label: Text(
                      dashboardProvider.cartQuantity,
                      style: TextStyle(fontSize: 10.sp),
                    ),
                    isLabelVisible:  dashboardProvider.cartQuantity != "0",
                    child: Icon(Icons.shopping_cart_outlined, color: AppTheme.primaryColor, size: 28.sp),
                  ),
                  onPressed: () {
                    context.push(AppRoutes.cart);
                  },
                ),
              );
            },
          )
        ],
      ),
      body: Consumer<ProductListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.productDetailItem == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = provider.productDetailItem;
          if (product == null) {
            return const Center(child: Text("Product not found"));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(product),
                _buildInfoTabs(product),
                if (product.similarProducts != null && product.similarProducts!.isNotEmpty)
                  _buildSimilarProducts(product.similarProducts!),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductHeader(ProductDetailItem product) {
    final bool hasPromotion = product.promotionPrice != null && double.tryParse(product.promotionPrice ?? "0")! > 0;
    
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Center(
            child: CachedNetworkImage(
              imageUrl: _getImageUrl(product.image),
              height: 200.h,
              fit: BoxFit.contain,
              cacheManager: ImageCacheManager(),
              placeholder: (context, url) => Container(color: Colors.grey[100], height: 200.h),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
            ),
          ),
          SizedBox(height: 15.h),
          // Title
          Text(
            product.name ?? "",
            style: TextStyle(color: AppTheme.primaryColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          // Short Description
          if (product.shortDescription != null && product.shortDescription!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Text(
                product.shortDescription!,
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
            ),
          // Brand
          SizedBox(height: 5.h),
          Text(
            product.brandName ?? "",
            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
          ),
          SizedBox(height: 10.h),
          // Pricing
          Row(
            children: [
              if (hasPromotion) ...[
                Text(
                  _formatPrice(product.promotionPrice),
                  style: TextStyle(color: Colors.grey[800], fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10.w),
                Text(
                   _formatPrice(product.price),
                   style: TextStyle(
                     color: AppTheme.primaryColor, 
                     fontSize: 16.sp, 
                     decoration: TextDecoration.lineThrough
                   ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.redColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    "-${_calculateDiscount(product.price, product.promotionPrice)}%",
                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else
                Text(
                  _formatPrice(product.price),
                  style: TextStyle(color: Colors.grey[800], fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          SizedBox(height: 15.h),
          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _onAddToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tealColor,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                    minimumSize: Size(double.infinity, 45.h),
                  ),
                  child: Text(
                    product.addedToCart == "Yes" ? "Update Cart [${product.addedQty}]" : "Add To Cart",
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              InkWell(
                onTap: () => _onFavorite(product),
                child: Image.asset(
                  product.isFavourite == "Yes" ? "assets/images/favadded.png" : "assets/images/fav_new.png",
                  width: 45.w,
                  height: 45.w,
                ),
              ),
            ],
          ),
          if (product.minimumOrderQty != null && product.minimumOrderQty != "0" && product.minimumOrderQty != "1")
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                "MOQ : ${product.minimumOrderQty}",
                style: TextStyle(color: AppTheme.redColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTabs(ProductDetailItem product) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: "Product Details"),
            Tab(text: "Other Information"),
          ],
        ),
        SizedBox(
          height: 300.h, // Fixed height for tab content or use Expanded if inside limited height container
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductDetailsTab(product),
              _buildOtherInfoTab(product),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsTab(ProductDetailItem product) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          _buildInfoRow("Item", product.item),
          _buildInfoRow("SKU", product.sku),
          _buildInfoRow("Sold As", product.soldAs),
          _buildInfoRow("Qty Per Carton", product.qtyPerOuter),
          _buildInfoRow("Inner Barcode", product.innerBarcode),
          _buildInfoRow("Outer Barcode", product.outerBarcode),
          _buildInfoRow("Shipper Barcode", product.shipperBarcode),
          _buildInfoRow("Primary Barcode", product.primaryBarcode),
        ],
      ),
    );
  }

  Widget _buildOtherInfoTab(ProductDetailItem product) {
    if (product.productSpecifications == null || product.productSpecifications!.isEmpty) {
      return const Center(child: Text("No specification available"));
    }
    return ListView.separated(
      padding: EdgeInsets.all(15.w),
      itemCount: product.productSpecifications!.length,
      separatorBuilder: (context, index) => Divider(height: 1.h),
      itemBuilder: (context, index) {
        final spec = product.productSpecifications![index]!;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                spec.specification ?? "",
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                spec.description ?? "",
                style: TextStyle(color: Colors.grey[700], fontSize: 13.sp),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.primaryColor, fontSize: 14.sp)),
          Text(value ?? "-", style: TextStyle(color: Colors.grey[700], fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts(List<ProductItem?> similarProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Text(
            "You Might Also Like",
            style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            itemCount: similarProducts.length,
            itemBuilder: (context, index) {
              final product = similarProducts[index];
              if (product == null) return const SizedBox.shrink();
              return _buildSimilarProductItem(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProductItem(ProductItem product) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailsScreen(productId: product.productId!)),
        );
      },
      child: Container(
        width: 140.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                child: CachedNetworkImage(
                  imageUrl: _getImageUrl(product.image),
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(color: Colors.grey[50]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatPrice(product.price),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "${UrlApiKey.mainUrl}$path";
  }

  String _formatPrice(String? price) {
    if (price == null) return "AUD 0.00";
    double? p = double.tryParse(price);
    if (p == null) return "AUD 0.00";
    return "AUD ${p.toStringAsFixed(2)}";
  }

  String _calculateDiscount(String? original, String? promo) {
     if (original == null || promo == null) return "0";
     double o = double.tryParse(original) ?? 0;
     double p = double.tryParse(promo) ?? 0;
     if (o == 0) return "0";
     int discount = (((o - p) / o) * 100).toInt();
     return discount.toString();
  }
}
