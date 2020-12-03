import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/event/event_bloc.dart';
import 'package:web/app/blocs/event/event_event.dart';
import 'package:web/app/blocs/images/images_bloc.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/event_comments.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_event_card.dart';

class TimelineEvent {
  bool locked;
  EventContent mainEvent;
  List<EventContent> subEvents;

  TimelineEvent({this.mainEvent, this.subEvents, this.locked = true});

  static TimelineEvent clone(TimelineEvent timelineEvent) {
    return TimelineEvent(
        locked: timelineEvent.locked,
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
      this.title = '',
      this.images,
      this.description = '',
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
  final Function deleteCallback;
  final bool viewMode;

  const TimelineCard(
      {Key key,
      @required this.width,
      this.height,
      @required this.event,
      this.folderId,
      this.deleteCallback,
      this.viewMode = false})
      : super(key: key);

  @override
  _TimelineCardState createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard> {
  Widget createHeader(double width, BuildContext context, TimelineEvent event) {
    return Container(
      height: 30,
      padding: EdgeInsets.zero,
      alignment: Alignment.centerRight,
      child: event.locked
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ButtonWithIcon(
                    text: "share",
                    icon: Icons.share,
                    onPressed: () {
                      DialogService.shareDialog(context, widget.folderId);
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
                SizedBox(width: 10),
                ButtonWithIcon(
                    text: "edit",
                    icon: Icons.edit,
                    onPressed: () {
                      BlocProvider.of<EventBloc>(context).add(EditEventEvent());
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ButtonWithIcon(
                    text: "cancel",
                    icon: Icons.cancel,
                    onPressed: () {
                      BlocProvider.of<EventBloc>(context)
                          .add(CancelEventEvent());
                    },
                    width: width,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black),
                SizedBox(width: 10),
                ButtonWithIcon(
                    text: "delete",
                    icon: Icons.delete,
                    onPressed: () {
                      widget.deleteCallback();
                    },
                    width: width,
                    backgroundColor: Colors.redAccent),
                SizedBox(width: 10),
                ButtonWithIcon(
                    text: "save",
                    icon: Icons.save,
                    onPressed: () async {
                      BlocProvider.of<EventBloc>(context).add(SaveEventEvent());
                    },
                    width: width,
                    backgroundColor: Colors.greenAccent),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => EventBloc(
            BlocProvider.of<DriveBloc>(context).state, widget.event,
            viewMode: widget.viewMode, eventID: widget.folderId))
      ],
      child: BlocBuilder<EventBloc, TimelineEvent>(
        builder: (context, event) {
          if (event == null) {
            return FullPageLoadingLogo();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Card(
              child: Column(
                children: [
                  EventCard(
                    controls: widget.viewMode
                        ? Container()
                        : createHeader(widget.width, context, event),
                    width: widget.width,
                    height: widget.height,
                    event: event.mainEvent,
                    locked: event.locked,
                  ),
                  Visibility(
                    visible: !event.locked,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 40,
                        width: 140,
                        child: ButtonWithIcon(
                            text: "add sub-event",
                            icon: Icons.add,
                            onPressed: () async {
                              BlocProvider.of<EventBloc>(context)
                                  .add(EventCreateSubEventEvent());
                            },
                            width: Constants.SMALL_WIDTH,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            iconColor: Colors.black),
                      ),
                    ),
                  ),
                  ...List.generate(event.subEvents.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                          child: EventCard(
                        controls: Visibility(
                            child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(right: 3, top: 3),
                                  child: Container(
                                    height: 34,
                                    width: 34,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(40))),
                                    child: IconButton(
                                      iconSize: 18,
                                      splashRadius: 18,
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        BlocProvider.of<EventBloc>(context)
                                            .add(DeleteSubEventEvent(index));
                                      },
                                    ),
                                  ),
                                )),
                            visible: !event.locked),
                        width: widget.width,
                        height: widget.height,
                        event: event.subEvents[index],
                        locked: event.locked,
                      )),
                    );
                  }),
                  CommentWidget(
                    width: widget.width,
                    height: widget.height,
                    comments: event.mainEvent.comments,
                    sendComment: (String comment) async {
                      User currentUser =
                          BlocProvider.of<AuthenticationBloc>(context).state;
                      String user = "";
                      if (currentUser != null) {
                        user = currentUser.displayName;
                        if (user == null || user == "") {
                          user = currentUser.email;
                        }
                      }

                      EventComment eventComment =
                          EventComment(comment: comment, user: user);
                      BlocProvider.of<EventBloc>(context).add(CommentEventEvent(
                          event, eventComment, event.mainEvent.folderID));
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TimelineHeader extends StatefulWidget {
  @override
  _TimelineHeaderState createState() => _TimelineHeaderState();
}

class _TimelineHeaderState extends State<TimelineHeader> {
  @override
  Widget build(BuildContext context) {
    return Container();
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

  const ButtonWithIcon(
      {Key key,
      this.text,
      this.icon,
      this.onPressed,
      this.iconColor = Colors.white,
      this.backgroundColor,
      this.textColor = Colors.white,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buttonWithIcon(this.text, this.icon, this.onPressed, this.iconColor,
        this.backgroundColor, this.textColor, this.width);
  }

  Widget buttonWithIcon(String text, IconData icon, Function onPressed,
      Color iconColor, Color backgroundColor, Color textColor, double width) {
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
