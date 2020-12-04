import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
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
    List<Widget> eventDisplay = List();
    List<_TimeLineEventEntry> timeLineEvents = List();
    Map<String, TimelineData> _timelineData = BlocProvider.of<TimelineBloc>(context).state;
    _timelineData.forEach((folderId, event) {
      Widget display = TimelineCard(
          width: widget.width,
          height: widget.height,
          event: event,
          folderId: folderId,
          deleteCallback: () async {
            BlocProvider.of<TimelineBloc>(context)
                .add(TimelineDeleteAdventureEvent(folderId: folderId));
          });
      _TimeLineEventEntry _timeLineEventEntry =
          _TimeLineEventEntry(event.mainEvent.timestamp, display);
      timeLineEvents.add(_timeLineEventEntry);
    });
    timeLineEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    timeLineEvents.forEach((element) {
      eventDisplay.add(element.event);
    });

    return Column(
      key: Key(_timelineData.length.toString()),
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
                  children: [Icon(Icons.add, size: 24), Text("add event")],
                ),
              ),
            ),
            onPressed: () async {
              int timestamp = DateTime.now().millisecondsSinceEpoch;
              BlocProvider.of<TimelineBloc>(context).add(
                  TimelineCreateAdventureEvent(
                      timestamp: timestamp, mainEvent: true));
            },
          ),
        ),
        SizedBox(height: 20),
        ...eventDisplay,
      ],
    );
  }
}
