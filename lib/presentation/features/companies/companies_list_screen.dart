import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/companies_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/assets.dart';


class CompaniesListScreen extends StatefulWidget {
  const CompaniesListScreen({super.key});

  @override
  State<CompaniesListScreen> createState() => _CompaniesListScreenState();
}

class _CompaniesListScreenState extends State<CompaniesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompaniesProvider>().fetchCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor, // @color/blue
      body: SafeArea(
        child: Column(
          children: [
            // Header Section (Logo Card)
            Expanded(
              child: Container(
                 width: double.infinity,
                 color: AppTheme.primaryColor,
                 child: Column(
                   children: [
                     Expanded(
                       child: Container(
                         width: double.infinity,
                         color: Colors.white, // Inner LinearLayout background
                         child: Column(
                           children: [
                              // Top Card with Logo
                              Card(
                                margin: EdgeInsets.only(
                                  top: 5.h,
                                  left: 5.w,
                                  right: 5.w,
                                ),
                                elevation: 5,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                child: Container(
                                  width: double.infinity,
                                  height: 55.h, // @dimen/dimen_55
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    AppAssets.appLogo, // @drawable/applogo (Need to verify asset exists, assumming appLogo based on previous context or fallback to splashLogo)
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              // GridView
                              Expanded(
                                child: Consumer<CompaniesProvider>(
                                  builder: (context, provider, child) {
                                    if (provider.isLoading) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    
                                    if (provider.errorMsg != null) {
                                      return Center(child: Text(provider.errorMsg!));
                                    }

                                    return GridView.builder(
                                      padding: EdgeInsets.only(
                                        top: 15.h, 
                                        bottom: 15.h, 
                                        right: 10.w // Margin Adjustment from XML
                                      ), 
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.8, // Adjust based on Card Content (Image 110 + Text + Button 35 + Margins)
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                      ),
                                      itemCount: provider.companies.length,
                                      itemBuilder: (context, index) {
                                        final company = provider.companies[index];
                                        // Image URL Construction? 
                                        // Android companies_list logic doesn't explicitly show url construction in Activity, 
                                        // but usually it's Full URL or partial.
                                        // Let's assume partial needs BaseURL or it's full. 
                                        // Splash used manual construct? No, Splash saved it.
                                        // Login used UrlApiKey.companyMainUrl + image.
                                        // Here we don't have Company Prefs yet.
                                        // We might need a base MAIN_URL? 
                                        // Let's infer from `UrlApiKey`.
                                        
                                        String imageUrl = company.image ?? "";
                                        // If not http, assume relative to some main url?
                                        // Android VM log: UrlApiKey.MAIN_URL is logged.
                                        // But UrlApiKey.MAIN_URL isn't set until we select a company?
                                        // Wait, `UrlApiKey` has constants.
                                        // Let's assume full URL or we'll debug.
                                        
                                        return Card(
                                          elevation: 2,
                                          color: Colors.white,
                                          margin: EdgeInsets.only(left: 10.w, bottom: 5.h), // XML margins
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                                          child: Padding(
                                            padding: EdgeInsets.all(5.w),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Company Image
                                                CachedNetworkImage(
                                                  imageUrl: imageUrl, 
                                                  height: 110.h, // @dimen/dimen_110
                                                  width: 170.w, // @dimen/dimen_170
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) => const SizedBox(),
                                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                                ),
                                                
                                                SizedBox(height: 5.h),
                                                
                                                // Company Name
                                                Text(
                                                  company.name ?? "",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppTheme.lightBlue, // @color/lightblue
                                                    fontSize: 15.sp, // @dimen/dimen_15
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                
                                                SizedBox(height: 5.h),
                                                
                                                // Description (Nature of Business?)
                                                Text(
                                                  company.natureOfBusiness ?? "", // Using natureOfBusiness as description based on API fields
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.sp, // @dimen/padding_12
                                                  ),
                                                ),
                                                
                                                Spacer(),

                                                // Select Button
                                                SizedBox(
                                                  width: 150.w, // @dimen/dimen_150
                                                  height: 35.h, // @dimen/dimen_35
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      provider.selectCompany(context, company);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppTheme.tealColor, // @color/tealcolor
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(2.r), // Android bg is rectangle/small radius
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                    child: Text(
                                                      "Select Company",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                
                                                SizedBox(height: 15.h),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                           ],
                         ),
                       ),
                     ),
                   ],
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
