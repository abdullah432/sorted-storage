import 'package:flutter/material.dart';
import 'package:web/app/models/page_content.dart';
import 'package:web/ui/pages/template/page_template.dart';

class DonatePage extends StatelessWidget {
  static const String route = '/donate';

  final List<PageContent> content = [
    PageContent(
        title: "Donate",
        text: "This is a donation page",
        imageUri: "assets/images/donate.png")
  ];

  @override
  Widget build(BuildContext context) {
    return PageTemplate(content);
  }
}
