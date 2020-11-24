import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/locator.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_card.dart';
import 'package:web/ui/widgets/timeline_event_card.dart';

class ViewPage extends StatefulWidget {
  static const String route = '/view';
  final String path;

  const ViewPage({Key key, this.path}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  String event;

  @override
  void initState() {
    super.initState();

    if (widget.path.length < ViewPage.route.length + 1) {
      event = null;
    } else {
      event = widget.path.substring(ViewPage.route.length + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Container();
    }
    return FutureBuilder(
        future: locator<StorageService>().getViewEvent(event),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong ${snapshot.error}'));
          }
          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            TimelineEvent timelineEvent = snapshot.data;
            return ResponsiveBuilder(builder: (context, sizingInformation) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: TimelineCard(
                    viewMode: true,
                    width: sizingInformation.screenSize.width,
                    event: timelineEvent,
                    folderId: event,
                    cancelCallback: () async {},
                    saveCallback: () async {},
                    deleteCallback: () async {}),
              );
            });
          }
          return ResponsiveBuilder(builder: (context, sizingInformation) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: sizingInformation.screenSize.width,
                height: sizingInformation.screenSize.height,
                child: FullPageLoadingLogo(),
              ),
            );
          });
        });
  }
}
