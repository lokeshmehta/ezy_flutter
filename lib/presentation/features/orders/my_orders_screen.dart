
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/orders_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../config/theme/app_theme.dart';
import 'widgets/order_list_item_widget.dart';
import 'order_details_screen.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order_models.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}


class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInitialOrders());
  }

  void _fetchInitialOrders() {
    final dashboardProvider = context.read<DashboardProvider>();
    final user = dashboardProvider.profileResponse?.results?[0];
    if (user != null) {
      context.read<OrdersProvider>().fetchOrders(
            accessToken: dashboardProvider.accessToken ?? "",
            customerId: user.customerId.toString(),
            isRefresh: true,
          );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final ordersProvider = context.read<OrdersProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final user = dashboardProvider.profileResponse?.results?[0];
      if (user != null && ordersProvider.hasMore && !ordersProvider.isMoreLoading) {
        ordersProvider.fetchOrders(
          accessToken: dashboardProvider.accessToken ?? "",
          customerId: user.customerId.toString(),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, {DateTime? firstDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submitFilters() {
    final ordersProvider = context.read<OrdersProvider>();
    ordersProvider.updateFilters(
      _searchController.text,
      _fromDateController.text,
      _toDateController.text,
    );
    _fetchInitialOrders();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _fromDateController.clear();
      _toDateController.clear();
    });
    final ordersProvider = context.read<OrdersProvider>();
    ordersProvider.clearFilters();
    _fetchInitialOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.white,
        elevation: 4, // 👈 controls shadow intensity
        shadowColor: Colors.black.withOpacity(0.25),
        surfaceTintColor: Colors.transparent,
        title: const Text("My Orders" ,
          style: TextStyle(
            color: Colors.black ,
          ) ,),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: Colors.white,
      child: Column(
        children: [
          // Search Box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search here",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
            ),
          ),
          SizedBox(height: 10.h),
          // Date Pickers Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fromDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context, _fromDateController),
                  decoration: InputDecoration(
                    hintText: "From Date",
                    suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: _toDateController,
                  readOnly: true,
                  onTap: () {
                    DateTime? startDate;
                    if (_fromDateController.text.isNotEmpty) {
                      startDate = DateFormat('dd/MM/yyyy').parse(_fromDateController.text);
                    }
                    _selectDate(context, _toDateController, firstDate: startDate);
                  },
                  decoration: InputDecoration(
                    hintText: "To Date",
                    suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                  child: const Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                  child: const Text("Clear", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return Consumer<OrdersProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.orders.isEmpty) {
          return  Center(child: Text("No orders data found",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16
            ) ,));
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: provider.orders.length + (provider.isMoreLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.orders.length) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final order = provider.orders[index];
            return OrderListItemWidget(
              order: order,
              onViewDetails: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
                );
              },
              onReorder: () => _handleReorder(order),
              onDuplicate: () => _handleDuplicate(order),
              onDelete: () => _handleCancel(order),
              onDownload: () => _handleDownload(order),
            );
          },
        );
      },
    );
  }

  void _handleReorder(OrderHistoryResult order) async {
    // Show confirmation dialog (Android parity)
    final bool? confirm = await _showConfirmDialog(
      title: "Re-Order Confirmation",
      content: "Do you want to re-order the products in this order?",
      confirmText: "Re-Order",
      confirmColor: Colors.orange,
    );

    if (confirm == true && mounted) {
      final ordersProvider = context.read<OrdersProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final user = dashboardProvider.profileResponse?.results?[0];
      if (user != null) {
        final success = await ordersProvider.reorderOrder(
          accessToken: dashboardProvider.accessToken ?? "",
          customerId: user.customerId.toString(),
          oldOrderId: order.orderId.toString(),
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added all products to cart")));
          // Redirect to Cart (Android Activity Redirection)
          // dashboard index 2 is cart in our dash, or /cart route
          while(Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          // Assuming Dashboard handles route or state
        }
      }
    }
  }

  void _handleDuplicate(OrderHistoryResult order) async {
    final bool? confirm = await _showConfirmDialog(
      title: "Duplicate Order Confirmation",
      content: "Do you want to duplicate this order?",
      confirmText: "Duplicate",
      confirmColor: AppTheme.primaryColor,
    );

    if (confirm == true && mounted) {
      final ordersProvider = context.read<OrdersProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final user = dashboardProvider.profileResponse?.results?[0];
      if (user != null) {
        final newOrderId = await ordersProvider.duplicateOrder(
          accessToken: dashboardProvider.accessToken ?? "",
          customerId: user.customerId.toString(),
          oldOrderId: order.orderId.toString(),
        );
        if (newOrderId != null && mounted) {
          _showSuccessDialog("Order Submitted Successfully", "Order ID : #$newOrderId");
          _fetchInitialOrders();
        }
      }
    }
  }

  void _handleCancel(OrderHistoryResult order) async {
    final bool? confirm = await _showConfirmDialog(
      title: "Cancel Order Confirmation",
      content: "Do you want to cancel this order?",
      confirmText: "Cancel Order",
      confirmColor: AppTheme.redColor,
    );

    if (confirm == true && mounted) {
      final ordersProvider = context.read<OrdersProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final user = dashboardProvider.profileResponse?.results?[0];
      if (user != null) {
        final success = await ordersProvider.cancelOrder(
          accessToken: dashboardProvider.accessToken ?? "",
          customerId: user.customerId.toString(),
          orderId: order.orderId.toString(),
        );
        if (success && mounted) {
           _fetchInitialOrders();
        }
      }
    }
  }

  void _handleDownload(OrderHistoryResult order) {
     if (order.pdfFile != null) {
        // Implement PDF download (CommonMethods.downloadpdffilefromurl parity)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Downloading Invoice: ${order.refNo}")));
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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }
}
