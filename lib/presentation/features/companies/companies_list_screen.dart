import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/companies_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/assets.dart';
import '../../../core/constants/url_api_key.dart';


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
                                   top: 5,
                                   left: 5,
                                   right: 5,
                                 ),
                                 elevation: 5,
                                 color: Colors.white,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                 child: Container(
                                   width: double.infinity,
                                   height: 55, // @dimen/dimen_55
                                   padding: EdgeInsets.symmetric(vertical: 10),
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
                                         top: 15, 
                                         bottom: 15, 
                                         right: 10 
                                       ), 
                                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                         crossAxisCount: 2,
                                         childAspectRatio: 0.60, // Further decreased for safety against overflow
                                         mainAxisSpacing: 10,
                                         crossAxisSpacing: 10,
                                       ),
                                       itemCount: provider.companies.length,
                                       itemBuilder: (context, index) {
                                         final company = provider.companies[index];
                                         
                                         String imageUrl = company.image ?? "";
                                         if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                                           imageUrl = UrlApiKey.companyMainUrl + imageUrl;
                                         }
                                         
                                         return Card(
                                           elevation: 2,
                                           color: Colors.white,
                                           margin: EdgeInsets.only(left: 10, bottom: 5), 
                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                           child: Padding(
                                             padding: EdgeInsets.all(5),
                                             child: Column(
                                               mainAxisSize: MainAxisSize.min,
                                               mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                                               children: [
                                                 // Company Image
                                                 CachedNetworkImage(
                                                   imageUrl: imageUrl, 
                                                   height: 110, // @dimen/dimen_110
                                                   width: 170, // @dimen/dimen_170
                                                   fit: BoxFit.contain,
                                                   placeholder: (context, url) => const SizedBox(),
                                                   errorWidget: (context, url, error) => const Icon(Icons.error),
                                                 ),
                                                 
                                                 SizedBox(height: 5),
                                                 
                                                 // Company Name
                                                 Text(
                                                   company.name ?? "",
                                                   textAlign: TextAlign.center,
                                                   maxLines: 2,
                                                   overflow: TextOverflow.ellipsis,
                                                   style: TextStyle(
                                                     color: AppTheme.lightBlue, 
                                                     fontSize: 15, 
                                                     fontWeight: FontWeight.bold,
                                                   ),
                                                 ),
                                                 
                                                 SizedBox(height: 5),
                                                 
                                                 // Description
                                                 Text(
                                                   company.natureOfBusiness ?? "", 
                                                   textAlign: TextAlign.center,
                                                   maxLines: 2,
                                                   overflow: TextOverflow.ellipsis,
                                                   style: TextStyle(
                                                     color: Colors.black,
                                                     fontSize: 12, 
                                                   ),
                                                 ),
                                                 
                                                 SizedBox(height: 10),

                                                 // Select Button
                                                 SizedBox(
                                                   width: 150, 
                                                   height: 35, 
                                                   child: ElevatedButton(
                                                     onPressed: () {
                                                       provider.selectCompany(context, company);
                                                     },
                                                     style: ElevatedButton.styleFrom(
                                                       backgroundColor: AppTheme.tealColor, 
                                                       shape: RoundedRectangleBorder(
                                                         borderRadius: BorderRadius.circular(20), // Round corners (Pill)
                                                       ),
                                                       padding: EdgeInsets.zero,
                                                     ),
                                                     child: Text(
                                                       "Select Company",
                                                       style: TextStyle(
                                                         color: Colors.white,
                                                         fontSize: 14,
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                                 
                                                 SizedBox(height: 5), // Bottom padding
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
