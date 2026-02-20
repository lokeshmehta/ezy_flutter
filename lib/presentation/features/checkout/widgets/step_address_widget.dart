import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/checkout_provider.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_messages.dart';


class StepAddressWidget extends StatefulWidget {
  const StepAddressWidget({super.key});

  @override
  State<StepAddressWidget> createState() => _StepAddressWidgetState();
}

class _StepAddressWidgetState extends State<StepAddressWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();

    return Column(
      children: [
        // Scrollable Form Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Billing Details"),
                SizedBox(height: 15.h),
                _buildLabelAndField(provider.billFirstNameController, "First Name *", "Kamlesh"),
                _buildLabelAndField(provider.billLastNameController, "Last Name *", "jangid"),
                _buildLabelAndField(provider.billStreetController, "Street Address *", "Enter Your House number and street name"),
                _buildLabelAndField(provider.billStreet2Controller, "", "Enter Your Apartment, suite, unit etc.."), // No label for 2nd line in screenshot usually? Or maybe hidden. Assuming screenshot shows blank label or just box. Actually 2nd box has hint. I'll pass empty label or manage spacing.
                // Screenshot shows "Street Address *" then two boxes. 
                // Let's handle this: The first call handles the label. The second just the box.
                // But my helper does label + box. 
                // Let's make label optional.
                
                _buildLabelAndField(provider.billCityController, "Town / City *", "Enter Your Town / City"),
                _buildLabelAndField(provider.billStateController, "State / Country *", "Enter Your State / Country"),
                _buildLabelAndField(provider.billPostCodeController, "Postcode / ZIP *", "Enter Your Postcode / ZIP"),
                _buildLabelAndField(provider.billPhoneController, "Phone *", "9012345678", keyboardType: TextInputType.phone),
                _buildLabelAndField(provider.billEmailController, "Email Address *", "Enter Your Email", keyboardType: TextInputType.emailAddress),

                SizedBox(height: 10.h),
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
                  SizedBox(height: 15.h),
                  _buildSectionTitle("Shipping Details"),
                  SizedBox(height: 15.h),
                  
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

                  _buildLabelAndField(provider.shipFirstNameController, "First Name *", "First Name"),
                  _buildLabelAndField(provider.shipLastNameController, "Last Name *", "Last Name"),
                  _buildLabelAndField(provider.shipStreetController, "Street Address *", "Enter Your House number and street name"),
                  _buildLabelAndField(provider.shipStreet2Controller, "", "Enter Your Apartment, suite, unit etc.."),
                  _buildLabelAndField(provider.shipCityController, "Town / City *", "Enter Your Town / City"),
                  _buildLabelAndField(provider.shipStateController, "State / Country *", "Enter Your State / Country"),
                  _buildLabelAndField(provider.shipPostCodeController, "Postcode / ZIP *", "Enter Your Postcode / ZIP"),
                  _buildLabelAndField(provider.shipPhoneController, "Phone *", "Phone"),
                  _buildLabelAndField(provider.shipEmailController, "Email Address *", "Email Address", keyboardType: TextInputType.emailAddress),
                ],
                
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),

        // Sticky Bottom Navigation (Shadow + Buttons)
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
               // Back Button
               Expanded(
                 child: InkWell(
                   onTap: () {
                      provider.previousStep();
                   },
                   child: Container(
                     height: 45.h,
                     decoration: BoxDecoration(
                       color: Color(0xFFF5A623), // Orange/Yellow from screenshot
                       borderRadius: BorderRadius.circular(5.r),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
                         SizedBox(width: 5.w),
                         Text("Back", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                       ],
                     ),
                   ),
                 ),
               ),
               
               // 2/3 Indicator
               Expanded(
                 child: Center(
                   child: Text("2/3", style: TextStyle(color: Color(0xFF0038FF), fontSize: 16.sp, fontWeight: FontWeight.bold)),
                 ),
               ),
               
               // Next Button
               Expanded(
                 child: InkWell(
                   onTap: () {
                      if(provider.validateAddressStep()) {
                          provider.nextStep();
                      } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppMessages.pleaseFillAllRequiredFields)));
                      }
                   },
                   child: Container(
                     height: 45.h,
                     decoration: BoxDecoration(
                       color: Color(0xFFF5A623), // Orange/Yellow
                       borderRadius: BorderRadius.circular(5.r),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text("Next", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                         SizedBox(width: 5.w),
                         Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
                       ],
                     ),
                   ),
                 ),
               ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0038FF), // Blue color from screenshot
      ),
    );
  }

  Widget _buildLabelAndField(TextEditingController controller, String label, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0038FF), // Blueish Label
              ),
            ),
            SizedBox(height: 8.h),
          ],
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14.sp, color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(5.r),
                 borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(5.r),
                 borderSide: BorderSide(color: Color(0xFF0038FF), width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
