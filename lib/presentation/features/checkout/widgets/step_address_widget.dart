
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../core/constants/app_theme.dart';


class StepAddressWidget extends StatefulWidget {
  const StepAddressWidget({super.key});

  @override
  State<StepAddressWidget> createState() => _StepAddressWidgetState();
}

class _StepAddressWidgetState extends State<StepAddressWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Billing Address"),
          SizedBox(height: 10.h),
          _buildTextField(provider.billFirstNameController, "First Name *"),
          _buildTextField(provider.billLastNameController, "Last Name *"),
          _buildTextField(provider.billStreetController, "Address 1 *"),
          _buildTextField(provider.billStreet2Controller, "Address 2"),
          _buildTextField(provider.billCityController, "City / Suburb *"),
          _buildTextField(provider.billStateController, "State / Province *"),
          _buildTextField(provider.billPostCodeController, "Zip / Postal Code *"),
          _buildTextField(provider.billPhoneController, "Phone Number *"),
          _buildTextField(provider.billEmailController, "Email Address *", keyboardType: TextInputType.emailAddress),

          SizedBox(height: 20.h),
          Row(
            children: [
              Checkbox(
                value: provider.isNewAddressChecked,
                onChanged: (val) {
                  provider.toggleNewAddress(val ?? false);
                },
                activeColor: Colors.teal,
              ),
              Text(
                "Ship to a different address?",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.normal),
              ),
            ],
          ),

          if (provider.isNewAddressChecked) ...[
            SizedBox(height: 10.h),
            _buildSectionTitle("Shipping Address"),
            SizedBox(height: 10.h),
            
            // Saved Addresses Dropdown
            if (provider.addressList.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 15.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: provider.selectedAddressIndex,
                    items: [
                      DropdownMenuItem(
                        value: 0,
                        child: Text("Choose Shipping Address *"),
                      ),
                      ...List.generate(provider.addressList.length, (index) {
                        final addr = provider.addressList[index];
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            "${addr.firstName} ${addr.lastName}, ${addr.street}...",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        provider.onAddressSelected(val);
                      }
                    },
                  ),
                ),
              ),

            _buildTextField(provider.shipFirstNameController, "First Name *"),
            _buildTextField(provider.shipLastNameController, "Last Name *"),
            _buildTextField(provider.shipStreetController, "Address 1 *"),
            _buildTextField(provider.shipStreet2Controller, "Address 2"),
            _buildTextField(provider.shipCityController, "City / Suburb *"),
            _buildTextField(provider.shipStateController, "State / Province *"),
            _buildTextField(provider.shipPostCodeController, "Zip / Postal Code *"),
            _buildTextField(provider.shipPhoneController, "Phone Number *"),
            _buildTextField(provider.shipEmailController, "Email Address *", keyboardType: TextInputType.emailAddress),
          ],
          
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                  if(provider.validateAddressStep()) {
                      provider.nextStep();
                  } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all required fields")));
                  }
              },
              style: ElevatedButton.styleFrom(
                 backgroundColor: AppTheme.tealColor,
                 foregroundColor: Colors.white,
                 minimumSize: Size(double.infinity, 45.h),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.authButtonRadius.r))
              ),
              child: Text("NEXT", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          
          SizedBox(height: 80.h), // Space for Bottom Bar
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(AppTheme.inputRadius.r),
             borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}
