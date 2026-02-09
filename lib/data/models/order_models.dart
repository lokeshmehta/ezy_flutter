

class OrderHistoryResponse {
  final int? status;
  final String? message;
  final int? resultsCount;
  final List<OrderHistoryResult>? results;

  OrderHistoryResponse({
    this.status,
    this.message,
    this.resultsCount,
    this.results,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResponse(
      status: json['status'],
      message: json['message'],
      resultsCount: json['results_count'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => OrderHistoryResult.fromJson(i))
              .toList()
          : null,
    );
  }
}

class OrderHistoryResult {
  final int? orderId;
  final String? refNo;
  final int? quantity;
  final String? subTotal;
  final int? extraSuppliers;
  final String? suppliersExceededShippingCharge;
  final int? deliveryLocationId;
  final String? deliveryLocationCharge;
  final String? deliveryCharge;
  final String? deliveryChargeGst;
  final String? gstPercentageDeliveryCharge;
  final String? gst;
  final String? discount;
  final String? couponDiscount;
  final String? couponName;
  final String? orderAmount;
  final String? orderStatus;
  final String? orderDate;
  final String? email;
  final String? phone;
  final String? customerFirstName;
  final String? customerLastName;
  final String? company;
  final String? shippingPhone;
  final String? shippingEmail;
  final String? deliveryAddress;
  final String? billingAddress;
  final String? remarks;
  final String? paymentType;
  final String? pdfFile;

  OrderHistoryResult({
    this.orderId,
    this.refNo,
    this.quantity,
    this.subTotal,
    this.extraSuppliers,
    this.suppliersExceededShippingCharge,
    this.deliveryLocationId,
    this.deliveryLocationCharge,
    this.deliveryCharge,
    this.deliveryChargeGst,
    this.gstPercentageDeliveryCharge,
    this.gst,
    this.discount,
    this.couponDiscount,
    this.couponName,
    this.orderAmount,
    this.orderStatus,
    this.orderDate,
    this.email,
    this.phone,
    this.customerFirstName,
    this.customerLastName,
    this.company,
    this.shippingPhone,
    this.shippingEmail,
    this.deliveryAddress,
    this.billingAddress,
    this.remarks,
    this.paymentType,
    this.pdfFile,
  });

  factory OrderHistoryResult.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResult(
      orderId: json['order_id'],
      refNo: json['RefNo'],
      quantity: json['quantity'],
      subTotal: json['sub_total'],
      extraSuppliers: json['extra_suppliers'],
      suppliersExceededShippingCharge: json['suppliers_exceeded_shipping_charge'],
      deliveryLocationId: json['delivery_location_id'],
      deliveryLocationCharge: json['delivery_location_charge'],
      deliveryCharge: json['delivery_charge'],
      deliveryChargeGst: json['delivery_charge_gst'],
      gstPercentageDeliveryCharge: json['gst_percentage_delivery_charge'],
      gst: json['gst'],
      discount: json['discount'],
      couponDiscount: json['coupon_discount'],
      couponName: json['coupon_name'],
      orderAmount: json['order_amount'],
      orderStatus: json['order_status'],
      orderDate: json['order_date'],
      email: json['email'],
      phone: json['phone'],
      customerFirstName: json['customer_first_name'],
      customerLastName: json['customer_last_name'],
      company: json['company'],
      shippingPhone: json['shipping_phone'],
      shippingEmail: json['shipping_email'],
      deliveryAddress: json['delivery_address'],
      billingAddress: json['billing_address'],
      remarks: json['remarks'],
      paymentType: json['payment_type'],
      pdfFile: json['pdf_file'],
    );
  }
}

class OrderDetailsResponse {
  final int? status;
  final String? message;
  final int? resultsCount;
  final List<OrderDetailResult>? results;

  OrderDetailsResponse({
    this.status,
    this.message,
    this.resultsCount,
    this.results,
  });

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      status: json['status'],
      message: json['message'],
      resultsCount: json['results_count'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => OrderDetailResult.fromJson(i))
              .toList()
          : null,
    );
  }
}

class OrderDetailResult {
  final int? brandId;
  final String? brandName;
  final int? brandNumber;
  final String? supplierStatus;
  final String? readyToPickup;
  final String? readyToPickupDateTime;
  final String? productsCollected;
  final String? productsCollectedDateTime;
  final String? expectedDeliveryDateTime;
  final String? productsDelivered;
  final String? productsDeliveredDateTime;
  final String? driverName;
  final String? driverPhone;
  final List<OrderProduct>? products;

  OrderDetailResult({
    this.brandId,
    this.brandName,
    this.brandNumber,
    this.supplierStatus,
    this.readyToPickup,
    this.readyToPickupDateTime,
    this.productsCollected,
    this.productsCollectedDateTime,
    this.expectedDeliveryDateTime,
    this.productsDelivered,
    this.productsDeliveredDateTime,
    this.driverName,
    this.driverPhone,
    this.products,
  });

  factory OrderDetailResult.fromJson(Map<String, dynamic> json) {
    return OrderDetailResult(
      brandId: json['brand_id'],
      brandName: json['brand_name'],
      brandNumber: json['brand_number'],
      supplierStatus: json['supplier_status'],
      readyToPickup: json['ready_to_pickup'],
      readyToPickupDateTime: json['ready_to_pickup_date_time'],
      productsCollected: json['products_collected'],
      productsCollectedDateTime: json['products_collected_date_time'],
      expectedDeliveryDateTime: json['expected_delivery_date_time'],
      productsDelivered: json['products_delivered'],
      productsDeliveredDateTime: json['products_delivered_date_time'],
      driverName: json['driver_name'],
      driverPhone: json['driver_phone'],
      products: json['products'] != null
          ? (json['products'] as List)
              .map((i) => OrderProduct.fromJson(i))
              .toList()
          : null,
    );
  }
}

class OrderProduct {
  final int? productId;
  final String? productName;
  final String? productImage;
  final String? itemCode;
  final String? sortKey;
  final String? sku;
  final String? soldAs;
  final String? orderedAs;
  final String? qtyPerOuter;
  final String? gst;
  final int? quantity;
  final double? gstPercentage;
  final String? normalPrice;
  final String? discount;
  final String? salePrice;
  final String? subTotal;
  final String? totalAmount;
  final int? discountId;
  final String? discountName;
  final String? productAvailable;
  final int? availableQty;

  OrderProduct({
    this.productId,
    this.productName,
    this.productImage,
    this.itemCode,
    this.sortKey,
    this.sku,
    this.soldAs,
    this.orderedAs,
    this.qtyPerOuter,
    this.gst,
    this.quantity,
    this.gstPercentage,
    this.normalPrice,
    this.discount,
    this.salePrice,
    this.subTotal,
    this.totalAmount,
    this.discountId,
    this.discountName,
    this.productAvailable,
    this.availableQty,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productId: json['product_id'],
      productName: json['product_name'],
      productImage: json['product_image'],
      itemCode: json['item_code'],
      sortKey: json['sort_key'],
      sku: json['sku'],
      soldAs: json['sold_as'],
      orderedAs: json['ordered_as'],
      qtyPerOuter: json['qty_per_outer'],
      gst: json['gst'],
      quantity: json['quantity'],
      gstPercentage: json['gst_percentage'] != null ? double.tryParse(json['gst_percentage'].toString()) : null,
      normalPrice: json['normal_price'],
      discount: json['discount'],
      salePrice: json['sale_price'],
      subTotal: json['sub_total'],
      totalAmount: json['total_amount'],
      discountId: json['discount_id'],
      discountName: json['discount_name'],
      productAvailable: json['product_available'],
      availableQty: json['available_qty'],
    );
  }
}
