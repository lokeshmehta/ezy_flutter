import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme/app_theme.dart';
import '../../providers/dashboard_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMap(String address) async {
    // Basic Google Maps intent
     final Uri launchUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$address");
     if (await canLaunchUrl(launchUri)) {
       await launchUrl(launchUri, mode: LaunchMode.externalApplication);
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: TextStyle(color: Colors.black, fontSize: 18.sp),
        ),
        backgroundColor: Colors.white,
        elevation: 4, // 👈 controls shadow intensity
        shadowColor: Colors.black.withOpacity(0.25),
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back , color: Colors.black,),
          onPressed: () {
             Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          final profile = provider.profileResponse?.results?.isNotEmpty == true
              ? provider.profileResponse!.results![0]
              : null;
          
          if (profile == null) {
            return Center(child: CircularProgressIndicator());
          }

          final mobile = profile.companyMobile ?? "N/A";
          final email = profile.companyEmail ?? "N/A";
          final address = "${profile.companyStreet}, ${profile.companySuburb}, ${profile.companyState}, ${profile.companyPostcode}";
            // Construct address matching Android logic

          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactItem(
                  icon: Icons.phone,
                  title: "Mobile Number",
                  value: mobile,
                  onTap: () => _makePhoneCall(mobile),
                ),
                _buildDivider(),
                _buildContactItem(
                  icon: Icons.email,
                  title: "Email Address",
                  value: email,
                  onTap: () => _sendEmail(email),
                ),
                _buildDivider(),
                _buildContactItem(
                  icon: Icons.location_on,
                  title: "Address",
                  value: address,
                  onTap: () => _openMap(address),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Divider(color: Colors.grey[300]),
    );
  }

  Widget _buildContactItem({required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
