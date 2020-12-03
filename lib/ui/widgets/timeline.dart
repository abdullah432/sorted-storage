
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/events/events_bloc.dart';
import 'package:web/app/blocs/events/events_event.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class EventTimeline extends StatefulWidget {
  final double width;
  final double height;

  const EventTimeline({Key key, this.width, this.height}): super(key: key);

  @override
  State<StatefulWidget> createState() => _EventTimelineState();
}

class _TimeLineEventEntry {
  final int timestamp;
  final Widget event;

  _TimeLineEventEntry(this.timestamp, this.event);
}

class _EventTimelineState extends State<EventTimeline> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, Map<String, TimelineEvent>>(
        builder: (context, events) {
          print('new event!! ${events.length}');

          List<Widget> eventDisplay = List();
          List<_TimeLineEventEntry> timeLineEvents = List();
          if (events != null) {
            events.forEach((folderId, event) {
              Widget display = TimelineCard(
                  width: widget.width,
                  height: widget.height,
                  event: event,
                  folderId: folderId,
                  deleteCallback: () async {
                    BlocProvider.of<EventsBloc>(context)
                        .add(EventsDeleteEventEvent(folderId: folderId));
                  });
              _TimeLineEventEntry _timeLineEventEntry =
              _TimeLineEventEntry(event.mainEvent.timestamp, display);
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
                        children: [Icon(Icons.add, size: 24), Text("add event")],
                      ),
                    ),
                  ),
                  onPressed: () async {
                      int timestamp = DateTime.now().millisecondsSinceEpoch;
                      BlocProvider.of<EventsBloc>(context).add(EventsCreateNewEventEvent(
                         timestamp:timestamp, mainEvent: true
                      ));
                  },
                ),
              ),
              SizedBox(height: 20),
              ...eventDisplay,
            ],
          );
      }
    );

  }
}
