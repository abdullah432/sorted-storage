import 'package:flutter/material.dart';
import 'package:web/app/models/page_content.dart';
import 'package:web/ui/pages/template/page_template.dart';

class ErrorPage extends StatelessWidget {
  static const String route = '/error';

  final List<PageContent> content = [
    PageContent(
        title: "Something went wrong",
        text: "please try again",
        imageUri: "assets/images/error.png")
  ];

  @override
  Widget build(BuildContext context) {
    return PageTemplate(content);
  }
}
