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
    
    // Strip everything except digits and dots
    String cleanPrice = price.replaceAll(RegExp(r'[^0-9.]'), '');
    String cleanPromo = promoPrice.replaceAll(RegExp(r'[^0-9.]'), '');

    final priceVal = double.tryParse(cleanPrice) ?? 0.0;
    final promoVal = double.tryParse(cleanPromo) ?? 0.0;
    
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

  static String decodeHtmlEntities(String? text) {
    if (text == null) return "";
    return text
      .replaceAll("&amp;", "&")
      .replaceAll("&lt;", "<")
      .replaceAll("&gt;", ">")
      .replaceAll("&quot;", "\"")
      .replaceAll("&apos;", "'")
      .replaceAll("&#39;", "'");
  }
}
