
class BannersResponse {
  int? status;
  String? message;
  List<BannerItem?>? results;

  BannersResponse({this.status, this.message, this.results});

  factory BannersResponse.fromJson(Map<String, dynamic> json) {
    return BannersResponse(
      status: json['status'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List).map((i) => i != null ? BannerItem.fromJson(i) : null).toList()
          : null,
    );
  }
}

class BannerItem {
  String? bannerId; // banner_id
  String? name; // name (was banner_title)
  String? image; // image (was banner_image)
  String? topCaption; // top_caption
  String? bottomCaption; // bottom_caption
  String? linkImageTo; // link_image_to
  String? divisionId; // division_id
  String? groupId; // group_id
  String? productId; // product_id
  String? sortOrder; // sort_order
  String? externalLink; // external_link
  String? products; // products

  BannerItem({
    this.bannerId,
    this.name,
    this.image,
    this.topCaption,
    this.bottomCaption,
    this.linkImageTo,
    this.divisionId,
    this.groupId,
    this.productId,
    this.sortOrder,
    this.externalLink,
    this.products,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      bannerId: json['banner_id']?.toString(),
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      topCaption: json['top_caption']?.toString(),
      bottomCaption: json['bottom_caption']?.toString(),
      linkImageTo: json['link_image_to']?.toString(),
      divisionId: json['division_id']?.toString(),
      groupId: json['group_id']?.toString(),
      productId: json['product_id']?.toString(),
      sortOrder: json['sort_order']?.toString(),
      externalLink: json['external_link']?.toString(),
      products: json['products']?.toString(),
    );
  }
}

class FooterBannersResponse {
    int? status;
    String? message;
    List<BannerItem?>? results;

    FooterBannersResponse({this.status, this.message, this.results});
    factory FooterBannersResponse.fromJson(Map<String, dynamic> json) {
        return FooterBannersResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? BannerItem.fromJson(i) : null).toList()
                : null,
        );
    }
}


class ProfileResponse {
  int? status;
  String? message;
  List<ProfileResult?>? results;
  int? resultsCount;
  String? cartQuantity; 
  String? suppliersCount; 
  String? suppliers;

  ProfileResponse({
    this.status,
    this.message,
    this.results,
    this.resultsCount,
    this.cartQuantity,
    this.suppliersCount,
    this.suppliers,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'],
      message: json['message'],
      results: json['results'] != null
          ? (json['results'] as List).map((i) => i != null ? ProfileResult.fromJson(i) : null).toList()
          : null,
      resultsCount: json['results_count'],
      cartQuantity: json['cart_quantity']?.toString(), 
      suppliersCount: json['suppliers_count']?.toString(), 
      suppliers: json['suppliers']?.toString(),
    );
  }
}

class ProfileResult {
  String? customerId; 
  String? firstName; 
  String? lastName; 
  String? email;
  String? mobile;
  String? image;
  String? unreadNotificationsCount; 
  String? wishlistPageHeading; 
  String? status;
  String? showPortalIn; 
  String? accNum; 
  String? allowScanToOrder; 
  String? priceDisplayTypeDecimals; 
  String? priceDisplayType; 
  String? supplierLogosPosition; 
  String? maximumNumberOfSuppliersProductsForFreeShipping; 
  String? showMarqueText; 
  String? marqueText; 
  String? marqueTextColor; 
  String? marqueTextSize; 
  String? marqueTextBackgroundColor; 
  String? marqueTextFormat; 
  String? bestSellers; 
  String? productsAdvertisements; 
  String? hotSelling; 
  String? supplierLogos; 
  String? popularCategories; 
  String? flashDeals; 
  String? newArrivals; 
  String? recentlyAdded; 
  String? customerMessageForAdditionalSuppliersCharge; 
  String? showShippingSegment; 
  String? showSoldAs;

  ProfileResult({
    this.customerId,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.image,
    this.unreadNotificationsCount,
    this.wishlistPageHeading,
    this.status,
    this.showPortalIn,
    this.accNum,
    this.allowScanToOrder,
    this.priceDisplayTypeDecimals,
    this.priceDisplayType,
    this.supplierLogosPosition,
    this.maximumNumberOfSuppliersProductsForFreeShipping,
    this.showMarqueText,
    this.marqueText,
    this.marqueTextColor,
    this.marqueTextSize,
    this.marqueTextBackgroundColor,
    this.marqueTextFormat,
    this.bestSellers,
    this.productsAdvertisements,
    this.hotSelling,
    this.supplierLogos,
    this.popularCategories,
    this.flashDeals,
    this.newArrivals,
    this.recentlyAdded,
    this.customerMessageForAdditionalSuppliersCharge,
    this.showShippingSegment,
    this.showSoldAs,
  });

  factory ProfileResult.fromJson(Map<String, dynamic> json) {
    return ProfileResult(
      customerId: json['customer_id']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      image: json['image']?.toString(),
      unreadNotificationsCount: json['unread_notifications_count']?.toString(),
      wishlistPageHeading: json['wishlist_page_heading']?.toString(),
      status: json['status']?.toString(),
      showPortalIn: json['show_portal_in']?.toString(),
      accNum: json['acc_num']?.toString(),
      allowScanToOrder: json['allow_scan_to_order']?.toString(),
      priceDisplayTypeDecimals: json['price_display_type_decimals']?.toString(),
      priceDisplayType: json['price_display_type']?.toString(),
      supplierLogosPosition: json['supplier_logos_position']?.toString(),
      maximumNumberOfSuppliersProductsForFreeShipping: json['maximum_number_of_suppliers_products_for_free_shipping']?.toString(),
      showMarqueText: json['show_marque_text']?.toString(),
      marqueText: json['marque_text']?.toString(),
      marqueTextColor: json['marque_text_color']?.toString(),
      marqueTextSize: json['marque_text_size']?.toString(),
      marqueTextBackgroundColor: json['marque_text_background_color']?.toString(),
      marqueTextFormat: json['marque_text_format']?.toString(),
      bestSellers: json['best_sellers']?.toString(),
      productsAdvertisements: json['products_advertisements']?.toString(),
      hotSelling: json['hot_selling']?.toString(),
      supplierLogos: json['supplier_logos']?.toString(),
      popularCategories: json['popular_categories']?.toString(),
      flashDeals: json['flash_deals']?.toString(),
      newArrivals: json['new_arrivals']?.toString(),
      recentlyAdded: json['recently_added']?.toString(),
      customerMessageForAdditionalSuppliersCharge: json['customer_message_for_additional_suppliers_charge']?.toString(),
      showShippingSegment: json['show_shipping_segment']?.toString(),
      showSoldAs: json['show_sold_as']?.toString(),
    );
  }
}

class HomeBlocksResponse {
    int? status;
    String? message;
    List<HomeBlockItem?>? results;

    HomeBlocksResponse({this.status, this.message, this.results});
    factory HomeBlocksResponse.fromJson(Map<String, dynamic> json) {
         return HomeBlocksResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? HomeBlockItem.fromJson(i) : null).toList()
                : null,
        );
    }
}

class HomeBlockItem {
  String? id;
  String? companyId; 
  String? name;
  String? image;
  String? description;
  String? sortOrder; 
  String? status;

  HomeBlockItem({this.id, this.companyId, this.name, this.image, this.description, this.sortOrder, this.status});

  factory HomeBlockItem.fromJson(Map<String, dynamic> json) {
    return HomeBlockItem(
      id: json['id']?.toString(),
      companyId: json['company_id']?.toString(),
      name: json['name']?.toString(),
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      sortOrder: json['sort_order']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class ProductItem {
    String? productId; 
    String? title;
    String? description;
    String? image;
    String? brandName; 
    String? brandId; 
    String? price;
    String? promotionPrice; 
    String? stockUnlimited; 
    String? qtyStatus; 
    String? availableStockQty; 
    String? minimumOrderQty; 
    String? soldAs; 
    String? isFavourite; 
    String? productAvailable; // Changed to String to handle 1/"1"
    String? supplierAvailable; // Changed to String
    String? notAvailableDaysMessage; 
    String? addedToCart; 
    String? addedQty; 
    String? addedSubTotal; 
    String? orderedAs; 
    String? qtyPerOuter; // Added for unit logic
    String? apiData;
    String? divisionId;
    String? groupId;
    String? sku;
    String? gstPercentage;
    String? fromDate;
    String? toDate;
    String? hasPromotion; // Added field

    ProductItem({
        this.productId,
        this.title,
        this.description,
        this.image,
        this.brandName,
        this.brandId,
        this.price,
        this.promotionPrice,
        this.stockUnlimited,
        this.qtyStatus,
        this.availableStockQty,
        this.minimumOrderQty,
        this.soldAs,
        this.isFavourite,
        this.productAvailable,
        this.supplierAvailable,
        this.notAvailableDaysMessage,
        this.addedToCart,
        this.addedQty,
        this.addedSubTotal,
        this.orderedAs,
        this.qtyPerOuter,
        this.apiData,
        this.divisionId,
        this.groupId,
        this.sku,
        this.gstPercentage,
        this.fromDate,
        this.toDate,
        this.hasPromotion,
    });

    factory ProductItem.fromJson(Map<String, dynamic> json) {
        return ProductItem(
            productId: json['product_id']?.toString(),
            title: json['title']?.toString(),
            description: json['description']?.toString(),
            image: json['image']?.toString(),
            brandName: json['brand_name']?.toString(),
            brandId: json['brand_id']?.toString(),
            price: json['price']?.toString(),
            promotionPrice: json['promotion_price']?.toString(),
            stockUnlimited: json['stock_unlimited']?.toString(),
            qtyStatus: json['qty_status']?.toString(),
            availableStockQty: json['available_stock_qty']?.toString(),
            minimumOrderQty: json['minimum_order_qty']?.toString(),
            soldAs: json['sold_as']?.toString(),
            isFavourite: json['is_favourite']?.toString(),
            productAvailable: json['product_available']?.toString(),
            supplierAvailable: json['supplier_available']?.toString(),
            notAvailableDaysMessage: json['not_available_days_message']?.toString(),
            addedToCart: json['added_to_cart']?.toString(),
            addedQty: json['added_qty']?.toString(),
            addedSubTotal: json['added_sub_total']?.toString(),
            orderedAs: json['ordered_as']?.toString(),
            qtyPerOuter: json['qty_per_outer']?.toString(),
            apiData: json['api_data']?.toString(),
            divisionId: json['division_id']?.toString(),
            groupId: json['group_id']?.toString(),
            sku: json['sku']?.toString(),
            gstPercentage: json['gst_percentage']?.toString(),
            fromDate: json['from_date']?.toString(),
            toDate: json['to_date']?.toString(),
            hasPromotion: json['has_promotion']?.toString(),
        );
    }
}

class DashboardProductsResponse {
    int? status;
    String? message;
     List<ProductItem?>? results;

    DashboardProductsResponse({this.status, this.message, this.results});
    factory DashboardProductsResponse.fromJson(Map<String, dynamic> json) {
        return DashboardProductsResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? ProductItem.fromJson(i) : null).toList()
                : null,
        );
    }
}

class PromotionsResponse {
    int? status;
    String? message;
     List<ProductItem?>? results;

    PromotionsResponse({this.status, this.message, this.results});
    factory PromotionsResponse.fromJson(Map<String, dynamic> json) {
         return PromotionsResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? ProductItem.fromJson(i) : null).toList()
                : null,
        );
    }
}

class FlashDealsResponse {
     int? status;
    String? message;
     List<ProductItem?>? results;

    FlashDealsResponse({this.status, this.message, this.results});
    factory FlashDealsResponse.fromJson(Map<String, dynamic> json) {
         return FlashDealsResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? ProductItem.fromJson(i) : null).toList()
                : null,
        );
    }
}

class PopularCategoryItem {
    String? divisionId; 
    String? groupLevel1; 
    String? image;
    String? popularCategory; 
    String? categoryProductsCount; // Added

    PopularCategoryItem({this.divisionId, this.groupLevel1, this.image, this.popularCategory, this.categoryProductsCount});

    factory PopularCategoryItem.fromJson(Map<String, dynamic> json) {
        return PopularCategoryItem(
            divisionId: json['division_id']?.toString(),
            groupLevel1: json['group_level_1']?.toString(),
            image: json['image']?.toString(),
            popularCategory: json['popular_category']?.toString(),
            categoryProductsCount: json['category_products_count']?.toString(),
        );
    }
}

class PopularCategoriesResponse {
    int? status;
    String? message;
    List<PopularCategoryItem?>? results;

    PopularCategoriesResponse({this.status, this.message, this.results});
    factory PopularCategoriesResponse.fromJson(Map<String, dynamic> json) {
         return PopularCategoriesResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? PopularCategoryItem.fromJson(i) : null).toList()
                : null,
        );
    }
}

class BrandItem {
    String? brandId;
    String? brandName;
    String? image;
    String? brandNumber;
    String? topBrand;
    String? majorBrand;
    String? status;
    String? companyId;

    BrandItem({this.brandId, this.brandName, this.image, this.brandNumber, this.topBrand, this.majorBrand, this.status, this.companyId});

    factory BrandItem.fromJson(Map<String, dynamic> json) {
        return BrandItem(
            brandId: json['brand_id']?.toString(),
            brandName: json['brand_name']?.toString(),
            image: json['image']?.toString(),
            brandNumber: json['brand_number']?.toString(),
            topBrand: json['top_brand']?.toString(),
            majorBrand: json['major_brand']?.toString(),
            status: json['status']?.toString(),
            companyId: json['company_id']?.toString(),
        );
    }
}


class SupplierLogosResponse {
     int? status;
    String? message;
    List<BrandItem?>? results; 

     SupplierLogosResponse({this.status, this.message, this.results});
      factory SupplierLogosResponse.fromJson(Map<String, dynamic> json) {
         return SupplierLogosResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? BrandItem.fromJson(i) : null).toList()
                : null,
        );
    }
}

class PopularAdvertosementsResponse {
    int? status;
    String? message;
    List<SupplierItem?>? results;

    PopularAdvertosementsResponse({this.status, this.message, this.results});
    factory PopularAdvertosementsResponse.fromJson(Map<String, dynamic> json) {
         return PopularAdvertosementsResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? SupplierItem.fromJson(i) : null).toList()
                : null,
        );
    }
}

class SupplierItem {
  String? image;
  String? externalLink;
  String? brandid;

  SupplierItem({this.image, this.externalLink, this.brandid});

  factory SupplierItem.fromJson(Map<String, dynamic> json) {
    return SupplierItem(
      image: json['image']?.toString(),
      externalLink: json['external_link']?.toString(),
      brandid: json['brand_id']?.toString(),
    );
  }
}
