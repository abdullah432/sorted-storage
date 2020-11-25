import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/locator.dart';
import 'package:web/ui/widgets/timeline.dart';

class MediaPage extends StatefulWidget {
  static const String route = '/media';

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  Widget build(BuildContext context) {
    StreamController<DialogStreamContent> connectingStreamController = new StreamController();
    StreamController<DialogStreamContent> mediaStreamController = new StreamController();

    return FutureBuilder(
        future: locator<StorageService>().getMediaFolder(connectingStreamController),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            var mediaFolderId = snapshot.data;

            return FutureBuilder(
                future: locator<StorageService>().getEventsFromFolder(mediaFolderId,
                    mediaStreamController),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return EventTimeline(
                                  mediaFolderID: mediaFolderId,
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight);
                        },
                      ),
                    );
                  } else {
                    return locator<DialogService>().simpleDialog(mediaStreamController);
                  }
                });
          } else {
            return locator<DialogService>().simpleDialog(connectingStreamController);
          }
        });
  }
}
