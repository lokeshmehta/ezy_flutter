import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../../data/models/profile_models.dart';
import '../../../core/constants/app_theme.dart';
import '../../../config/routes/app_routes.dart';

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
    
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) {
            context.read<AddressProvider>().fetchAddresses();
        }
    });
  }

  void _confirmDelete(String addressId) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
              title: const Text("Delete Address"),
              content: const Text("Are you sure you want to delete this address?"),
              actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                  TextButton(
                      onPressed: () {
                          Navigator.pop(ctx);
                          context.read<AddressProvider>().deleteAddress(addressId).then((success) {
                             if (success && mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address deleted successfully")));
                             }
                          });
                      },
                      child: const Text("Delete", style: TextStyle(color: AppTheme.redColor)),
                  )
              ],
          )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Addresses", style: TextStyle(color: AppTheme.white)),
        backgroundColor: AppTheme.orderSuccessTeal,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
             return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.addressList.isEmpty) {
             return Center(
                 child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                         Icon(Icons.location_off, size: 60.sp, color: AppTheme.darkGrayColor),
                         SizedBox(height: 10.h),
                         Text("No addresses found", style: TextStyle(fontSize: 16.sp, color: AppTheme.darkGrayColor)),
                         SizedBox(height: 20.h),
                         ElevatedButton.icon(
                             onPressed: () => context.push(AppRoutes.addAddress),
                             icon: const Icon(Icons.add, color: AppTheme.white),
                             label: const Text("Add New Address", style: TextStyle(color: AppTheme.white)),
                             style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orderSuccessTeal),
                         )
                     ],
                 )
             );
          }
          
          return ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: provider.addressList.length,
              itemBuilder: (ctx, index) {
                  final address = provider.addressList[index];
                  return _buildAddressItem(address);
              }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addAddress),
        backgroundColor: AppTheme.orderSuccessTeal,
        child: const Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }
  
  Widget _buildAddressItem(AddressItem address) {
      bool isDefault = address.defaultAddress == "Yes";
      return Card(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text("${address.firstName ?? ""} ${address.lastName ?? ""}", 
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                              if (isDefault)
                                  Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                          color: AppTheme.lightGreenBg,
                                          borderRadius: BorderRadius.circular(4.r)
                                      ),
                                      child: Text("DEFAULT", style: TextStyle(fontSize: 10.sp, color: AppTheme.darkGreenText, fontWeight: FontWeight.bold)),
                                  )
                          ],
                      ),
                      SizedBox(height: 4.h),
                      Text(address.street ?? "", style: TextStyle(fontSize: 14.sp)),
                      if (address.street2 != null && address.street2!.isNotEmpty)
                         Text(address.street2!, style: TextStyle(fontSize: 14.sp)),
                      Text("${address.suburb ?? ""}, ${address.state ?? ""} ${address.postcode ?? ""}", 
                          style: TextStyle(fontSize: 14.sp)),
                      SizedBox(height: 4.h),
                      Text("Phone: ${address.phone ?? ""}", style: TextStyle(fontSize: 13.sp, color: AppTheme.darkGrayColor)),
                      
                      SizedBox(height: 10.h),
                      Divider(thickness: 1, color: AppTheme.hintColor),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                               TextButton.icon(
                                   onPressed: () {
                                       // Pass address object to edit screen
                                       context.push(AppRoutes.addAddress, extra: address);
                                   },
                                   icon: Icon(Icons.edit, size: 16.sp, color: AppTheme.primaryColor),
                                   label: Text("Edit", style: TextStyle(color: AppTheme.primaryColor, fontSize: 13.sp))
                               ),
                               TextButton.icon(
                                   onPressed: () => _confirmDelete(address.addressId ?? ""),
                                   icon: Icon(Icons.delete, size: 16.sp, color: AppTheme.redColor),
                                   label: Text("Delete", style: TextStyle(color: AppTheme.redColor, fontSize: 13.sp))
                               ),
                          ],
                      )
                  ],
              ),
          ),
      );
  }
}
