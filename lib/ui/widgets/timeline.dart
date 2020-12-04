import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/add_adventure/add_adventure_bloc.dart';
import 'package:web/app/blocs/add_adventure/add_adventure_event.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/update_adventure/update_adventure_bloc.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class _TimeLineEventEntry {
  final int timestamp;
  final Widget event;

  _TimeLineEventEntry(this.timestamp, this.event);
}

class TimelineLayout extends StatefulWidget {
  final double width;
  final double height;

  const TimelineLayout({Key key, this.width, this.height}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimelineLayoutState();
}

class _TimelineLayoutState extends State<TimelineLayout> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<AddAdventureBloc>(context).add(AddAdventureDoneEvent());
    List<Widget> eventDisplay = List();
    List<_TimeLineEventEntry> timeLineEvents = List();
    Map<String, TimelineData> _timelineData =
        BlocProvider.of<TimelineBloc>(context).state;
    _timelineData.forEach((folderId, event) {
      Widget display = BlocProvider<UpdateAdventureBloc>(
        create: (BuildContext context) => UpdateAdventureBloc(),
        child: TimelineCard(
          width: widget.width,
          height: widget.height,
          event: event,
          folderId: folderId,
          deleteCallback: () async {
            BlocProvider.of<TimelineBloc>(context)
                .add(TimelineDeleteAdventureEvent(folderId: folderId));
          },
        ),
      );
      _TimeLineEventEntry _timeLineEventEntry =
          _TimeLineEventEntry(event.mainEvent.timestamp, display);
      timeLineEvents.add(_timeLineEventEntry);
    });
    timeLineEvents.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    timeLineEvents.forEach((element) {
      eventDisplay.add(element.event);
    });

    return Column(
      key: Key(_timelineData.length.toString()),
      children: [
        BlocBuilder<AddAdventureBloc, bool>(builder: (context, adding) {
          if (adding) {
            return StaticLoadingLogo();
          }
          return Container(
            width: 150,
            child: ButtonWithIcon(
              icon: Icons.add,
              text: "add event",
              width: Constants.SMALL_WIDTH,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              iconColor: Colors.black,
              onPressed: () async {
                BlocProvider.of<AddAdventureBloc>(context)
                    .add(AddAdventureNewEvent());
                int timestamp = DateTime.now().millisecondsSinceEpoch;
                BlocProvider.of<TimelineBloc>(context).add(
                    TimelineCreateAdventureEvent(
                        timestamp: timestamp, mainEvent: true));
              },
            ),
          );
        }),
        SizedBox(height: 20),
        ...eventDisplay,
      ],
    );
  }
}
