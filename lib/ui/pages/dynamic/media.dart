import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/ui/widgets/timeline.dart';

class MediaPage extends StatefulWidget {
  static const String route = '/media';

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TimelineBloc(
          BlocProvider.of<DriveBloc>(context).state),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return EventTimeline(
                width: constraints.maxWidth, height: constraints.maxHeight);
          },
        ),
      ),
    );
  }
}
