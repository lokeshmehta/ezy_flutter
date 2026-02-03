// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'companies_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompaniesResponse _$CompaniesResponseFromJson(Map<String, dynamic> json) {
  return _CompaniesResponse.fromJson(json);
}

/// @nodoc
mixin _$CompaniesResponse {
  @JsonKey(name: 'results_count')
  int? get resultsCount => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  List<CompanyResult>? get results => throw _privateConstructorUsedError;
  int? get status => throw _privateConstructorUsedError;

  /// Serializes this CompaniesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompaniesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompaniesResponseCopyWith<CompaniesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompaniesResponseCopyWith<$Res> {
  factory $CompaniesResponseCopyWith(
          CompaniesResponse value, $Res Function(CompaniesResponse) then) =
      _$CompaniesResponseCopyWithImpl<$Res, CompaniesResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'results_count') int? resultsCount,
      String? message,
      List<CompanyResult>? results,
      int? status});
}

/// @nodoc
class _$CompaniesResponseCopyWithImpl<$Res, $Val extends CompaniesResponse>
    implements $CompaniesResponseCopyWith<$Res> {
  _$CompaniesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompaniesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resultsCount = freezed,
    Object? message = freezed,
    Object? results = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      resultsCount: freezed == resultsCount
          ? _value.resultsCount
          : resultsCount // ignore: cast_nullable_to_non_nullable
              as int?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      results: freezed == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<CompanyResult>?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompaniesResponseImplCopyWith<$Res>
    implements $CompaniesResponseCopyWith<$Res> {
  factory _$$CompaniesResponseImplCopyWith(_$CompaniesResponseImpl value,
          $Res Function(_$CompaniesResponseImpl) then) =
      __$$CompaniesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'results_count') int? resultsCount,
      String? message,
      List<CompanyResult>? results,
      int? status});
}

/// @nodoc
class __$$CompaniesResponseImplCopyWithImpl<$Res>
    extends _$CompaniesResponseCopyWithImpl<$Res, _$CompaniesResponseImpl>
    implements _$$CompaniesResponseImplCopyWith<$Res> {
  __$$CompaniesResponseImplCopyWithImpl(_$CompaniesResponseImpl _value,
      $Res Function(_$CompaniesResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompaniesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resultsCount = freezed,
    Object? message = freezed,
    Object? results = freezed,
    Object? status = freezed,
  }) {
    return _then(_$CompaniesResponseImpl(
      resultsCount: freezed == resultsCount
          ? _value.resultsCount
          : resultsCount // ignore: cast_nullable_to_non_nullable
              as int?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      results: freezed == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<CompanyResult>?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompaniesResponseImpl implements _CompaniesResponse {
  const _$CompaniesResponseImpl(
      {@JsonKey(name: 'results_count') this.resultsCount,
      this.message,
      final List<CompanyResult>? results,
      this.status})
      : _results = results;

  factory _$CompaniesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompaniesResponseImplFromJson(json);

  @override
  @JsonKey(name: 'results_count')
  final int? resultsCount;
  @override
  final String? message;
  final List<CompanyResult>? _results;
  @override
  List<CompanyResult>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? status;

  @override
  String toString() {
    return 'CompaniesResponse(resultsCount: $resultsCount, message: $message, results: $results, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompaniesResponseImpl &&
            (identical(other.resultsCount, resultsCount) ||
                other.resultsCount == resultsCount) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, resultsCount, message,
      const DeepCollectionEquality().hash(_results), status);

  /// Create a copy of CompaniesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompaniesResponseImplCopyWith<_$CompaniesResponseImpl> get copyWith =>
      __$$CompaniesResponseImplCopyWithImpl<_$CompaniesResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompaniesResponseImplToJson(
      this,
    );
  }
}

abstract class _CompaniesResponse implements CompaniesResponse {
  const factory _CompaniesResponse(
      {@JsonKey(name: 'results_count') final int? resultsCount,
      final String? message,
      final List<CompanyResult>? results,
      final int? status}) = _$CompaniesResponseImpl;

  factory _CompaniesResponse.fromJson(Map<String, dynamic> json) =
      _$CompaniesResponseImpl.fromJson;

  @override
  @JsonKey(name: 'results_count')
  int? get resultsCount;
  @override
  String? get message;
  @override
  List<CompanyResult>? get results;
  @override
  int? get status;

  /// Create a copy of CompaniesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompaniesResponseImplCopyWith<_$CompaniesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompanyResult _$CompanyResultFromJson(Map<String, dynamic> json) {
  return _CompanyResult.fromJson(json);
}

/// @nodoc
mixin _$CompanyResult {
  @JsonKey(name: 'company_id')
  int? get companyId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'nature_of_business')
  String? get natureOfBusiness => throw _privateConstructorUsedError;
  @JsonKey(name: 'unique_url')
  String? get uniqueUrl => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_token')
  String? get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_url')
  String? get companyUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_required_for_customer_signup')
  String? get emailRequiredForCustomerSignup =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'available_payment_methods')
  String? get availablePaymentMethods => throw _privateConstructorUsedError;
  @JsonKey(name: 'razor_pay_key')
  String? get razorPayKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'razor_pay_secret')
  String? get razorPaySecret => throw _privateConstructorUsedError;
  @JsonKey(name: 'web_url')
  String? get webUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_new_user_sign_up')
  String? get allowNewUserSignUp => throw _privateConstructorUsedError;
  @JsonKey(name: 'login_screen_username_placeholder')
  String? get loginScreenUsernamePlaceholder =>
      throw _privateConstructorUsedError;

  /// Serializes this CompanyResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompanyResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanyResultCopyWith<CompanyResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyResultCopyWith<$Res> {
  factory $CompanyResultCopyWith(
          CompanyResult value, $Res Function(CompanyResult) then) =
      _$CompanyResultCopyWithImpl<$Res, CompanyResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'company_id') int? companyId,
      String? name,
      @JsonKey(name: 'nature_of_business') String? natureOfBusiness,
      @JsonKey(name: 'unique_url') String? uniqueUrl,
      String? image,
      @JsonKey(name: 'access_token') String? accessToken,
      @JsonKey(name: 'company_url') String? companyUrl,
      @JsonKey(name: 'email_required_for_customer_signup')
      String? emailRequiredForCustomerSignup,
      @JsonKey(name: 'available_payment_methods')
      String? availablePaymentMethods,
      @JsonKey(name: 'razor_pay_key') String? razorPayKey,
      @JsonKey(name: 'razor_pay_secret') String? razorPaySecret,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'allow_new_user_sign_up') String? allowNewUserSignUp,
      @JsonKey(name: 'login_screen_username_placeholder')
      String? loginScreenUsernamePlaceholder});
}

/// @nodoc
class _$CompanyResultCopyWithImpl<$Res, $Val extends CompanyResult>
    implements $CompanyResultCopyWith<$Res> {
  _$CompanyResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanyResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyId = freezed,
    Object? name = freezed,
    Object? natureOfBusiness = freezed,
    Object? uniqueUrl = freezed,
    Object? image = freezed,
    Object? accessToken = freezed,
    Object? companyUrl = freezed,
    Object? emailRequiredForCustomerSignup = freezed,
    Object? availablePaymentMethods = freezed,
    Object? razorPayKey = freezed,
    Object? razorPaySecret = freezed,
    Object? webUrl = freezed,
    Object? allowNewUserSignUp = freezed,
    Object? loginScreenUsernamePlaceholder = freezed,
  }) {
    return _then(_value.copyWith(
      companyId: freezed == companyId
          ? _value.companyId
          : companyId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      natureOfBusiness: freezed == natureOfBusiness
          ? _value.natureOfBusiness
          : natureOfBusiness // ignore: cast_nullable_to_non_nullable
              as String?,
      uniqueUrl: freezed == uniqueUrl
          ? _value.uniqueUrl
          : uniqueUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      companyUrl: freezed == companyUrl
          ? _value.companyUrl
          : companyUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      emailRequiredForCustomerSignup: freezed == emailRequiredForCustomerSignup
          ? _value.emailRequiredForCustomerSignup
          : emailRequiredForCustomerSignup // ignore: cast_nullable_to_non_nullable
              as String?,
      availablePaymentMethods: freezed == availablePaymentMethods
          ? _value.availablePaymentMethods
          : availablePaymentMethods // ignore: cast_nullable_to_non_nullable
              as String?,
      razorPayKey: freezed == razorPayKey
          ? _value.razorPayKey
          : razorPayKey // ignore: cast_nullable_to_non_nullable
              as String?,
      razorPaySecret: freezed == razorPaySecret
          ? _value.razorPaySecret
          : razorPaySecret // ignore: cast_nullable_to_non_nullable
              as String?,
      webUrl: freezed == webUrl
          ? _value.webUrl
          : webUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      allowNewUserSignUp: freezed == allowNewUserSignUp
          ? _value.allowNewUserSignUp
          : allowNewUserSignUp // ignore: cast_nullable_to_non_nullable
              as String?,
      loginScreenUsernamePlaceholder: freezed == loginScreenUsernamePlaceholder
          ? _value.loginScreenUsernamePlaceholder
          : loginScreenUsernamePlaceholder // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompanyResultImplCopyWith<$Res>
    implements $CompanyResultCopyWith<$Res> {
  factory _$$CompanyResultImplCopyWith(
          _$CompanyResultImpl value, $Res Function(_$CompanyResultImpl) then) =
      __$$CompanyResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'company_id') int? companyId,
      String? name,
      @JsonKey(name: 'nature_of_business') String? natureOfBusiness,
      @JsonKey(name: 'unique_url') String? uniqueUrl,
      String? image,
      @JsonKey(name: 'access_token') String? accessToken,
      @JsonKey(name: 'company_url') String? companyUrl,
      @JsonKey(name: 'email_required_for_customer_signup')
      String? emailRequiredForCustomerSignup,
      @JsonKey(name: 'available_payment_methods')
      String? availablePaymentMethods,
      @JsonKey(name: 'razor_pay_key') String? razorPayKey,
      @JsonKey(name: 'razor_pay_secret') String? razorPaySecret,
      @JsonKey(name: 'web_url') String? webUrl,
      @JsonKey(name: 'allow_new_user_sign_up') String? allowNewUserSignUp,
      @JsonKey(name: 'login_screen_username_placeholder')
      String? loginScreenUsernamePlaceholder});
}

/// @nodoc
class __$$CompanyResultImplCopyWithImpl<$Res>
    extends _$CompanyResultCopyWithImpl<$Res, _$CompanyResultImpl>
    implements _$$CompanyResultImplCopyWith<$Res> {
  __$$CompanyResultImplCopyWithImpl(
      _$CompanyResultImpl _value, $Res Function(_$CompanyResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompanyResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyId = freezed,
    Object? name = freezed,
    Object? natureOfBusiness = freezed,
    Object? uniqueUrl = freezed,
    Object? image = freezed,
    Object? accessToken = freezed,
    Object? companyUrl = freezed,
    Object? emailRequiredForCustomerSignup = freezed,
    Object? availablePaymentMethods = freezed,
    Object? razorPayKey = freezed,
    Object? razorPaySecret = freezed,
    Object? webUrl = freezed,
    Object? allowNewUserSignUp = freezed,
    Object? loginScreenUsernamePlaceholder = freezed,
  }) {
    return _then(_$CompanyResultImpl(
      companyId: freezed == companyId
          ? _value.companyId
          : companyId // ignore: cast_nullable_to_non_nullable
              as int?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      natureOfBusiness: freezed == natureOfBusiness
          ? _value.natureOfBusiness
          : natureOfBusiness // ignore: cast_nullable_to_non_nullable
              as String?,
      uniqueUrl: freezed == uniqueUrl
          ? _value.uniqueUrl
          : uniqueUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      companyUrl: freezed == companyUrl
          ? _value.companyUrl
          : companyUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      emailRequiredForCustomerSignup: freezed == emailRequiredForCustomerSignup
          ? _value.emailRequiredForCustomerSignup
          : emailRequiredForCustomerSignup // ignore: cast_nullable_to_non_nullable
              as String?,
      availablePaymentMethods: freezed == availablePaymentMethods
          ? _value.availablePaymentMethods
          : availablePaymentMethods // ignore: cast_nullable_to_non_nullable
              as String?,
      razorPayKey: freezed == razorPayKey
          ? _value.razorPayKey
          : razorPayKey // ignore: cast_nullable_to_non_nullable
              as String?,
      razorPaySecret: freezed == razorPaySecret
          ? _value.razorPaySecret
          : razorPaySecret // ignore: cast_nullable_to_non_nullable
              as String?,
      webUrl: freezed == webUrl
          ? _value.webUrl
          : webUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      allowNewUserSignUp: freezed == allowNewUserSignUp
          ? _value.allowNewUserSignUp
          : allowNewUserSignUp // ignore: cast_nullable_to_non_nullable
              as String?,
      loginScreenUsernamePlaceholder: freezed == loginScreenUsernamePlaceholder
          ? _value.loginScreenUsernamePlaceholder
          : loginScreenUsernamePlaceholder // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyResultImpl implements _CompanyResult {
  const _$CompanyResultImpl(
      {@JsonKey(name: 'company_id') this.companyId,
      this.name,
      @JsonKey(name: 'nature_of_business') this.natureOfBusiness,
      @JsonKey(name: 'unique_url') this.uniqueUrl,
      this.image,
      @JsonKey(name: 'access_token') this.accessToken,
      @JsonKey(name: 'company_url') this.companyUrl,
      @JsonKey(name: 'email_required_for_customer_signup')
      this.emailRequiredForCustomerSignup,
      @JsonKey(name: 'available_payment_methods') this.availablePaymentMethods,
      @JsonKey(name: 'razor_pay_key') this.razorPayKey,
      @JsonKey(name: 'razor_pay_secret') this.razorPaySecret,
      @JsonKey(name: 'web_url') this.webUrl,
      @JsonKey(name: 'allow_new_user_sign_up') this.allowNewUserSignUp,
      @JsonKey(name: 'login_screen_username_placeholder')
      this.loginScreenUsernamePlaceholder});

  factory _$CompanyResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyResultImplFromJson(json);

  @override
  @JsonKey(name: 'company_id')
  final int? companyId;
  @override
  final String? name;
  @override
  @JsonKey(name: 'nature_of_business')
  final String? natureOfBusiness;
  @override
  @JsonKey(name: 'unique_url')
  final String? uniqueUrl;
  @override
  final String? image;
  @override
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @override
  @JsonKey(name: 'company_url')
  final String? companyUrl;
  @override
  @JsonKey(name: 'email_required_for_customer_signup')
  final String? emailRequiredForCustomerSignup;
  @override
  @JsonKey(name: 'available_payment_methods')
  final String? availablePaymentMethods;
  @override
  @JsonKey(name: 'razor_pay_key')
  final String? razorPayKey;
  @override
  @JsonKey(name: 'razor_pay_secret')
  final String? razorPaySecret;
  @override
  @JsonKey(name: 'web_url')
  final String? webUrl;
  @override
  @JsonKey(name: 'allow_new_user_sign_up')
  final String? allowNewUserSignUp;
  @override
  @JsonKey(name: 'login_screen_username_placeholder')
  final String? loginScreenUsernamePlaceholder;

  @override
  String toString() {
    return 'CompanyResult(companyId: $companyId, name: $name, natureOfBusiness: $natureOfBusiness, uniqueUrl: $uniqueUrl, image: $image, accessToken: $accessToken, companyUrl: $companyUrl, emailRequiredForCustomerSignup: $emailRequiredForCustomerSignup, availablePaymentMethods: $availablePaymentMethods, razorPayKey: $razorPayKey, razorPaySecret: $razorPaySecret, webUrl: $webUrl, allowNewUserSignUp: $allowNewUserSignUp, loginScreenUsernamePlaceholder: $loginScreenUsernamePlaceholder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyResultImpl &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.natureOfBusiness, natureOfBusiness) ||
                other.natureOfBusiness == natureOfBusiness) &&
            (identical(other.uniqueUrl, uniqueUrl) ||
                other.uniqueUrl == uniqueUrl) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.companyUrl, companyUrl) ||
                other.companyUrl == companyUrl) &&
            (identical(other.emailRequiredForCustomerSignup,
                    emailRequiredForCustomerSignup) ||
                other.emailRequiredForCustomerSignup ==
                    emailRequiredForCustomerSignup) &&
            (identical(
                    other.availablePaymentMethods, availablePaymentMethods) ||
                other.availablePaymentMethods == availablePaymentMethods) &&
            (identical(other.razorPayKey, razorPayKey) ||
                other.razorPayKey == razorPayKey) &&
            (identical(other.razorPaySecret, razorPaySecret) ||
                other.razorPaySecret == razorPaySecret) &&
            (identical(other.webUrl, webUrl) || other.webUrl == webUrl) &&
            (identical(other.allowNewUserSignUp, allowNewUserSignUp) ||
                other.allowNewUserSignUp == allowNewUserSignUp) &&
            (identical(other.loginScreenUsernamePlaceholder,
                    loginScreenUsernamePlaceholder) ||
                other.loginScreenUsernamePlaceholder ==
                    loginScreenUsernamePlaceholder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      companyId,
      name,
      natureOfBusiness,
      uniqueUrl,
      image,
      accessToken,
      companyUrl,
      emailRequiredForCustomerSignup,
      availablePaymentMethods,
      razorPayKey,
      razorPaySecret,
      webUrl,
      allowNewUserSignUp,
      loginScreenUsernamePlaceholder);

  /// Create a copy of CompanyResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyResultImplCopyWith<_$CompanyResultImpl> get copyWith =>
      __$$CompanyResultImplCopyWithImpl<_$CompanyResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyResultImplToJson(
      this,
    );
  }
}

abstract class _CompanyResult implements CompanyResult {
  const factory _CompanyResult(
      {@JsonKey(name: 'company_id') final int? companyId,
      final String? name,
      @JsonKey(name: 'nature_of_business') final String? natureOfBusiness,
      @JsonKey(name: 'unique_url') final String? uniqueUrl,
      final String? image,
      @JsonKey(name: 'access_token') final String? accessToken,
      @JsonKey(name: 'company_url') final String? companyUrl,
      @JsonKey(name: 'email_required_for_customer_signup')
      final String? emailRequiredForCustomerSignup,
      @JsonKey(name: 'available_payment_methods')
      final String? availablePaymentMethods,
      @JsonKey(name: 'razor_pay_key') final String? razorPayKey,
      @JsonKey(name: 'razor_pay_secret') final String? razorPaySecret,
      @JsonKey(name: 'web_url') final String? webUrl,
      @JsonKey(name: 'allow_new_user_sign_up') final String? allowNewUserSignUp,
      @JsonKey(name: 'login_screen_username_placeholder')
      final String? loginScreenUsernamePlaceholder}) = _$CompanyResultImpl;

  factory _CompanyResult.fromJson(Map<String, dynamic> json) =
      _$CompanyResultImpl.fromJson;

  @override
  @JsonKey(name: 'company_id')
  int? get companyId;
  @override
  String? get name;
  @override
  @JsonKey(name: 'nature_of_business')
  String? get natureOfBusiness;
  @override
  @JsonKey(name: 'unique_url')
  String? get uniqueUrl;
  @override
  String? get image;
  @override
  @JsonKey(name: 'access_token')
  String? get accessToken;
  @override
  @JsonKey(name: 'company_url')
  String? get companyUrl;
  @override
  @JsonKey(name: 'email_required_for_customer_signup')
  String? get emailRequiredForCustomerSignup;
  @override
  @JsonKey(name: 'available_payment_methods')
  String? get availablePaymentMethods;
  @override
  @JsonKey(name: 'razor_pay_key')
  String? get razorPayKey;
  @override
  @JsonKey(name: 'razor_pay_secret')
  String? get razorPaySecret;
  @override
  @JsonKey(name: 'web_url')
  String? get webUrl;
  @override
  @JsonKey(name: 'allow_new_user_sign_up')
  String? get allowNewUserSignUp;
  @override
  @JsonKey(name: 'login_screen_username_placeholder')
  String? get loginScreenUsernamePlaceholder;

  /// Create a copy of CompanyResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyResultImplCopyWith<_$CompanyResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
