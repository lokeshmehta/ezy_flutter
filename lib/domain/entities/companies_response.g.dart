// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companies_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompaniesResponseImpl _$$CompaniesResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CompaniesResponseImpl(
      resultsCount: (json['results_count'] as num?)?.toInt(),
      message: json['message'] as String?,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => CompanyResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: (json['status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CompaniesResponseImplToJson(
        _$CompaniesResponseImpl instance) =>
    <String, dynamic>{
      'results_count': instance.resultsCount,
      'message': instance.message,
      'results': instance.results,
      'status': instance.status,
    };

_$CompanyResultImpl _$$CompanyResultImplFromJson(Map<String, dynamic> json) =>
    _$CompanyResultImpl(
      companyId: (json['company_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      natureOfBusiness: json['nature_of_business'] as String?,
      uniqueUrl: json['unique_url'] as String?,
      image: json['image'] as String?,
      accessToken: json['access_token'] as String?,
      companyUrl: json['company_url'] as String?,
      emailRequiredForCustomerSignup:
          json['email_required_for_customer_signup'] as String?,
      availablePaymentMethods: json['available_payment_methods'] as String?,
      razorPayKey: json['razor_pay_key'] as String?,
      razorPaySecret: json['razor_pay_secret'] as String?,
      webUrl: json['web_url'] as String?,
      allowNewUserSignUp: json['allow_new_user_sign_up'] as String?,
      loginScreenUsernamePlaceholder:
          json['login_screen_username_placeholder'] as String?,
    );

Map<String, dynamic> _$$CompanyResultImplToJson(_$CompanyResultImpl instance) =>
    <String, dynamic>{
      'company_id': instance.companyId,
      'name': instance.name,
      'nature_of_business': instance.natureOfBusiness,
      'unique_url': instance.uniqueUrl,
      'image': instance.image,
      'access_token': instance.accessToken,
      'company_url': instance.companyUrl,
      'email_required_for_customer_signup':
          instance.emailRequiredForCustomerSignup,
      'available_payment_methods': instance.availablePaymentMethods,
      'razor_pay_key': instance.razorPayKey,
      'razor_pay_secret': instance.razorPaySecret,
      'web_url': instance.webUrl,
      'allow_new_user_sign_up': instance.allowNewUserSignUp,
      'login_screen_username_placeholder':
          instance.loginScreenUsernamePlaceholder,
    };
