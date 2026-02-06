class ProfileResponse {
  int? status;
  String? message;
  int? resultsCount;
  List<ProfileResult>? results;

  ProfileResponse({this.status, this.message, this.resultsCount, this.results});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'],
      message: json['message'],
      resultsCount: json['results_count'],
      results: json['results'] != null
          ? (json['results'] as List).map((i) => ProfileResult.fromJson(i)).toList()
          : null,
    );
  }
}

class ProfileResult {
  String? customerId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? subTotalHeading;
  String? totalHeading;
  String? allowToReviewOrderBeforeSubmitting;
  List<AddressItem>? addressesList;

  // Add other profile fields as needed, but these are critical for Checkout

  ProfileResult({
    this.customerId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.subTotalHeading,
    this.totalHeading,
    this.allowToReviewOrderBeforeSubmitting,
    this.addressesList,
  });

  factory ProfileResult.fromJson(Map<String, dynamic> json) {
    return ProfileResult(
      customerId: json['customer_id']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      subTotalHeading: json['sub_total_heading']?.toString(),
      totalHeading: json['total_heading']?.toString(),
      allowToReviewOrderBeforeSubmitting: json['allow_to_review_order_before_submmitting']?.toString(),
      addressesList: json['addresses_list'] != null
          ? (json['addresses_list'] as List).map((i) => AddressItem.fromJson(i)).toList()
          : null,
    );
  }
}

class AddressItem {
  String? addressId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? street;
  String? street2;
  String? suburb;
  String? state;
  String? postcode;
  String? country;
  String? defaultAddress;
  String? deliveryLocationId;
  String? deliveryLocationCharge;
  String? isChecked; // Local UI state

  AddressItem({
    this.addressId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.street,
    this.street2,
    this.suburb,
    this.state,
    this.postcode,
    this.country,
    this.defaultAddress,
    this.deliveryLocationId,
    this.deliveryLocationCharge,
    this.isChecked = "No",
  });

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      addressId: json['address_id']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      street: json['street']?.toString(),
      street2: json['street2']?.toString(),
      suburb: json['suburb']?.toString(),
      state: json['state']?.toString(),
      postcode: json['postcode']?.toString(),
      country: json['country']?.toString(),
      defaultAddress: json['default_address']?.toString(),
      deliveryLocationId: json['delivery_location_id']?.toString(),
      deliveryLocationCharge: json['delivery_location_charge']?.toString() ?? json['location_delivery_charge']?.toString(),
      isChecked: "No",
    );
  }
}
