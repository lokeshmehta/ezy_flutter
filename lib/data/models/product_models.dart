import 'home_models.dart';

class ProductsResponse {
  int? status;
  String? message;
  int? resultsCount;
  String? totalRecords;
  List<ProductItem?>? results;

  ProductsResponse({
    this.status,
    this.message,
    this.resultsCount,
    this.totalRecords,
    this.results,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      status: json['status'],
      message: json['message'],
      resultsCount: json['results_count'],
      totalRecords: json['total_records']?.toString(),
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => i != null ? ProductItem.fromJson(i) : null)
              .toList()
          : null,
    );
  }
}

class FilterProductResponse {
  int? status;
  String? message;
  List<FilterDivision?>? divisions;
  int? divisionsCount;
  List<FilterSupplier?>? suppliers;
  int? suppliersCount;
  List<FilterTag?>? tags;
  int? tagsCount;
  List<FilterGroup?>? groups;
  int? groupsCount;
  List<FilterGroup?>? groupNames;
  int? groupNamesCount;
  List<FilterDivisionName?>? divisionNames;
  int? divisionNamesCount;

  FilterProductResponse({
    this.status,
    this.message,
    this.divisions,
    this.divisionsCount,
    this.suppliers,
    this.suppliersCount,
    this.tags,
    this.tagsCount,
    this.groups,
    this.groupsCount,
    this.groupNames,
    this.groupNamesCount,
    this.divisionNames,
    this.divisionNamesCount,
  });

  factory FilterProductResponse.fromJson(Map<String, dynamic> json) {
    return FilterProductResponse(
      status: json['status'],
      message: json['message'],
      divisionsCount: json['divisions_count'],
      divisions: json['divisions'] != null
          ? (json['divisions'] as List)
              .map((i) => i != null ? FilterDivision.fromJson(i) : null)
              .toList()
          : null,
      suppliersCount: json['suppliers_count'],
      suppliers: json['suppliers'] != null
          ? (json['suppliers'] as List)
              .map((i) => i != null ? FilterSupplier.fromJson(i) : null)
              .toList()
          : null,
      tagsCount: json['tags_count'],
      tags: json['tags'] != null
          ? (json['tags'] as List)
              .map((i) => i != null ? FilterTag.fromJson(i) : null)
              .toList()
          : null,
      groupsCount: json['groups_count'],
      groups: json['groups'] != null
          ? (json['groups'] as List)
              .map((i) => i != null ? FilterGroup.fromJson(i) : null)
              .toList()
          : null,
      groupNamesCount: json['group_names_count'],
      groupNames: json['group_names'] != null
          ? (json['group_names'] as List)
              .map((i) => i != null ? FilterGroup.fromJson(i) : null)
              .toList()
          : null,
      divisionNamesCount: json['division_names_count'],
      divisionNames: json['division_names'] != null
          ? (json['division_names'] as List)
              .map((i) => i != null ? FilterDivisionName.fromJson(i) : null)
              .toList()
          : null,
    );
  }
}

class FilterDivision {
  String? divisionId;
  String? groupLevel1;
  String? products;
  String? selected;

  FilterDivision({
    this.divisionId,
    this.groupLevel1,
    this.products,
    this.selected = "No",
  });

  factory FilterDivision.fromJson(Map<String, dynamic> json) {
    return FilterDivision(
      divisionId: json['division_id']?.toString(),
      groupLevel1: json['group_level_1']?.toString(),
      products: json['products']?.toString(),
      selected: json['selected']?.toString() ?? "No",
    );
  }
}

class FilterSupplier {
  String? brandId;
  String? brandName;
  String? products;
  String? modUrl;
  String? selected;

  FilterSupplier({
    this.brandId,
    this.brandName,
    this.products,
    this.modUrl,
    this.selected = "No",
  });

  factory FilterSupplier.fromJson(Map<String, dynamic> json) {
    return FilterSupplier(
      brandId: json['brand_id']?.toString(),
      brandName: json['brand_name']?.toString(),
      products: json['products']?.toString(),
      modUrl: json['mod_url']?.toString(),
      selected: json['selected']?.toString() ?? "No",
    );
  }
}

class FilterTag {
  String? tagId;
  String? tagName;
  String? tagSelected;

  FilterTag({
    this.tagId,
    this.tagName,
    this.tagSelected = "No",
  });

  factory FilterTag.fromJson(Map<String, dynamic> json) {
    return FilterTag(
      tagId: json['tag_id']?.toString(),
      tagName: json['tag_name']?.toString(),
      tagSelected: json['tag_selected']?.toString() ?? "No",
    );
  }
}

class FilterGroup {
  String? groupId;
  String? groupLevel2;
  int? products;
  String? groupSelected;

  FilterGroup({
    this.groupId,
    this.groupLevel2,
    this.products,
    this.groupSelected = "No",
  });

  factory FilterGroup.fromJson(Map<String, dynamic> json) {
    return FilterGroup(
      groupId: json['group_id']?.toString(),
      groupLevel2: json['group_level_2']?.toString(),
      products: json['products'],
      groupSelected: json['group_selected']?.toString() ?? "No",
    );
  }
}

class FilterDivisionName {
  String? groupLevel1;
  String? products;

  FilterDivisionName({
    this.groupLevel1,
    this.products,
  });

  factory FilterDivisionName.fromJson(Map<String, dynamic> json) {
    return FilterDivisionName(
      groupLevel1: json['group_level_1']?.toString(),
      products: json['products']?.toString(),
    );
  }
}

class ProductSortResponse {
  int? status;
  String? message;
  int? resultsCount;
  List<SortItem?>? results;

  ProductSortResponse({
    this.status,
    this.message,
    this.resultsCount,
    this.results,
  });

  factory ProductSortResponse.fromJson(Map<String, dynamic> json) {
    return ProductSortResponse(
      status: json['status'],
      message: json['message'],
      resultsCount: json['results_count'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => i != null ? SortItem.fromJson(i) : null)
              .toList()
          : null,
    );
  }
}

class SortItem {
  String? value;
  String? name;
  String? selected;

  SortItem({this.value, this.name, this.selected = "No"});

  factory SortItem.fromJson(Map<String, dynamic> json) {
    return SortItem(
      value: json['value']?.toString(),
      name: json['name']?.toString(),
      selected: json['selected']?.toString() ?? "No",
    );
  }
}

class ProductDetailsResponse {
  int? status;
  String? message;
  int? resultsCount;
  List<ProductDetailItem?>? results;

  ProductDetailsResponse({
    this.status,
    this.message,
    this.resultsCount,
    this.results,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      status: json['status'],
      message: json['message'],
      resultsCount: json['results_count'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((i) => i != null ? ProductDetailItem.fromJson(i) : null)
              .toList()
          : null,
    );
  }
}

class ProductDetailItem extends ProductItem {
  List<ProductField?>? productFields;
  List<ProductSpecification?>? productSpecifications;
  List<ProductItem?>? similarProducts;
  List<ProductItem?>? sameCategoryProducts;
  String? item;
  String? sku;
  String? unitsShipper;
  String? innerBarcode;
  String? shipperBarcode;
  String? outerBarcode;
  String? primaryBarcode;

  ProductDetailItem({
    super.addedToCart,
    super.addedQty,
    super.addedSubTotal,
    super.productId,
    super.name, // Mapping 'title' to 'name' for consistency with ProductItem
    super.description,
    super.shortDescription,
    super.image,
    super.brandName,
    super.brandId,
    super.price,
    super.promotionPrice,
    super.stockUnlimited,
    super.qtyStatus,
    super.availableStockQty,
    super.minimumOrderQty,
    super.soldAs,
    super.gst,
    super.gstPercentage,
    super.hasPromotion,
    super.label,
    super.productAvailable,
    super.supplierAvailable,
    super.notAvailableDaysMessage,
    super.isFavourite,
    super.discountPercentage,
    super.discountId,
    super.discountName,
    super.qtyPerOuter,
    super.orderedAs,
    super.apiData,
    this.productFields,
    this.productSpecifications,
    this.similarProducts,
    this.sameCategoryProducts,
    this.item,
    this.sku,
    this.unitsShipper,
    this.innerBarcode,
    this.shipperBarcode,
    this.outerBarcode,
    this.primaryBarcode,
  });

  factory ProductDetailItem.fromJson(Map<String, dynamic> json) {
    final base = ProductItem.fromJson(json);
    return ProductDetailItem(
      addedToCart: base.addedToCart,
      addedQty: base.addedQty,
      addedSubTotal: base.addedSubTotal,
      productId: base.productId,
      name: json['title']?.toString() ?? base.name,
      description: base.description,
      shortDescription: base.shortDescription,
      image: base.image,
      brandName: base.brandName,
      brandId: base.brandId,
      price: base.price,
      promotionPrice: base.promotionPrice,
      stockUnlimited: base.stockUnlimited,
      qtyStatus: base.qtyStatus,
      availableStockQty: base.availableStockQty,
      minimumOrderQty: base.minimumOrderQty,
      soldAs: base.soldAs,
      gst: base.gst,
      gstPercentage: base.gstPercentage,
      hasPromotion: base.hasPromotion,
      label: base.label,
      productAvailable: base.productAvailable,
      supplierAvailable: base.supplierAvailable,
      notAvailableDaysMessage: base.notAvailableDaysMessage,
      isFavourite: base.isFavourite,
      discountPercentage: base.discountPercentage,
      discountId: base.discountId,
      discountName: base.discountName,
      qtyPerOuter: base.qtyPerOuter,
      orderedAs: base.orderedAs,
      apiData: base.apiData,
      productFields: json['product_fields'] != null
          ? (json['product_fields'] as List)
              .map((i) => i != null ? ProductField.fromJson(i) : null)
              .toList()
          : null,
      productSpecifications: json['product_specifications'] != null
          ? (json['product_specifications'] as List)
              .map((i) => i != null ? ProductSpecification.fromJson(i) : null)
              .toList()
          : null,
      similarProducts: json['similar_products'] != null
          ? (json['similar_products'] as List)
              .map((i) => i != null ? ProductItem.fromJson(i) : null)
              .toList()
          : null,
      sameCategoryProducts: json['same_category_products'] != null
          ? (json['same_category_products'] as List)
              .map((i) => i != null ? ProductItem.fromJson(i) : null)
              .toList()
          : null,
      item: json['item']?.toString(),
      sku: json['sku']?.toString(),
      unitsShipper: json['units_shipper']?.toString(),
      innerBarcode: json['inner_barcode']?.toString(),
      shipperBarcode: json['shipper_barcode']?.toString(),
      outerBarcode: json['outer_barcode']?.toString(),
      primaryBarcode: json['primary_barcode']?.toString(),
    );
  }
}

class ProductField {
  String? name;

  ProductField({this.name});

  factory ProductField.fromJson(Map<String, dynamic> json) {
    return ProductField(name: json['name']?.toString());
  }
}

class ProductSpecification {
  String? id;
  String? specificationId;
  String? productId;
  String? description;
  String? specification;

  ProductSpecification({
    this.id,
    this.specificationId,
    this.productId,
    this.description,
    this.specification,
  });

  factory ProductSpecification.fromJson(Map<String, dynamic> json) {
    return ProductSpecification(
      id: json['id']?.toString(),
      specificationId: json['specification_id']?.toString(),
      productId: json['product_id']?.toString(),
      description: json['description']?.toString(),
      specification: json['specification']?.toString(),
    );
  }
}
