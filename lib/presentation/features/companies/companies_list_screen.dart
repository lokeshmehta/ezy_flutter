import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/companies_provider.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/assets.dart';
import '../../../core/constants/url_api_key.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/custom_loader_widget.dart';


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
                                 elevation: 1,
                                 color: Colors.white,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                 child: Container(
                                   width: double.infinity,
                                   height: 70, // Increased size
                                   padding: EdgeInsets.symmetric(vertical: 0),
                                   alignment: Alignment.center,
                                   child: Image.asset(
                                     AppAssets.appLogo, 
                                     fit: BoxFit.contain,
                                   ),
                                 ),
                               ),

                                // GridView
                               Expanded(
                                 child: Stack(
                                   children: [
                                     Consumer<CompaniesProvider>(
                                       builder: (context, provider, child) {
                                         // Moved isLoading check to Overlay
                                         
                                         if (provider.errorMsg != null) {
                                           return Center(child: Text(provider.errorMsg!));
                                         }

                                         return GridView.builder(
                                           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                             crossAxisCount: 2,
                                             childAspectRatio: 0.65,
                                             mainAxisSpacing: 10,
                                             crossAxisSpacing: 8, 
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
                                               margin: const EdgeInsets.only(bottom: 10), 
                                               shape: RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.circular(4),
                                               ),
                                               child: Padding(
                                                 padding: const EdgeInsets.all(8),
                                                 child: Column(
                                                   mainAxisSize: MainAxisSize.max, 
                                                   mainAxisAlignment: MainAxisAlignment.start, 
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

                                                     const Spacer(), 

                                                     SizedBox(
                                                       width: 160, 
                                                       height: 35,
                                                       child: ElevatedButton(
                                                         onPressed: () {
                                                           provider.selectCompany(context, company);
                                                         },
                                                         style: ElevatedButton.styleFrom(
                                                           backgroundColor: AppTheme.tealColor,
                                                           padding: EdgeInsets.zero, 
                                                           shape: RoundedRectangleBorder(
                                                             borderRadius: BorderRadius.circular(20),
                                                           ),
                                                         ),
                                                         child: const FittedBox( 
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
                                     Consumer<CompaniesProvider>(
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
