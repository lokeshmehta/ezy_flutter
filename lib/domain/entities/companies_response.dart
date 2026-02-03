import 'package:freezed_annotation/freezed_annotation.dart';

part 'companies_response.freezed.dart';
part 'companies_response.g.dart';

@freezed
class CompaniesResponse with _$CompaniesResponse {
  const factory CompaniesResponse({
    @JsonKey(name: 'results_count') int? resultsCount,
    String? message,
    List<CompanyResult>? results,
    int? status,
  }) = _CompaniesResponse;

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) =>
      _$CompaniesResponseFromJson(json);
}

@freezed
class CompanyResult with _$CompanyResult {
  const factory CompanyResult({
    @JsonKey(name: 'company_id') int? companyId,
    String? name,
    @JsonKey(name: 'nature_of_business') String? natureOfBusiness,
    @JsonKey(name: 'unique_url') String? uniqueUrl,
    String? image,
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'company_url') String? companyUrl,
    @JsonKey(name: 'email_required_for_customer_signup') String? emailRequiredForCustomerSignup,
    @JsonKey(name: 'available_payment_methods') String? availablePaymentMethods,
    @JsonKey(name: 'razor_pay_key') String? razorPayKey,
    @JsonKey(name: 'razor_pay_secret') String? razorPaySecret,
    @JsonKey(name: 'web_url') String? webUrl,
    @JsonKey(name: 'allow_new_user_sign_up') String? allowNewUserSignUp,
    @JsonKey(name: 'login_screen_username_placeholder') String? loginScreenUsernamePlaceholder,
  }) = _CompanyResult;

  factory CompanyResult.fromJson(Map<String, dynamic> json) =>
      _$CompanyResultFromJson(json);
}
