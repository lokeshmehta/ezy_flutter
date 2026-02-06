import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/parser.dart';

// Note: flutter_html is good for parsing HTML links in answers. 
// If not available, use simple parsing or text. 
// Android uses Html.fromHtml and updates movement method.
// I'll stick to simple parsing for now to minimize dependencies if not added, 
// using generic text if complex html control is needed I might need another package.
// Actually flutter_html is not in pubspec by default usually?
// I'll check pubspec.yaml if I can. For now, I will use text and basic parsing.

class FAQDetailItemWidget extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const FAQDetailItemWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  String _parseHtmlString(String htmlString) {
    if (htmlString.isEmpty) return "";
    final document = parse(htmlString);
    return document.body?.text ?? htmlString;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _parseHtmlString(question),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (isExpanded) ...[
                SizedBox(height: 10.h),
                Divider(color: Colors.grey[300], thickness: 1),
                SizedBox(height: 10.h),
                // Using selection area/text span logic if needed
                // For now just text.
                Text(
                  _parseHtmlString(answer),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
