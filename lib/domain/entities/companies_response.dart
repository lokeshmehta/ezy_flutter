class CompaniesResponse {
  final int? resultsCount;
  final String? message;
  final List<CompanyResult>? results;
  final int? status;

  CompaniesResponse({
    this.resultsCount,
    this.message,
    this.results,
    this.status,
  });

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    return CompaniesResponse(
      resultsCount: json['results_count'] is int ? json['results_count'] : int.tryParse(json['results_count']?.toString() ?? '0'),
      message: json['message']?.toString(),
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => CompanyResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '0'),
    );
  }
}

class CompanyResult {
  final int? companyId;
  final String? name;
  final String? natureOfBusiness;
  final String? uniqueUrl;
  final String? image;
  final String? accessToken;
  final String? companyUrl;
  final String? emailRequiredForCustomerSignup;
  final String? availablePaymentMethods;
  final String? razorPayKey;
  final String? razorPaySecret;
  final String? webUrl;
  final String? allowNewUserSignUp;
  final String? loginScreenUsernamePlaceholder;

  CompanyResult({
    this.companyId,
    this.name,
    this.natureOfBusiness,
    this.uniqueUrl,
    this.image,
    this.accessToken,
    this.companyUrl,
    this.emailRequiredForCustomerSignup,
    this.availablePaymentMethods,
    this.razorPayKey,
    this.razorPaySecret,
    this.webUrl,
    this.allowNewUserSignUp,
    this.loginScreenUsernamePlaceholder,
  });

  factory CompanyResult.fromJson(Map<String, dynamic> json) {
    return CompanyResult(
      companyId: json['company_id'] is int ? json['company_id'] : int.tryParse(json['company_id']?.toString() ?? '0'),
      name: json['name']?.toString(),
      natureOfBusiness: json['nature_of_business']?.toString(),
      uniqueUrl: json['unique_url']?.toString(),
      image: json['image']?.toString(),
      accessToken: json['access_token']?.toString(),
      companyUrl: json['company_url']?.toString(),
      emailRequiredForCustomerSignup: json['email_required_for_customer_signup']?.toString(),
      availablePaymentMethods: json['available_payment_methods']?.toString(),
      razorPayKey: json['razor_pay_key']?.toString(),
      razorPaySecret: json['razor_pay_secret']?.toString(),
      webUrl: json['web_url']?.toString(),
      allowNewUserSignUp: json['allow_new_user_sign_up']?.toString(),
      loginScreenUsernamePlaceholder: json['login_screen_username_placeholder']?.toString(),
    );
  }
}
