import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/orders_provider.dart';
import '../../../data/models/order_models.dart';
import '../../widgets/custom_loader_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderHistoryResult order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider = context.read<DashboardProvider>();
      final profile = dashboardProvider.profileResponse?.results;
      final customerId = (profile != null && profile.isNotEmpty) ? profile[0]?.customerId?.toString() ?? "" : "";

      context.read<OrdersProvider>().fetchOrderDetails(
            accessToken: dashboardProvider.accessToken ?? "",
            customerId: customerId,
            orderId: widget.order.orderId.toString(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloading Invoice...")));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<OrdersProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.orderDetails == null) {
                return const SizedBox.shrink(); // Overlay handles loading
              }
              if (provider.orderDetails == null) {
                return const Center(child: Text("Failed to load details"));
              }
    
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummarySection(),
                    const Divider(),
                    _buildSectionTitle("Supplier Details"),
                    SizedBox(height: 8.h),
                    _buildSupplierDetails(provider.orderDetails!.results),
                    const Divider(),
                    _buildSectionTitle("Address Details"),
                    SizedBox(height: 8.h),
                    _buildAddressDetails(),
                    const Divider(),
                    _buildSectionTitle("Payment Details"),
                    SizedBox(height: 8.h),
                    _buildPaymentDetails(),
                    const Divider(),
                    if (widget.order.remarks != null && widget.order.remarks!.isNotEmpty) ...[
                      _buildSectionTitle("Order Notes"),
                      SizedBox(height: 4.h),
                      Text(widget.order.remarks!, style: TextStyle(fontSize: 14.sp)),
                      const Divider(),
                    ],
                    SizedBox(height: 20.h),
                    _buildActionButtons(),
                    SizedBox(height: 30.h),
                  ],
                ),
              );
            },
          ),
          Consumer<OrdersProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                 return Container(
                    color: Colors.black54,
                    child: Center(
                      child: SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                             CustomLoaderWidget(size: 100.w),
                             Text(
                               "Please Wait",
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                 color: AppTheme.primaryColor,
                                 fontSize: 13.sp,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                          ],
                        ),
                      ),
                    ),
                  );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      children: [
        _buildRow("Order ID :", "#${widget.order.refNo}"),
        _buildRow("Status :", widget.order.orderStatus ?? "", valueColor: AppTheme.tealColor),
        _buildRow("Order Date :", widget.order.orderDate?.split(" ")[0] ?? ""),
        _buildRow("Order Time :", widget.order.orderDate?.contains(" ") == true ? widget.order.orderDate!.split(" ")[1] : ""),
      ],
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: AppTheme.darkGrayColor)),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: valueColor ?? AppTheme.textColor)),
        ],
      ),
    );
  }

  Widget _buildSupplierDetails(List<OrderDetailResult>? results) {
    if (results == null || results.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final supplier = results[index];
        return Card(
          elevation: 0,
          color: Colors.grey[100],
          margin: EdgeInsets.only(bottom: 10.h),
          child: ExpansionTile(
            title: Text(supplier.brandName ?? "Supplier", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Status: ${supplier.supplierStatus}"),
            children: (supplier.products ?? []).map((p) => ListTile(
              leading: Image.network(p.productImage ?? "", width: 40.w, errorBuilder: (_,__,___)=> const Icon(Icons.image)),
              title: Text(p.productName ?? "", style: TextStyle(fontSize: 13.sp)),
              subtitle: Text("Qty: ${p.quantity} | ${p.orderedAs}"),
              trailing: Text("AUD ${p.totalAmount}"),
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAddressDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Shipping Address:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
        Text(widget.order.deliveryAddress ?? "", style: TextStyle(fontSize: 12.sp)),
        SizedBox(height: 10.h),
        Text("Billing Address:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
        Text(widget.order.billingAddress ?? "", style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      children: [
        _buildRow("Sub Total :", "AUD ${widget.order.subTotal}"),
        _buildRow("Discount :", "AUD ${widget.order.discount}", valueColor: AppTheme.redColor),
        _buildRow("Shipping Charges :", "AUD ${widget.order.deliveryCharge}"),
        _buildRow("Add. Supplier Shipping :", "AUD ${widget.order.suppliersExceededShippingCharge}"),
        _buildRow("Tax (GST) :", "AUD ${widget.order.gst}"),
        const Divider(),
        _buildRow("Total :", "AUD ${widget.order.orderAmount}", valueColor: AppTheme.primaryColor),
      ],
    );
  }

  Widget _buildActionButtons() {
    final bool isCancelled = widget.order.orderStatus?.toLowerCase() == "cancelled";
    
    return Column(
      children: [
        _buildActionButton("DUPLICATE ORDER", AppTheme.primaryColor, () => _handleDuplicate()),
        SizedBox(height: 10.h),
        _buildActionButton("RE-ORDER", AppTheme.secondaryColor, () => _handleReorder()),
        if (!isCancelled) ...[
          SizedBox(height: 10.h),
          _buildActionButton("CANCEL ORDER", AppTheme.redColor, () => _handleCancel()),
        ],
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 45.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _handleReorder() async {
    final bool? confirm = await _showConfirmDialog(
      title: "Re-Order Confirmation",
      content: "Do you want to re-order the products in this order?",
      confirmText: "Re-Order",
      confirmColor: AppTheme.secondaryColor,
    );

    if (confirm == true && mounted) {
      final ordersProvider = context.read<OrdersProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final profile = dashboardProvider.profileResponse?.results;
      final customerId = (profile != null && profile.isNotEmpty) ? profile[0]?.customerId?.toString() ?? "" : "";

      if (customerId.isNotEmpty) {
        final success = await ordersProvider.reorderOrder(
          accessToken: dashboardProvider.accessToken ?? "",
          customerId: customerId,
          oldOrderId: widget.order.orderId.toString(),
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added all products to cart")));
          Navigator.pop(context); // Go back to orders
        }
      }
    }
  }

  void _handleDuplicate() async {
    final bool? confirm = await _showConfirmDialog(
      title: "Duplicate Order Confirmation",
      content: "Do you want to duplicate this order?",
      confirmText: "Duplicate",
      confirmColor: AppTheme.primaryColor,
    );

    if (confirm == true && mounted) {
      final ordersProvider = context.read<OrdersProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final profile = dashboardProvider.profileResponse?.results;
      final customerId = (profile != null && profile.isNotEmpty) ? profile[0]?.customerId?.toString() ?? "" : "";

      if (customerId.isNotEmpty) {
        final newOrderId = await ordersProvider.duplicateOrder(
          accessToken: dashboardProvider.accessToken ?? "",
          customerId: customerId,
          oldOrderId: widget.order.orderId.toString(),
        );
        if (newOrderId != null && mounted) {
          _showSuccessDialog("Order Submitted Successfully", "Order ID : #$newOrderId");
        }
      }
    }
  }

  void _handleCancel() async {
    final bool? confirm = await _showConfirmDialog(
      title: "Cancel Order Confirmation",
      content: "Do you want to cancel this order?",
      confirmText: "Cancel Order",
      confirmColor: AppTheme.redColor,
    );

    if (confirm == true && mounted) {
      final ordersProvider = context.read<OrdersProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final profile = dashboardProvider.profileResponse?.results;
      final customerId = (profile != null && profile.isNotEmpty) ? profile[0]?.customerId?.toString() ?? "" : "";

      if (customerId.isNotEmpty) {
        final success = await ordersProvider.cancelOrder(
          accessToken: dashboardProvider.accessToken ?? "",
          customerId: customerId,
          orderId: widget.order.orderId.toString(),
        );
        if (success && mounted) {
           Navigator.pop(context);
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ],
      ),
    );
  }
}
