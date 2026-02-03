class MenuitemsResponse {
  String? category;
  String? image;
  String? name;
  String? displayName; // display_name
  String? fromDate; // from_date
  String? toDate; // to_date
  String? products;
  String? id;
  String? price;
  String? promotionPrice; // promotion_price
  String? hasPromotion; // has_promotion
  String? availableStockQty; // available_stock_qty
  String? stockUnlimited; // stock_unlimited
  String? minimumOrderQty; // minimum_order_qty
  String? isFavourite; // is_favourite
  String? brandId; // brand_id
  int? scrolledPosition;
  int? productAvailable; // product_available
  int? supplierAvailable; // supplier_available
  String? notAvailableDaysMessage; // not_available_days_message
  String? addedToCart; // added_to_cart
  String? addedQty; // added_qty
  String? addedSubTotal; // added_sub_total
  String? soldAs; // sold_as
  String? qtyPerOuter; // qty_per_outer
  String? orderedAs; // ordered_as
  String? apiData; // api_data
  String? qtyStatus; // qty_status

  MenuitemsResponse({
    this.category,
    this.image,
    this.name,
    this.displayName,
    this.fromDate,
    this.toDate,
    this.products,
    this.id,
    this.price,
    this.promotionPrice,
    this.hasPromotion,
    this.availableStockQty = "0",
    this.stockUnlimited = "",
    this.minimumOrderQty = "0",
    this.isFavourite,
    this.brandId,
    this.scrolledPosition,
    this.productAvailable,
    this.supplierAvailable,
    this.notAvailableDaysMessage,
    this.addedToCart,
    this.addedQty,
    this.addedSubTotal,
    this.soldAs,
    this.qtyPerOuter = "0",
    this.orderedAs = "",
    this.apiData = "",
    this.qtyStatus = "",
  });

  factory MenuitemsResponse.fromJson(Map<String, dynamic> json) {
    return MenuitemsResponse(
      category: json['category'],
      image: json['image'],
      name: json['name'],
      displayName: json['display_name'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
      products: json['products'],
      id: json['id'],
      price: json['price'],
      promotionPrice: json['promotion_price'],
      hasPromotion: json['has_promotion'],
      availableStockQty: json['available_stock_qty'] ?? "0",
      stockUnlimited: json['stock_unlimited'] ?? "",
      minimumOrderQty: json['minimum_order_qty'] ?? "0",
      isFavourite: json['is_favourite'],
      brandId: json['brand_id'],
      scrolledPosition: json['scrolledPosition'],
      productAvailable: json['product_available'],
      supplierAvailable: json['supplier_available'],
      notAvailableDaysMessage: json['not_available_days_message'],
      addedToCart: json['added_to_cart'],
      addedQty: json['added_qty'],
      addedSubTotal: json['added_sub_total'],
      soldAs: json['sold_as'],
      qtyPerOuter: json['qty_per_outer'] ?? "0",
      orderedAs: json['ordered_as'] ?? "",
      apiData: json['api_data'] ?? "",
      qtyStatus: json['qty_status'] ?? "",
    );
  }
}

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
  String? suppliersCount; // suppliers_count
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
      cartQuantity: json['cart_quantity'],
      suppliersCount: json['suppliers_count'],
      suppliers: json['suppliers'],
    );
  }
}

class ProfileResult {
  String? customerId; // customer_id
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
  String? marqueTextSize; // marque_text_size
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
      customerId: json['customer_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      mobile: json['mobile'],
      image: json['image'],
      unreadNotificationsCount: json['unread_notifications_count'],
      wishlistPageHeading: json['wishlist_page_heading'],
      status: json['status'],
      showPortalIn: json['show_portal_in'],
      accNum: json['acc_num'],
      allowScanToOrder: json['allow_scan_to_order'],
      priceDisplayTypeDecimals: json['price_display_type_decimals'],
      priceDisplayType: json['price_display_type'],
      supplierLogosPosition: json['supplier_logos_position'],
      maximumNumberOfSuppliersProductsForFreeShipping: json['maximum_number_of_suppliers_products_for_free_shipping'],
      showMarqueText: json['show_marque_text'],
      marqueText: json['marque_text'],
      marqueTextColor: json['marque_text_color'],
      marqueTextSize: json['marque_text_size'],
      marqueTextBackgroundColor: json['marque_text_background_color'],
      marqueTextFormat: json['marque_text_format'],
      bestSellers: json['best_sellers'],
      productsAdvertisements: json['products_advertisements'],
      hotSelling: json['hot_selling'],
      supplierLogos: json['supplier_logos'],
      popularCategories: json['popular_categories'],
      flashDeals: json['flash_deals'],
      newArrivals: json['new_arrivals'],
      recentlyAdded: json['recently_added'],
    );
  }
}

class HomeBlocksResponse {
    int? status;
    String? message;
    List<MenuitemsResponse?>? results; // Assuming HomeBlocks uses similar structure or simplified
    // In Android: homePageCategoriesApiCall -> HomeBlocksResponse -> homeItemsLay. Probably Categories.

    HomeBlocksResponse({this.status, this.message, this.results});
    factory HomeBlocksResponse.fromJson(Map<String, dynamic> json) {
         return HomeBlocksResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? MenuitemsResponse.fromJson(i) : null).toList()
                : null,
        );
    }
}

class DashboardProductsResponse {
    int? status;
    String? message;
     List<MenuitemsResponse?>? results;

    DashboardProductsResponse({this.status, this.message, this.results});
    factory DashboardProductsResponse.fromJson(Map<String, dynamic> json) {
        return DashboardProductsResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? MenuitemsResponse.fromJson(i) : null).toList()
                : null,
        );
    }
}

class PromotionsResponse {
    int? status;
    String? message;
     List<MenuitemsResponse?>? results;

    PromotionsResponse({this.status, this.message, this.results});
    factory PromotionsResponse.fromJson(Map<String, dynamic> json) {
         return PromotionsResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? MenuitemsResponse.fromJson(i) : null).toList()
                : null,
        );
    }
}

class FlashDealsResponse {
     int? status;
    String? message;
     List<MenuitemsResponse?>? results;

    FlashDealsResponse({this.status, this.message, this.results});
    factory FlashDealsResponse.fromJson(Map<String, dynamic> json) {
         return FlashDealsResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? MenuitemsResponse.fromJson(i) : null).toList()
                : null,
        );
    }
}

class PopularCategoriesResponse {
    int? status;
    String? message;
    List<MenuitemsResponse?>? results;

    PopularCategoriesResponse({this.status, this.message, this.results});
    factory PopularCategoriesResponse.fromJson(Map<String, dynamic> json) {
         return PopularCategoriesResponse(
            status: json['status'],
            message: json['message'],
            results: json['results'] != null
                ? (json['results'] as List).map((i) => i != null ? MenuitemsResponse.fromJson(i) : null).toList()
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
