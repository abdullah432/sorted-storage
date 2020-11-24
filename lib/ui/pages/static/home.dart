

import 'package:flutter/material.dart';
import 'package:web/app/models/page_content.dart';
import 'package:web/ui/pages/static/donate.dart';
import 'package:web/ui/pages/template/page_template.dart';

class HomePage extends StatelessWidget {
  static const String route = '/home';

  final List<PageContent> content = [
    PageContent(
        title: "About",
        text: "Welcome to SortedStorage.com! this site was created as a means to sort "
            "your cloud storage files in a nice way so that you can share it with friends and family."
            "SortedStorage.com was built with two things in mind: keeping your privacy, being open source, and being free",
        imageUri: "assets/images/google.png"),
    PageContent(
        title: "Privacy",
        text: "SortedStorage.com simply acts as a middleman between you and "
            "your cloud storage provider. We cannot see and do not store any account information or anything "
            "you upload, this is between you and your cloud storage provider. "
            "Don't believe me? good as .. said 'trust is earned', therefore, this project is open source, "
            "anyone can see exactly what happens under the hood",
        imageUri: "assets/images/privacy.png"),
    PageContent(
        title: "Open Source",
        text: "If you are a developer or just curious about the code please visit https://github.com/Jsuppers."
            "There are still many features this project wants to acheive, so if you are a developer please consider "
            "contributing. Or if you want to simply support this project consider donating!",
        imageUri: "assets/images/Octocat.png", callToActionButtonRoute: "", callToActionButtonText: "Github"),
    PageContent(
        title: "Free",
        text: "Welcome to SortedStorage.com! this site was created as a means to sort "
            "your cloud storage files in a nice way so that you can share it with friends and family."
            "SortedStorage.com was built with two things in mind: privacy and free",
        imageUri: "assets/images/free.png",
        callToActionButtonRoute: DonatePage.route, callToActionButtonText: "Donate")
  ];


  @override
  Widget build(BuildContext context) {
    return PageTemplate(content);
  }
}
