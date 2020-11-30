import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/bloc/navigation/navigation_bloc.dart';
import 'package:web/locator.dart';
import 'package:web/route.dart';
import 'package:web/theme.dart';
import 'package:web/ui/pages/static/home.dart';
import 'package:web/ui/widgets/loading.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NavigationBloc _bloc;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _bloc = NavigationBloc(navigatorKey: _navigatorKey);
//    _content = _getContentForState(_bloc.state);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: locator<AuthenticationService>().silentSignIn(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder(
              stream: locator<AuthenticationService>().onUserChange(),
              builder: (context, snapshot) {
                return BlocProvider<NavigationBloc>(
                  create: (BuildContext context) => _bloc,
                  child: MaterialApp(
                    title: 'Sorted Storage',
                    theme: myThemeData,
                    navigatorKey: _navigatorKey,
                    onGenerateRoute: RouteConfiguration.onGenerateRoute,
                    initialRoute: HomePage.route,
                  ),
                );
              });
        }

        return FullPageLoadingLogo();
      },
    );
  }
}
//
//class MainContainerWidget extends StatefulWidget {
//  @override
//  _MainAppContainerState createState() => _MainAppContainerState();
//}
//
//class _MainAppContainerState extends State<MainContainerWidget> {
//  NavigationBloc _bloc;
//  Widget _content;
//
//  @override
//  void initState() {
//    super.initState();
//    _bloc = NavigationBloc();
//    _content = _getContentForState(_bloc.state);
//  }
//
//  Widget _getContentForState(NavigationState state) {
//    switch (state.selectedItem) {
//      case NavigationItem.home_page:
//        return Text("1");
//      case NavigationItem.documents_page:
//        return Text("2");
//      case NavigationItem.login_page:
//        return Text("3");
//      case NavigationItem.media_page:
//        return Text("4");
//      default:
//        return Text("default");
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) => BlocBuilder<NavigationBloc, NavigationState>(
//    builder: (BuildContext context, NavigationState state) {
//      _content = _getContentForState(state);
//
//      return Scaffold(
//        drawer: NavDrawerWidget("Joe Shmoe", "shmoe@joesemail.com"),
//        body: AnimatedSwitcher(
//          switchInCurve: Curves.easeInExpo,
//          switchOutCurve: Curves.easeOutExpo,
//          duration: Duration(milliseconds: 300),
//          child: _content,
//        ),
//      );
//    }
//  );
//
//  @override
//  void dispose() {
//    super.dispose();
//    _bloc.close();
//  }
//}
//
//class NavDrawerWidget extends StatelessWidget {
//  final String accountName;
//  final String accountEmail;
//  final List<_NavigationItem> _listItems = [
//    _NavigationItem(true, null, null, null),
//    _NavigationItem(
//        false, NavigationItem.home_page, "First Page", Icons.looks_one),
//    _NavigationItem(
//        false, NavigationItem.documents_page, "Second Page", Icons.looks_two),
//  ];
//
//  NavDrawerWidget(this.accountName, this.accountEmail);
//
//  @override
//  Widget build(BuildContext context) => Drawer(
//          // Add a ListView to the drawer. This ensures the user can scroll
//          // through the options in the drawer if there isn't enough vertical
//          // space to fit everything.
//          child: Container(
//        color: Colors.grey,
//        child: ListView.builder(
//            padding: EdgeInsets.zero,
//            itemCount: _listItems.length,
//            itemBuilder: (BuildContext context, int index) =>
//                BlocBuilder<NavigationBloc, NavigationState>(
//                  builder: (BuildContext context, NavigationState state) =>
//                      _buildItem(_listItems[index], state),
//                )),
//      ));
//
//  Widget _buildItem(_NavigationItem data, NavigationState state) => data.header
//      // if the item is a header return the header widget
//      ? _makeHeaderItem()
//      // otherwise build and return the default list item
//      : _makeListItem(data, state);
//
//  Widget _makeHeaderItem() => UserAccountsDrawerHeader(
//        accountName: Text(accountName, style: TextStyle(color: Colors.white)),
//        accountEmail: Text(accountEmail, style: TextStyle(color: Colors.white)),
//        decoration: BoxDecoration(color: Colors.blueGrey),
//        currentAccountPicture: CircleAvatar(
//          backgroundColor: Colors.white,
//          foregroundColor: Colors.amber,
//          child: Icon(
//            Icons.person,
//            size: 54,
//          ),
//        ),
//      );
//
//  Widget _makeListItem(_NavigationItem data, NavigationState state) => Card(
//        color: data.item == state.selectedItem ? Colors.blue : Colors.grey,
//        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
//        // So we see the selected highlight
//        borderOnForeground: true,
//        elevation: 0,
//        margin: EdgeInsets.zero,
//        child: Builder(
//          builder: (BuildContext context) => ListTile(
//            title: Text(
//              data.title,
//              style: TextStyle(
//                color: data.item == state.selectedItem
//                    ? Colors.blue
//                    : Colors.blueGrey,
//              ),
//            ),
//            leading: Icon(
//              data.icon,
//              // if it's selected change the color
//              color: data.item == state.selectedItem
//                  ? Colors.blue
//                  : Colors.blueGrey,
//            ),
//            onTap: () => _handleItemClick(context, data.item),
//          ),
//        ),
//      );
//
//  void _handleItemClick(BuildContext context, NavigationItem item) {
//    BlocProvider.of<NavigationBloc>(context).add(NavigateTo(item));
//    Navigator.pop(context);
//  }
//}
//
//// helper class used to represent navigation list items
//class _NavigationItem {
//  final bool header;
//  final NavigationItem item;
//  final String title;
//  final IconData icon;
//
//  _NavigationItem(this.header, this.item, this.title, this.icon);
//}
