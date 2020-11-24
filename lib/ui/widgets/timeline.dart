import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/locator.dart';
import 'package:web/theme.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class EventTimeline extends StatefulWidget {
  final double width;
  final String mediaFolderID;

  const EventTimeline(
      {Key key, this.width, this.mediaFolderID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EventTimelineState();
}

class _TimeLineEventEntry {
  final int timestamp;
  final Widget event;

  _TimeLineEventEntry(this.timestamp, this.event);
}

class _EventTimelineState extends State<EventTimeline> {
  Map<String, TimelineEvent> events;

  @override
  void initState() {
    super.initState();
    events = locator<StorageService>().getEvents();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> eventDisplay = List();
    List<_TimeLineEventEntry> timeLineEvents = List();
    if (events != null) {
      events.forEach((folderId, event) {
        Widget display = TimelineCard(
                width: widget.width,
                event: event,
                folderId: folderId,
                cancelCallback: () async {
                  setState(() {
                    events = locator<StorageService>().getEvents();
                  });
                },
                saveCallback: () async {
                  setState(() {
                    events = locator<StorageService>().getEvents();
                  });
                },
                deleteCallback: () async {
                  StreamController<DialogStreamContent> streamController =
                      new StreamController();
                  locator<DialogService>().popUpDialog(streamController);

                  try {
                    await locator<StorageService>().deleteEvent(folderId);
                  } catch (e) {
                    print(e);
                  } finally {
                    locator<NavigationService>().pop();
                    streamController.close();

                    setState(() {
                      events = locator<StorageService>().getEvents();
                    });
                  }
                });
        _TimeLineEventEntry _timeLineEventEntry = _TimeLineEventEntry(event.mainEvent.timestamp, display);
        timeLineEvents.add(_timeLineEventEntry);
      });
      timeLineEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      timeLineEvents.forEach((element) {
        eventDisplay.add(element.event);
      });
    }

    return Column(
      children: [
        Card(
          child: MaterialButton(
            minWidth: 100,
            height: 40,
            child: Container(
              width: 100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.add, size: 24),
                    Text("add event")
                  ],
                ),
              ),
            ),
            onPressed: () async {
              StreamController<DialogStreamContent> streamController =
              new StreamController();
              locator<DialogService>().popUpDialog(streamController);

              try {
                int timestamp = DateTime.now().millisecondsSinceEpoch;
                streamController
                    .add(DialogStreamContent("Creating event folder", 0));
                await locator<StorageService>()
                    .createEventFolder(widget.mediaFolderID, timestamp, true);

                setState(() {
                  events = locator<StorageService>().getEvents();
                });
              } catch (e) {} finally {
                locator<NavigationService>().pop();
                streamController.close();
              }
            },
          ),
        ),
        SizedBox(height: 20),
        ...eventDisplay,
      ],
    );
  }
}
