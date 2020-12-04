import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/add_adventure/add_adventure_bloc.dart';
import 'package:web/app/blocs/add_adventure/add_adventure_event.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class MediaPage extends StatefulWidget {
  static const String route = '/media';

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimelineBloc, Map<String, TimelineData>>(
    builder: (context, timeline) {
      if (timeline == null) {
        return FullPageLoadingLogo();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return TimelineLayout(
                width: constraints.maxWidth, height: constraints.maxHeight);
          },
        ),
      );}
    );
  }
}
