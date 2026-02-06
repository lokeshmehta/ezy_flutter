class CommonMethods {
  static String productsBack = "";
  static String supplierIDs = "";
  static String categoryIDs = "";
  static String groupIDs = "";
  static String selecetedProducts = "";
  static String selectFirstTime = "";
  static String tagIDs = "";
  static String sortIDs = "";
  static String firstSuppliers = "";
  static String firstGroupids = "";
  static String firstCatIds = "";
  static String firstSelProds = "";
  static String firstTags = "";
  static String filterSelected = "All Products";
  
  // Shared pagination and state
  static String cartCount = "0";
  static int supplierCount = 0;
  static String suppliers = "";

  static void resetProductFilters() {
    productsBack = "";
    supplierIDs = "";
    categoryIDs = "";
    groupIDs = "";
    selecetedProducts = "";
    selectFirstTime = "";
    tagIDs = "";
    sortIDs = "";
    firstSuppliers = "";
    firstGroupids = "";
    firstCatIds = "";
    firstSelProds = "";
    firstTags = "";
    filterSelected = "All Products";
  }

  static String findDiscount(String? price, String? promoPrice) {
    if (price == null || promoPrice == null) return "0";
    final priceVal = double.tryParse(price) ?? 0.0;
    final promoVal = double.tryParse(promoPrice) ?? 0.0;
    if (priceVal <= 0 || promoVal <= 0 || promoVal >= priceVal) return "0";
    final discount = ((priceVal - promoVal) / priceVal) * 100;
    return discount.toStringAsFixed(0);
  }
  static String checkNullempty(String? value) {
    if (value == null || value.isEmpty || value == "null") {
      return "";
    }
    return value;
  }
}
