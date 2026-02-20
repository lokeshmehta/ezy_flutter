import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/scan_provider.dart';
import '../../../core/constants/app_theme.dart';
import 'widgets/scanner_overlay_widget.dart';
import '../../widgets/custom_loader_widget.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,

  );
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.resumed:
      // Restart the scanner when the app is resumed.
      // Don't start if we are processing a result
        if (!_isProcessing) {
          controller.start();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      // Stop the scanner when the app is paused.
        controller.stop();
        break;
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _isProcessing = true;
    });
    // Stop scanning while processing
    await controller.stop();

    if (!mounted) return;

    final success = await context.read<ScanProvider>().scanProduct(code);

    if (!mounted) return;

    if (success) {
      _showResultDialog(
        title: "Scan Product",
        message: "Scanned Product has been added to Cart.",
        isSuccess: true,
      );
    } else {
      final error = context.read<ScanProvider>().errorMessage ?? "Product not found.";
      _showResultDialog(
        title: "Scan Product",
        message: error,
        isSuccess: false,
      );
    }
  }

  void _showResultDialog({required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                color: isSuccess ? AppTheme.tealColor : AppTheme.redColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _resetScanner();
                      },
                      child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                    )
                  ],
                ),
              ),

              // Body
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Do you want to scan another product?",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _resetScanner();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.tealColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
                          ),
                          child: const Text("Yes"),
                        ),
                        SizedBox(width: 20.w),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context); // Go back to dashboard
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
                          ),
                          child: const Text("No"),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      _isProcessing = false;
    });
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ]
              ),
              child: Row(
                children: [
                  SizedBox(width: 10.w),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 28.sp),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 38.w), // Balance the icon width
                        child: Text(
                          "Scan Product",
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Scanner Body
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: controller,
                        onDetect: _onDetect,
                      ),
                      // Custom Overlay (Green Corners + Red Laser)
                      const ScannerOverlayWidget(),
                      // Loading Overlay
                      Consumer<ScanProvider>(
                        builder: (context, provider, _) {
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
              ),
            ),

          ],
        ),
      ),
    );
  }
}
