import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/url_api_key.dart';
import '../../../core/network/image_cache_manager.dart';
import '../../../core/utils/common_methods.dart';
import '../../providers/product_list_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../dashboard/widgets/wishlist_category_dialog.dart';
import './widgets/product_details_bottom_sheet.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../../data/models/product_models.dart';
import '../../../data/models/home_models.dart';
import '../../widgets/custom_loader_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  bool _isSameCategoryVisible = false;
  bool _isSimilarProductsVisible = false;

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
          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w800, fontSize: 18.sp ,),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: Stack(
        children: [
          Consumer<ProductListProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.productDetailItem == null) {
                return const SizedBox.shrink(); // Overlay handles loading
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
                    if (product.sameCategoryProducts != null && product.sameCategoryProducts!.isNotEmpty)
                      _buildSameCategorySection(product),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            },
          ),
          Consumer<ProductListProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                 return Container(
                    color: Colors.black54,
                    child: Center(
                      child: SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                             CustomLoaderWidget(size: 100.w),
                             Text(
                               "Please Wait",
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                 color: AppTheme.primaryColor,
                                 fontSize: 13.sp,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                          ],
                        ),
                      ),
                    ),
                  );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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
            child: GestureDetector(
              onTap: () => _showImagePopup(context, _getImageUrl(product.image)),
              child: Hero(
                tag: "product_image_${product.productId}",
                child: CachedNetworkImage(
                  imageUrl: _getImageUrl(product.image),
                  height: 200.h,
                  fit: BoxFit.contain,
                  cacheManager: ImageCacheManager(),
                  placeholder: (context, url) => Container(color: Colors.grey[100], height: 200.h),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          // Title
          Text(
            CommonMethods.decodeHtmlEntities(product.name),
            style: TextStyle(color: AppTheme.primaryColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          // Short Description
          if (product.shortDescription != null && product.shortDescription!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Text(
                CommonMethods.decodeHtmlEntities(product.shortDescription),
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
            ),
          // Brand
          SizedBox(height: 5.h),
          Text(
            CommonMethods.decodeHtmlEntities(product.brandName),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 160.w,
                child: ElevatedButton(
                  onPressed: () => _onAddToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tealColor,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.productButtonRadius.r)),
                    minimumSize: Size(double.infinity, 40.h),
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
                  width: 30.h,
                  height: 30.h,
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
          onTap: (index) {
            setState(() {
              // Rebuild to show the selected tab content
            });
          },
          tabs: const [
            Tab(text: "Product Details"),
            Tab(text: "Other Information"),
          ],
        ),
        _tabController.index == 0 
          ? _buildProductDetailsTab(product) 
          : _buildOtherInfoTab(product),
      ],
    );
  }

  Widget _buildProductDetailsTab(ProductDetailItem product) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          _buildInfoRow("Item", product.item),
          _buildInfoRow("SKU", product.sku),
          _buildInfoRow("Sold As", product.soldAs),
          _buildInfoRow("Qty Per Carton", product.qtyPerOuter),
          /*_buildInfoRow("Inner Barcode", product.innerBarcode),
          _buildInfoRow("Outer Barcode", product.outerBarcode),
          _buildInfoRow("Shipper Barcode", product.shipperBarcode),
          _buildInfoRow("Primary Barcode", product.primaryBarcode),*/
        ],
      ),
    );
  }

  Widget _buildOtherInfoTab(ProductDetailItem product) {
    if (product.productSpecifications == null || product.productSpecifications!.isEmpty) {
      return const Center(child: Text("No specification available"));
    }

    // We need to map the specifications to these 4 categories if possible.
    // Assuming the API returns these exact strings in 'specification' or we list all.
    // The user request shows specific buttons: "Important information", "Nutrition information", "Allergens", "Ingredients"
    // Let's filter the specifications to find these.

    final specs = product.productSpecifications!;



    // If we can't find exact matches, we might just list all of them as buttons?
    // Or we stick to the requested 4 and only show if data exists.
    // Let's try to find them. If not found, maybe show "Other"?
    // Actually, looking at the native screenshot, it seems to show these specific categories.
    // I will try to map them. If the API returns different names, this might fail to show.
    // However, I will implement a generic way to show ALL specifications as buttons.
    // This handles dynamic data better.

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      child: Column(
        children: specs.map((spec) {
          if (spec == null || spec.specification == null) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h, left: 15.w, right: 15.w),
            child: Align(
              alignment: Alignment.centerLeft, // keeps it left aligned
              child: ElevatedButton(
                onPressed: () => _showOtherInfoDialog(
                    spec.specification!, spec.description ?? ""),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  CommonMethods.decodeHtmlEntities(spec.specification),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showOtherInfoDialog(String title, String content) {
    // Decode HTML entities
    String decodedContent = CommonMethods.decodeHtmlEntities(content);
    
    // Replace table with custom tag to isolate scrolling
    if (decodedContent.contains("<table")) {
      decodedContent = decodedContent
          .replaceAll('<table', '<table-view><table')
          .replaceAll('</table>', '</table></table-view>');
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.r)), 
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title, 
                      style: TextStyle(color: Colors.blue[900], fontSize: 18.sp, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.blue[900], size: 24.sp),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10.w),
                child: Html(
                    data: decodedContent,
                    style: {
                      "body": Style(
                        fontSize: FontSize(14.sp),
                        color: Colors.black87,
                        lineHeight: LineHeight(1.5),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "table": Style(
                         display: Display.table,
                         border: Border.all(color: Colors.grey.shade300),
                      ),
                      "th": Style(
                        padding: HtmlPaddings.all(8),
                        backgroundColor: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        fontWeight: FontWeight.bold,
                      ),
                      "td": Style(
                        padding: HtmlPaddings.all(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    },
                    extensions: [
                      const TableHtmlExtension(),
                      TagExtension(
                        tagsToExtend: {"table-view"},
                        builder: (extensionContext) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Html(
                              data: extensionContext.innerHtml,
                              shrinkWrap: true,
                              style: {
                                "table": Style(
                                  border: Border.all(color: Colors.grey.shade300),
                                  display: Display.table,
                                ),
                                "th": Style(
                                  padding: HtmlPaddings.all(8),
                                  backgroundColor: Colors.grey.shade100,
                                  border: Border.all(color: Colors.grey.shade300),
                                  fontWeight: FontWeight.bold,
                                  // whiteSpace: WhiteSpace.nowrap, // Not supported, removed
                                ),
                                "td": Style(
                                  padding: HtmlPaddings.all(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                  // whiteSpace: WhiteSpace.nowrap, // Not supported, removed
                                ),
                              },
                              extensions: [const TableHtmlExtension()],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.primaryColor, fontSize: 14.sp , fontWeight: FontWeight.w700)),
          Text(CommonMethods.decodeHtmlEntities(value), style: TextStyle(color: Colors.grey[700], fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts(List<ProductItem?> similarProducts) {
    final count = similarProducts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 "You Might Also Like",
                 style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
               ),
               SizedBox(height: 4.h),
             //  if (!_isSimilarProductsVisible)
                 GestureDetector(
                   onTap: () {
                     setState(() {
                       _isSimilarProductsVisible = true;
                     });
                   },
                   child: RichText(
                     text: TextSpan(
                       text: "$count other products related to this product. ",
                       style: TextStyle(color: Colors.blue, fontSize: 12.sp),
                       children: [
                         TextSpan(
                           text: "Click here",
                           style: TextStyle(
                             color: Colors.blue, 
                             fontWeight: FontWeight.bold,
                             decoration: TextDecoration.underline,
                           ),
                         ),
                         TextSpan(
                           text: " to view",
                           style: TextStyle(
                             color: Colors.blue,

                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
             ],
          ),
        ),
        
        if (_isSimilarProductsVisible)
          SizedBox(
            height: 300.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              itemCount: count,
              itemBuilder: (context, index) {
                final item = similarProducts[index];
                if (item == null) return const SizedBox.shrink();
                
                return SizedBox(
                  width: 170.w,
                  child: _buildProductCard(item),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSameCategorySection(ProductDetailItem product) {
    final sameCategoryProducts = product.sameCategoryProducts!;
    final count = sameCategoryProducts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 "In The Same Category",
                 style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
               ),
               SizedBox(height: 4.h),
           //    if (!_isSameCategoryVisible)
                 GestureDetector(
                   onTap: () {
                     setState(() {
                       _isSameCategoryVisible = true;
                     });
                   },
                   child: RichText(
                     text: TextSpan(
                       text: "$count other products in the same category. ",
                       style: TextStyle(color: Colors.blue, fontSize: 12.sp),
                       children: [
                         TextSpan(
                           text: "Click here",
                           style: TextStyle(
                             color: Colors.blue, 
                             fontWeight: FontWeight.bold,
                             decoration: TextDecoration.underline,
                           ),
                         ),
                         TextSpan(
                           text: " to view",
                           style: TextStyle(
                             color: Colors.blue,

                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
             ],
          ),
        ),
        
        if (_isSameCategoryVisible)
          SizedBox(
            height: 300.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              itemCount: count,
              itemBuilder: (context, index) {
                final item = sameCategoryProducts[index];
                if (item == null) return const SizedBox.shrink();
                
                return SizedBox(
                  width: 170.w,
                  child: _buildProductCard(item),
                );
              },
            ),
          ),
      ],
    );
  }
  
  Widget _buildProductCard(ProductItem item) {
    // Standardizing UI to match native Android:
    // 1. Top Stripe: Orange, "Carton (X Units)" or "Each"
    // 2. Image: Standard
    // 3. Details: Title, etc.
    // 4. Action: "Add To Cart" (Orange Rounded) + Heart Icon (Outline/Filled)

    final bool isOutOfStock = item.qtyStatus == "Out Of Stock";
    final bool canAddToCart = item.supplierAvailable == "1" && item.productAvailable == "1" && !isOutOfStock;
    final bool hasPromotion = item.promotionPrice != null && double.tryParse(item.promotionPrice ?? "0")! > 0;
    
    // Logic for stripe text
    String stripeText = "";
    if (item.soldAs == "Each") {
      stripeText = "Each";
    } else if (item.soldAs != null && item.qtyPerOuter != null) {
      stripeText = "${item.soldAs} (${item.qtyPerOuter} Units)";
    } else {
      stripeText = item.soldAs ?? "";
    }

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.all(2.w),
        child: InkWell(
          onTap: () {
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailsScreen(productId: item.productId!)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Top Stripe (Orange)
               if (stripeText.isNotEmpty)
                 Container(
                   width: double.infinity,
                   padding: EdgeInsets.symmetric(vertical: 4.h),
                   decoration: const BoxDecoration(
                     color: AppTheme.secondaryColor, // Orange
                   ),
                   alignment: Alignment.center,
                   child: Text(
                     stripeText,
                     style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                   ),
                 ),

               // Image
               Expanded(
                 flex: 5,
                 child: Stack(
                   children: [
                      Center(
                        child: Padding(
                           padding: EdgeInsets.all(5.w),
                           child: CachedNetworkImage(
                             imageUrl: _getImageUrl(item.image),
                             fit: BoxFit.contain,
                             placeholder: (context, url) => Container(color: Colors.grey[100]),
                             errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                           ),
                        ),
                      ),
                      if (item.label != null && item.label!.isNotEmpty)
                         Positioned(
                           top: 5.h,
                           left: 5.w,
                           child: Container(
                             padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                             decoration: BoxDecoration(color: AppTheme.redColor, borderRadius: BorderRadius.circular(3.r)),
                             child: Text(item.label!, style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                           ),
                         ),
                   ],
                 ),
               ),
               
               // Details
               Expanded(
                 flex: 6,
                 child: Padding(
                   padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 8.w),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(item.brandName ?? "", style: TextStyle(color: Colors.black54, fontSize: 11.sp, fontWeight: FontWeight.w800), maxLines: 1),
                       Text(item.title ?? "", style: TextStyle(color: AppTheme.blackColor, fontSize: 12.sp, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                       
                       // Price
                       SizedBox(height: 5.h),
                        if (!hasPromotion)
                          Text(_formatPrice(item.price), style: TextStyle(color: Colors.grey[700], fontSize: 12.sp, fontWeight: FontWeight.w800))
                        else
                          Row(children: [
                             Text(_formatPrice(item.price), style: TextStyle(color: Colors.grey, fontSize: 12.sp, decoration: TextDecoration.lineThrough)),
                             SizedBox(width: 5.w),
                             Text(_formatPrice(item.promotionPrice), style: TextStyle(color: AppTheme.redColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ]),
                          
                       const Spacer(),
                       
                       // Action Row: Add To Cart + Heart
                       Row(
                         children: [
                           Expanded(
                             child: InkWell(
                               onTap: () => _onAddToCart(ProductDetailItem.fromJson(item.toJson())), 
                               child: Container(
                                 height: 32.h,
                                 alignment: Alignment.center,
                                 decoration: BoxDecoration(
                                   color: canAddToCart ? AppTheme.secondaryColor : AppTheme.redColor, // Orange like screenshot
                                   borderRadius: BorderRadius.circular(20.r), // Rounded
                                 ),
                                 child: Text(
                                   isOutOfStock ? "Out Of Stock" : "Add To Cart", 
                                   style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)
                                 ),
                               ),
                             ),
                           ),
                           SizedBox(width: 8.w),
                           InkWell(
                             onTap: () {
                               // Assuming we can re-use _onFavorite logic but it might expect a dynamic object or ProductDetailItem
                               // _onFavorite expects 'dynamic' which usually is cast to ProductDetailItem or ProductItem model
                               // Let's wrap item in _onFavorite call.
                               _onFavorite(ProductDetailItem.fromJson(item.toJson()));
                             },
                             child: Icon(
                               item.isFavourite == "Yes" ? Icons.favorite : Icons.favorite_border,
                               color: item.isFavourite == "Yes" ? AppTheme.redColor : AppTheme.primaryColor, // Or Grey/Primary
                               size: 26.sp,
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 ),
               ),
            ],
          ),
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

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  width: 1.sw,
                  height: 1.sh,
                  cacheManager: ImageCacheManager(),
                  placeholder: (context, url) => Center(child: CustomLoaderWidget(size: 50.w)),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
