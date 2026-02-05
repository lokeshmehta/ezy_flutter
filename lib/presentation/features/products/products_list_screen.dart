import 'package:flutter/material.dart';

class ProductsListScreen extends StatelessWidget {
  final String? supplierId;
  final String? backNav;

  const ProductsListScreen({
    super.key,
    this.supplierId,
    this.backNav,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products List")),
      body: Center(
        child: Text("Products List Screen\nSupplier ID: $supplierId"),
      ),
    );
  }
}
