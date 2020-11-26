import 'dart:async';
import 'dart:typed_data';

import 'package:web/app/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/navigation_service.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/constants.dart';
import 'package:web/locator.dart';
import 'package:web/ui/widgets/event_comments.dart';
import 'package:web/ui/widgets/timeline_event_card.dart';

class TimelineEvent {
  EventContent mainEvent;
  List<EventContent> subEvents;

  TimelineEvent({this.mainEvent, this.subEvents});

  static TimelineEvent clone(TimelineEvent timelineEvent) {
    return TimelineEvent(
        mainEvent: EventContent.clone(timelineEvent.mainEvent),
        subEvents: List.generate(timelineEvent.subEvents.length,
            (index) => EventContent.clone(timelineEvent.subEvents[index])));
  }
}

class EventImage {
  String imageURL;
  Uint8List bytes;

  EventImage({this.imageURL, this.bytes});
}

class SubEvent {
  final String id;
  final int timestamp;

  SubEvent(this.id, this.timestamp);
}

class EventContent {
  int timestamp;
  String title;
  Map<String, EventImage> images;
  String description;
  String folderID;
  String settingsID;
  String commentsID;
  String permissionID;
  EventComments comments;
  List<SubEvent> subEvents;

  EventContent(
      {this.timestamp,
      this.title,
      this.images,
      this.description,
      this.folderID,
      this.settingsID,
      this.subEvents,
      this.commentsID,
      this.comments});

  EventContent.clone(EventContent event)
      : this(
            timestamp: event.timestamp,
            title: event.title,
            images: Map.from(event.images),
            description: event.description,
            settingsID: event.settingsID,
            commentsID: event.commentsID,
            folderID: event.folderID,
            subEvents: List.from(event.subEvents),
            comments: EventComments.clone(event.comments));
}

class TimelineCard extends StatefulWidget {
  final double width;
  final double height;
  final TimelineEvent event;
  final String folderId;
  final Function cancelCallback;
  final Function deleteCallback;
  final Function saveCallback;
  final bool viewMode;

  const TimelineCard(
      {Key key,
      @required this.width,
      this.height,
      @required this.event,
      this.folderId,
      this.deleteCallback,
      this.saveCallback,
      this.cancelCallback,
      this.viewMode = false})
      : super(key: key);

  @override
  _TimelineCardState createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard> {
  bool visible = true;
  bool locked = true;
  TimelineEvent cloudCopy;
  TimelineEvent localCopy;

  @override
  void initState() {
    super.initState();
    cloudCopy = widget.event;
    localCopy = TimelineEvent.clone(widget.event);
  }

  Widget createHeader(double width) {
    return Container(
      height: 30,
      padding: EdgeInsets.zero,
      alignment: Alignment.centerRight,
      child: locked
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ButtonWithIcon(text: "share", icon: Icons.share, onPressed: () {
                  setState(() {
                    locator<DialogService>().shareDialog(widget.folderId);
                  });
                }, width: width, backgroundColor: Colors.white, textColor: Colors.black, iconColor: Colors.black),
                SizedBox(width: 10),
                ButtonWithIcon(text: "edit",  icon: Icons.edit, onPressed: () {
                  setState(() {
                    locked = !locked;
                  });
                }, width: width, backgroundColor: Colors.white, textColor: Colors.black, iconColor: Colors.black),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ButtonWithIcon(text: "cancel", icon: Icons.cancel, onPressed: () {
                  localCopy = TimelineEvent.clone(cloudCopy);
                  locked = !locked;
                  widget.cancelCallback();
                }, width: width, backgroundColor: Colors.white, textColor: Colors.black, iconColor: Colors.black),
                SizedBox(width: 10),
                ButtonWithIcon(text:"delete", icon:Icons.delete, onPressed: () {
                    widget.deleteCallback();
                  }, width: width, backgroundColor: Colors.redAccent),
                SizedBox(width: 10),
                ButtonWithIcon(text:"save", icon: Icons.save, onPressed: () async {
                  StreamController<DialogStreamContent> streamTextController =
                  new StreamController();
                  locator<DialogService>().popUpDialog(streamTextController);

                  Future.delayed(new Duration(milliseconds: 500), () async {
                    bool callParentRebuild = false;
                    if (localCopy.mainEvent.timestamp !=
                        cloudCopy.mainEvent.timestamp) {
                      callParentRebuild = true;
                    }

                    for (EventContent subEvent in localCopy.subEvents) {
                      EventContent cloudSubEvent = cloudCopy.subEvents
                          .singleWhere((element) =>
                      element.folderID == subEvent.folderID);
                      await locator<StorageService>().syncDrive(
                          streamTextController, subEvent, cloudSubEvent);
                    }

                    List<EventContent> eventsToDelete = List();
                    for (EventContent subEvent in cloudCopy.subEvents) {
                      EventContent localEvent;
                      for (int i = 0; i < localCopy.subEvents.length; i++) {
                        if (subEvent.folderID ==
                            localCopy.subEvents[i].folderID) {
                          localEvent = localCopy.subEvents[i];
                          break;
                        }
                      }
                      if (localEvent == null) {
                        await locator<StorageService>()
                            .deleteEvent(subEvent.folderID);
                        callParentRebuild = true;
                        eventsToDelete.add(subEvent);
                      }
                    }

                    for (EventContent subEvent in eventsToDelete) {
                      cloudCopy.subEvents.remove(subEvent);
                    }

                    locator<StorageService>()
                        .syncDrive(streamTextController,
                        localCopy.mainEvent, cloudCopy.mainEvent)
                        .then((value) {
                      localCopy = TimelineEvent.clone(cloudCopy);
                      print(localCopy.mainEvent.images);
                      locator<NavigationService>().pop(); //pop dialog
                      streamTextController.close();
                      locator<StorageService>()
                          .updateEvent(widget.folderId, cloudCopy);

                      if (callParentRebuild) {
                        print(' save calllie back');
                        widget.saveCallback();
                      } else {
                        setState(() {
                          locked = !locked;
                        });
                      }
                    }); //pop dialog
                  });
                }, width: width, backgroundColor: Colors.greenAccent),
              ],
            ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        child: Column(
          children: [
            EventCard(
              controls:
                  widget.viewMode ? Container() : createHeader(widget.width),
              width: widget.width,
              height: widget.height,
              event: localCopy.mainEvent,
              locked: locked,
            ),
            Visibility(
              visible: !locked,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 40,
                  width: 140,
                  child: ButtonWithIcon(text: "add sub-event", icon: Icons.add,
                    onPressed: () async {
                      StreamController<DialogStreamContent> streamController =
                          new StreamController();
                      streamController.add(
                          DialogStreamContent("Connecting to Google Drive", 0));
                      locator<DialogService>().popUpDialog(streamController);

                      try {
                        EventContent event = await locator<StorageService>()
                            .createEventFolder(localCopy.mainEvent.folderID,
                                localCopy.mainEvent.timestamp, false);

                        setState(() {
                          localCopy.subEvents.add(event);
                          cloudCopy.subEvents.add(EventContent.clone(event));
                        });
                      } catch (e) {
                        print(e);
                      } finally {
                        streamController.close();
                        locator<NavigationService>().pop();
                      }
                    }, width: Constants.SMALL_WIDTH, backgroundColor: Colors.white, textColor: Colors.black, iconColor: Colors.black),
                ),
              ),
            ),
            ...List.generate(localCopy.subEvents.length, (index) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                    child: EventCard(
                  controls: Visibility(
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 3, top: 3),
                            child: Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40))),
                              child: IconButton(
                                iconSize: 18,
                                splashRadius: 18,
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    localCopy.subEvents.removeAt(index);
                                    //widget.event.images.remove(imageKey);
                                  });
                                },
                              ),
                            ),
                          )),
                      visible: !locked),
                  width: widget.width,
                  height: widget.height,
                  event: localCopy.subEvents[index],
                  locked: locked,
                )),
              );
            }),
            CommentWidget(
              width: widget.width,
              height: widget.height,
              comments: widget.event.mainEvent.comments,
              sendComment: (String comment) async {
              StreamController<DialogStreamContent> streamController = new StreamController();
              locator<DialogService>().popUpDialog(streamController);
              streamController.add(DialogStreamContent("sending comment", 0));
              try {
                User currentUser = locator<AuthenticationService>().getCurrentUser();
                if (currentUser == null) {
                  await locator<AuthenticationService>().signIn(null);
                  await locator<StorageService>().initialize();
                  currentUser = locator<AuthenticationService>().getCurrentUser();
                }

                String user = "";
                if (currentUser != null) {
                  user = currentUser.displayName;
                  if (user == null || user == "") {
                    user = currentUser.email;
                  }
                }

                EventComment eventComment = EventComment(comment: comment, user: user);
                await locator<StorageService>().sendComment(widget.event.mainEvent, eventComment);
                setState(() {
                  widget.event.mainEvent;
                });
              } catch (e) {
                print('error: $e');
                return null;
              } finally {
                locator<NavigationService>().pop();
                streamController.close();
              }
            },)
          ],
        ),
      ),
    );
  }
}


class ButtonWithIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onPressed;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final double width;

  const ButtonWithIcon({Key key,
    this.text, this.icon, this.onPressed,
    this.iconColor = Colors.white,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.width}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return buttonWithIcon(this.text,
        this.icon,
        this.onPressed,
        this.iconColor,
        this.backgroundColor,
        this.textColor,
        this.width);
  }

  Widget buttonWithIcon(String text, IconData icon, Function onPressed,
      Color iconColor, Color backgroundColor,
        Color textColor, double width) {
    return MaterialButton(
        minWidth: width >= Constants.SMALL_WIDTH ? 100 : 30,
        child: width >= Constants.SMALL_WIDTH
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'Roboto',
                color: textColor,
              ),
            ),
          ],
        )
            : Icon(
          icon,
          color: iconColor,
        ),
        color: backgroundColor,
        textColor: textColor,
        onPressed: onPressed);
  }
}

