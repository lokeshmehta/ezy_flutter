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
                                         childAspectRatio: 0.70, // Further decreased for safety against overflow
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
                                           margin: const EdgeInsets.only(left: 10, bottom: 5),
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(4),
                                           ),
                                           child: Padding(
                                             padding: const EdgeInsets.all(8),
                                             child: Column(
                                               mainAxisSize: MainAxisSize.max, // 🔥 IMPORTANT
                                               mainAxisAlignment: MainAxisAlignment.start, // 🔥 IMPORTANT
                                               children: [
                                                 // Company Image
                                                 CachedNetworkImage(
                                                   imageUrl: imageUrl,
                                                   height: 110,
                                                   width: double.infinity,
                                                   fit: BoxFit.contain,
                                                   placeholder: (context, url) => const SizedBox(),
                                                   errorWidget: (context, url, error) => const Icon(Icons.error),
                                                 ),

                                                 const SizedBox(height: 6),

                                                 // Company Name
                                                 Text(
                                                   company.name ?? "",
                                                   textAlign: TextAlign.center,
                                                   maxLines: 2,
                                                   overflow: TextOverflow.ellipsis,
                                                   style: const TextStyle(
                                                     color: AppTheme.lightBlue,
                                                     fontSize: 15,
                                                     fontWeight: FontWeight.bold,
                                                   ),
                                                 ),

                                                 const SizedBox(height: 4),

                                                 // Description
                                                 Text(
                                                   company.natureOfBusiness ?? "",
                                                   textAlign: TextAlign.center,
                                                   maxLines: 2,
                                                   overflow: TextOverflow.ellipsis,
                                                   style: const TextStyle(
                                                     color: Colors.black,
                                                     fontSize: 12,
                                                   ),
                                                 ),

                                                 const Spacer(), // 🔥 PUSHES BUTTON TO BOTTOM

                                                 SizedBox(
                                                   width: 160, // ⬅️ slightly wider
                                                   height: 35,
                                                   child: ElevatedButton(
                                                     onPressed: () {
                                                       provider.selectCompany(context, company);
                                                     },
                                                     style: ElevatedButton.styleFrom(
                                                       backgroundColor: AppTheme.tealColor,
                                                       padding: EdgeInsets.zero, // 🔥 IMPORTANT
                                                       shape: RoundedRectangleBorder(
                                                         borderRadius: BorderRadius.circular(20),
                                                       ),
                                                     ),
                                                     child: const FittedBox( // 🔥 GUARANTEES ONE LINE
                                                       fit: BoxFit.scaleDown,
                                                       child: Text(
                                                         "Select Company",
                                                         maxLines: 1,
                                                         softWrap: false,
                                                         overflow: TextOverflow.visible,
                                                         style: TextStyle(
                                                           color: Colors.white,
                                                           fontSize: 14,
                                                           fontWeight: FontWeight.w500,
                                                         ),
                                                       ),
                                                     ),
                                                   ),
                                                 ),

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
