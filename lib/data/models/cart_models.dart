class CartDetailsResponse {
  int? status;
  String? message;
  int? resultsCount;
  List<CartDetailsResult>? results;

  CartDetailsResponse({
    this.status,
    this.message,
    this.resultsCount,
    this.results,
  });

  factory CartDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CartDetailsResponse(
      status: json['status'],
      message: json['message'],
      resultsCount: json['results_count'],
      results: json['results'] != null
          ? (json['results'] as List).map((i) => CartDetailsResult.fromJson(i)).toList()
          : null,
    );
  }
}

class CartDetailsResult {
  String? cartId;
  String? customerId;
  String? subTotal;
  String? gst;
  String? total; // internal usage usually
  String? orderAmount; // often the final total
  String? discount;
  String? couponId;
  String? couponName;
  String? couponDiscount;
  String? deliveryLocationId;
  String? deliveryLocationCharge;
  String? deliveryCharge;
  String? deliveryChargeGst;
  String? gstPercentageDeliveryCharge;
  String? suppliersExceededShippingCharge;
  String? minOrderNotificationText;
  String? maxOrderNotificationText;
  String? maxOrderAmount;
  String? minimumOrderAmount;
  String? restrictOnMinOrderAmountNotReached;
  String? restrictOnMaxOrderAmountReached;
  String? showShippingSegment;
  
  List<CartBrand>? brands;

  CartDetailsResult({
    this.cartId,
    this.customerId,
    this.subTotal,
    this.gst,
    this.total,
    this.orderAmount,
    this.discount,
    this.couponId,
    this.couponName,
    this.couponDiscount,
    this.deliveryLocationId,
    this.deliveryLocationCharge,
    this.deliveryCharge,
    this.deliveryChargeGst,
    this.gstPercentageDeliveryCharge,
    this.suppliersExceededShippingCharge,
    this.minOrderNotificationText,
    this.maxOrderNotificationText,
    this.maxOrderAmount,
    this.minimumOrderAmount,
    this.restrictOnMinOrderAmountNotReached,
    this.restrictOnMaxOrderAmountReached,
    this.showShippingSegment,
    this.brands,
  });

  factory CartDetailsResult.fromJson(Map<String, dynamic> json) {
    return CartDetailsResult(
      cartId: json['cart_id']?.toString(),
      customerId: json['customer_id']?.toString(),
      subTotal: json['sub_total']?.toString(),
      gst: json['gst']?.toString(),
      total: json['total']?.toString(),
      orderAmount: json['order_amount']?.toString(),
      discount: json['discount']?.toString(),
      couponId: json['coupon_id']?.toString(),
      couponName: json['coupon_name']?.toString(),
      couponDiscount: json['coupon_discount']?.toString(),
      deliveryLocationId: json['delivery_location_id']?.toString(),
      deliveryLocationCharge: json['location_delivery_charge']?.toString() ?? json['delivery_location_charge']?.toString(), // Check exact key
      deliveryCharge: json['delivery_charge']?.toString(),
      deliveryChargeGst: json['delivery_charge_gst']?.toString(),
      gstPercentageDeliveryCharge: json['gst_percentage_delivery_charge']?.toString(),
      suppliersExceededShippingCharge: json['suppliers_exceeded_shipping_charge']?.toString(),
      minOrderNotificationText: json['min_order_notification_text']?.toString(),
      maxOrderNotificationText: json['max_order_notification_text']?.toString(),
      maxOrderAmount: json['max_order_amount']?.toString(),
      minimumOrderAmount: json['minimum_order_amount']?.toString(),
      restrictOnMinOrderAmountNotReached: json['restrict_on_min_order_amount_not_reached']?.toString(),
      restrictOnMaxOrderAmountReached: json['restrict_on_max_order_amount_reached']?.toString(),
      showShippingSegment: json['show_shipping_segment']?.toString(),
      brands: json['brands'] != null
          ? (json['brands'] as List).map((i) => CartBrand.fromJson(i)).toList()
          : null,
    );
  }
}

class CartBrand {
  String? brandId;
  String? brandName;
  List<CartItem>? products;

  CartBrand({this.brandId, this.brandName, this.products});

  factory CartBrand.fromJson(Map<String, dynamic> json) {
    return CartBrand(
      brandId: json['brand_id']?.toString(),
      brandName: json['brand_name']?.toString(),
      products: json['products'] != null
          ? (json['products'] as List).map((i) => CartItem.fromJson(i)).toList()
          : null,
    );
  }
}

class CartItem {
  String? productId;
  String? title; // Product Name
  String? image;
  String? qty;
  String? minimumOrderQty;
  String? normalPrice; // price
  String? salePrice; // promotion_price
  String? gstPercentage;
  String? gstPrice; // gst_amount
  String? supplierAvailable;
  String? productAvailable;
  String? notAvailableDaysMessage;
  String? discountAmount;
  String? soldAs;
  String? orderedAs;

  // Flattened brand info (filled during parsing)
  String? brandId;
  String? brandName;

  CartItem({
    this.productId,
    this.title,
    this.image,
    this.qty,
    this.minimumOrderQty,
    this.normalPrice,
    this.salePrice,
    this.gstPercentage,
    this.gstPrice,
    this.supplierAvailable,
    this.productAvailable,
    this.notAvailableDaysMessage,
    this.discountAmount,
    this.soldAs,
    this.orderedAs,
    this.brandId,
    this.brandName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id']?.toString(),
      title: json['title']?.toString(),
      image: json['image']?.toString(),
      qty: json['qty']?.toString(),
      minimumOrderQty: json['minimum_order_qty']?.toString(),
      normalPrice: json['normal_price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      gstPercentage: json['gst_percentage']?.toString(),
      gstPrice: json['gst_amount']?.toString(), // Mapped from gst_amount
      supplierAvailable: json['supplier_available']?.toString(),
      productAvailable: json['product_available']?.toString(),
      notAvailableDaysMessage: json['not_available_days_message']?.toString(),
      discountAmount: json['discount_amount']?.toString(),
      soldAs: json['sold_as']?.toString(),
      orderedAs: json['ordered_as']?.toString(),
    );
  }

  // CopyWith for updating qty/state locally
  CartItem copyWith({
    String? qty,
    String? orderedAs,
  }) {
    return CartItem(
      productId: productId,
      title: title,
      image: image,
      qty: qty ?? this.qty,
      minimumOrderQty: minimumOrderQty,
      normalPrice: normalPrice,
      salePrice: salePrice,
      gstPercentage: gstPercentage,
      gstPrice: gstPrice,
      supplierAvailable: supplierAvailable,
      productAvailable: productAvailable,
      notAvailableDaysMessage: notAvailableDaysMessage,
      discountAmount: discountAmount,
      soldAs: soldAs,
      orderedAs: orderedAs ?? this.orderedAs,
      brandId: brandId,
      brandName: brandName,
    );
  }
}
