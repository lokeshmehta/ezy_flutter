
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
  String? bannerImage; // banner_image
  String? bannerTitle; // banner_title
  String? categoryId; // category_id
  String? linkImageTo; // link_image_to
  String? offerId; // offer_id
  String? supplierId; // supplier_id
  String? tagId; // tag_id

  BannerItem({
    this.bannerId,
    this.bannerImage,
    this.bannerTitle,
    this.categoryId,
    this.linkImageTo,
    this.offerId,
    this.supplierId,
    this.tagId,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      bannerId: json['banner_id'],
      bannerImage: json['banner_image'],
      bannerTitle: json['banner_title'],
      categoryId: json['category_id'],
      linkImageTo: json['link_image_to'],
      offerId: json['offer_id'],
      supplierId: json['supplier_id'],
      tagId: json['tag_id'],
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
  int? resultsCount; // results_count
  String? cartQuantity; // cart_quantity
  String? suppliersCount; // suppliers_count (Int in Android, making String safe or dynamic)
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
      suppliersCount: json['suppliers_count']?.toString(), // Handle Int/String
      suppliers: json['suppliers']?.toString(),
    );
  }
}

class ProfileResult {
  String? customerId; // Android: Not explicitly in ResultsItem but Login returns it. 
                      // Wait, Android ProfileResponse.ResultsItem DOES NOT have customer_id. 
                      // Removing strict requirement or keeping for safety if backend includes it. 
                      // Kept as per previous valid structure, but Android code didn't show it.

  String? firstName; // first_name
  String? lastName; // last_name
  String? email;
  String? mobile;
  String? image;
  String? unreadNotificationsCount; // unread_notifications_count
  String? wishlistPageHeading; // wishlist_page_heading
  String? status;
  String? showPortalIn; // show_portal_in
  String? accNum; // acc_num
  String? allowScanToOrder; // allow_scan_to_order
  String? priceDisplayTypeDecimals; // price_display_type_decimals
  String? priceDisplayType; // price_display_type
  String? supplierLogosPosition; // supplier_logos_position
  String? maximumNumberOfSuppliersProductsForFreeShipping; // maximum_number_of_suppliers_products_for_free_shipping
  String? showMarqueText; // show_marque_text
  String? marqueText; // marque_text
  String? marqueTextColor; // marque_text_color
  String? marqueTextSize; // marque_text_size (Float in Android)
  String? marqueTextBackgroundColor; // marque_text_background_color
  String? marqueTextFormat; // marque_text_format
  String? bestSellers; // best_sellers
  String? productsAdvertisements; // products_advertisements
  String? hotSelling; // hot_selling
  String? supplierLogos; // supplier_logos
  String? popularCategories; // popular_categories
  String? flashDeals; // flash_deals
  String? newArrivals; // new_arrivals
  String? recentlyAdded; // recently_added

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
  String? companyId; // company_id
  String? name;
  String? image;
  String? description;
  String? sortOrder; // sort_order
  String? status;

  HomeBlockItem({this.id, this.companyId, this.name, this.image, this.description, this.sortOrder, this.status});

  factory HomeBlockItem.fromJson(Map<String, dynamic> json) {
    return HomeBlockItem(
      id: json['id']?.toString(),
      companyId: json['company_id']?.toString(),
      name: json['name'],
      image: json['image'],
      description: json['description'],
      sortOrder: json['sort_order']?.toString(),
      status: json['status'],
    );
  }
}

// Corresponds to Android 'Products' class
class ProductItem {
    String? productId; // product_id
    String? title;
    String? description;
    String? image;
    String? brandName; // brand_name
    String? brandId; // brand_id
    String? price;
    String? promotionPrice; // promotion_price
    String? stockUnlimited; // stock_unlimited
    String? qtyStatus; // qty_status
    String? availableStockQty; // available_stock_qty
    String? minimumOrderQty; // minimum_order_qty
    String? soldAs; // sold_as
    String? isFavourite; // is_favourite
    int? productAvailable; // product_available
    int? supplierAvailable; // supplier_available
    String? notAvailableDaysMessage; // not_available_days_message
    String? addedToCart; // added_to_cart
    String? addedQty; // added_qty
    String? addedSubTotal; // added_sub_total
    String? orderedAs; // ordered_as
    String? apiData; // api_data

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
        this.apiData,
    });

    factory ProductItem.fromJson(Map<String, dynamic> json) {
        return ProductItem(
            productId: json['product_id']?.toString(),
            title: json['title'],
            description: json['description'],
            image: json['image'],
            brandName: json['brand_name'],
            brandId: json['brand_id']?.toString(),
            price: json['price'],
            promotionPrice: json['promotion_price'],
            stockUnlimited: json['stock_unlimited'],
            qtyStatus: json['qty_status'],
            availableStockQty: json['available_stock_qty']?.toString(),
            minimumOrderQty: json['minimum_order_qty']?.toString(),
            soldAs: json['sold_as'],
            isFavourite: json['is_favourite'],
            productAvailable: json['product_available'] is int ? json['product_available'] : int.tryParse(json['product_available']?.toString() ?? ""),
            supplierAvailable: json['supplier_available'] is int ? json['supplier_available'] : int.tryParse(json['supplier_available']?.toString() ?? ""),
            notAvailableDaysMessage: json['not_available_days_message'],
            addedToCart: json['added_to_cart']?.toString(),
            addedQty: json['added_qty']?.toString(),
            addedSubTotal: json['added_sub_total']?.toString(),
            orderedAs: json['ordered_as'],
            apiData: json['api_data'],
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
    String? divisionId; // division_id
    String? groupLevel1; // group_level_1
    String? image;
    String? popularCategory; // popular_category
    // category_products ignored for dashboard listing usually, unless needed.

    PopularCategoryItem({this.divisionId, this.groupLevel1, this.image, this.popularCategory});

    factory PopularCategoryItem.fromJson(Map<String, dynamic> json) {
        return PopularCategoryItem(
            divisionId: json['division_id']?.toString(),
            groupLevel1: json['group_level_1'],
            image: json['image'],
            popularCategory: json['popular_category'],
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

class SupplierLogosResponse {
     int? status;
    String? message;
    List<BannerItem?>? results; // Uses BannerItem structure usually for logos

     SupplierLogosResponse({this.status, this.message, this.results});
      factory SupplierLogosResponse.fromJson(Map<String, dynamic> json) {
         return SupplierLogosResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? BannerItem.fromJson(i) : null).toList()
                : null,
        );
    }
}

class PopularAdvertosementsResponse {
    int? status;
    String? message;
    List<BannerItem?>? results;

    PopularAdvertosementsResponse({this.status, this.message, this.results});
    factory PopularAdvertosementsResponse.fromJson(Map<String, dynamic> json) {
         return PopularAdvertosementsResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? BannerItem.fromJson(i) : null).toList()
                : null,
        );
    }
}
