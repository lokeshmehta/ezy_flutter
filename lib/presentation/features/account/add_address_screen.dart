import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../providers/address_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/profile_models.dart';
import '../../../core/constants/app_messages.dart';
import '../../widgets/custom_loader_widget.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressItem? addressToEdit;
  
  const AddAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _streetController;
  late TextEditingController _street2Controller;
  late TextEditingController _suburbController;
  late TextEditingController _stateController;
  late TextEditingController _postcodeController;
  
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final address = widget.addressToEdit;
    
    _firstNameController = TextEditingController(text: address?.firstName ?? "");
    _lastNameController = TextEditingController(text: address?.lastName ?? "");
    _emailController = TextEditingController(text: address?.email ?? "");
    _mobileController = TextEditingController(text: address?.phone ?? "");
    _streetController = TextEditingController(text: address?.street ?? "");
    _street2Controller = TextEditingController(text: address?.street2 ?? "");
    _suburbController = TextEditingController(text: address?.suburb ?? "");
    _stateController = TextEditingController(text: address?.state ?? "");
    _postcodeController = TextEditingController(text: address?.postcode ?? "");
    
    _isDefault = address?.defaultAddress == "Yes";
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _streetController.dispose();
    _street2Controller.dispose();
    _suburbController.dispose();
    _stateController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
     if (!_formKey.currentState!.validate()) return;
     
     final provider = context.read<AddressProvider>();
     final defaultVal = _isDefault ? "Yes" : "No"; // Assuming "Yes"/"No" match API expectation from inspection
     
     bool success;
     if (widget.addressToEdit != null) {
         // Edit Mode
         success = await provider.editAddress(
             addressId: widget.addressToEdit!.addressId ?? "",
             firstName: _firstNameController.text,
             lastName: _lastNameController.text,
             mobile: _mobileController.text,
             email: _emailController.text,
             street: _streetController.text,
             street2: _street2Controller.text,
             suburb: _suburbController.text,
             state: _stateController.text,
             postcode: _postcodeController.text,
             defaultAddress: defaultVal
         );
     } else {
         // Add Mode
         success = await provider.addAddress(
             firstName: _firstNameController.text,
             lastName: _lastNameController.text,
             mobile: _mobileController.text,
             email: _emailController.text,
             street: _streetController.text,
             street2: _street2Controller.text,
             suburb: _suburbController.text,
             state: _stateController.text,
             postcode: _postcodeController.text,
             defaultAddress: defaultVal
         );
     }

     if (!mounted) return;
     
     if (success) {
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(widget.addressToEdit != null ? "Address updated successfully" : "Address added successfully"))
         );
         context.pop();
     } else {
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red)
         );
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4, // 👈 controls shadow intensity
        shadowColor: Colors.black.withOpacity(0.25),
        surfaceTintColor: Colors.transparent,
        title: Text(widget.addressToEdit != null ? "Edit Address" : "Add Address", style: const TextStyle(color: Colors.black)),
        backgroundColor: AppTheme.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.blackColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),

      ),
      body: Consumer<AddressProvider>(
          builder: (context, provider, child) {
              return Stack(
                  children: [
                      SingleChildScrollView(
                          padding: EdgeInsets.all(16.w),
                          child: Form(
                              key: _formKey,
                              child: Column(
                                  children: [
                                      _buildTextField("First Name", _firstNameController, validator: (v) => v!.isEmpty ? AppMessages.enterValidFirstName : null),
                                      _buildTextField("Last Name", _lastNameController, validator: (v) => v!.isEmpty ? AppMessages.enterValidLastName : null),
                                      _buildTextField("Email", _emailController, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? AppMessages.enterValidEmail : null),
                                      _buildTextField("Mobile Number", _mobileController, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? AppMessages.enterValidMobileNumber : null),
                                      _buildTextField("Street Address", _streetController, validator: (v) => v!.isEmpty ? AppMessages.enterValidStreetAddress : null),
                                      _buildTextField("Street 2 (Optional)", _street2Controller),
                                      _buildTextField("Suburb / City", _suburbController, validator: (v) => v!.isEmpty ? AppMessages.enterValidTownCity : null),
                                      Row(
                                          children: [
                                              Expanded(child: _buildTextField("State", _stateController, validator: (v) => v!.isEmpty ? AppMessages.enterValidStateCountry : null)),
                                              SizedBox(width: 10.w),
                                              Expanded(child: _buildTextField("Postcode", _postcodeController, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? AppMessages.enterValidPostcode : null)),
                                          ],
                                      ),
                                      SizedBox(height: 10.h),
                                      CheckboxListTile(
                                          title: const Text("Set as Default Address"),
                                          value: _isDefault,
                                          onChanged: (val) {
                                              setState(() {
                                                  _isDefault = val ?? false;
                                              });
                                          },
                                          activeColor: AppTheme.primaryColor,
                                          controlAffinity: ListTileControlAffinity.leading,
                                          contentPadding: EdgeInsets.zero,
                                      ),
                                      SizedBox(height: 30.h),
                                      SizedBox(
                                          width: double.infinity,
                                          height: 50.h,
                                          child: ElevatedButton(
                                              onPressed: provider.isLoading ? null : _onSubmit,
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.tealColor,
                                                  minimumSize: Size(double.infinity, 45.h),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r))
                                              ),
                                              child: Text(
                                                  widget.addressToEdit != null ? "Update Address" : "Add Address", 
                                                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)
                                              ),
                                          ),
                                      )
                                  ],
                              ),
                          ),
                      ),
                      if(provider.isLoading)
                          Container(
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
                          )
                  ],
              );
          },
      ),
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
      return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.inputRadius.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
          ),
      );
  }
}
