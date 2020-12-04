import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  static const String route = '/terms-of-conditions';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: "",
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            TextSpan(
              text: "You don't have the votes!\n",
              style: TextStyle(color: Colors.black.withOpacity(0.8)),
            ),
            TextSpan(
              text: "You're gonna need congressional approval and you don't have the votes!\n",
              style: TextStyle(color: Colors.black.withOpacity(1.0)),
            ),
          ],
        ),
      )
    );
  }

}