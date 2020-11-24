import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  static const String route = '/account';

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Text("profile"),
      ],
    );
  }
}