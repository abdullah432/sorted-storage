
import 'package:flutter/material.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/locator.dart';
import 'package:web/ui/pages/static/privacy_policy.dart';
import 'package:web/ui/pages/static/terms_of_conditions.dart';

class Footer extends StatelessWidget {
  final double width;
  const Footer({@required this.width});

  @override
  Widget build(BuildContext context) {

    List<Widget> spacer =  [
    SizedBox(width: 5),
        Text("-"),
    SizedBox(width: 5)];

    List<Widget> children = [
      MaterialButton(
        onPressed: () {
          locator<NavigationService>().navigateTo(PolicyPage.route);
        },
        child: Text('Privacy Policy',
            style: Theme.of(context).textTheme.bodyText1),
      ),
      ...spacer,
      MaterialButton(

        onPressed: () {
          locator<NavigationService>().navigateTo(TermsPage.route);
        },
        child: Text('Terms of Conditions',
            style: Theme.of(context).textTheme.bodyText1),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        width: width,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}