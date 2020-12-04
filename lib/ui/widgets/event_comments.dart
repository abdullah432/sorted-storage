import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/add_adventure/add_adventure_bloc.dart';
import 'package:web/app/blocs/add_adventure/add_adventure_event.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/app/blocs/send_comment/send_comment_bloc.dart';
import 'package:web/app/blocs/send_comment/send_comment_event.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/user.dart' as usr;
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CommentWidget extends StatefulWidget {
  final Function(BuildContext context, usr.User user, String comment)
      sendComment;
  final AdventureComments comments;
  final double width;
  final double height;
  final usr.User user;

  const CommentWidget(
      {Key key,
      this.sendComment,
      this.comments,
      this.width,
      this.height,
      this.user})
      : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    List<Widget> comments = List();
    for (int i = 0; i < widget.comments.comments.length; i++) {
      String user = widget.comments.comments[i].user;
      if (user == null || user == "") {
        user = "Anonymous";
      }
      comments.add(Container(
        child: Row(
          children: [
            Text(
              '$user',
              style: myThemeData.textTheme.headline4,
            ),
            SizedBox(width: 10),
            Text(
              '${widget.comments.comments[i].comment}',
              style: myThemeData.textTheme.bodyText1,
            ),
          ],
        ),
      ));
    }

    return Container(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: comments,
              ),
            ),
            widget.user == null
                ? ButtonWithIcon(
                    text: "Sign in to comment",
                    icon: Icons.login,
                    onPressed: () {
                      BlocProvider.of<AuthenticationBloc>(context)
                          .add(AuthenticationSignInEvent());
                    },
                    width: Constants.SMALL_WIDTH,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black)
                : CommentSection(controller: controller, widget: widget)
          ],
        ),
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  const CommentSection({
    Key key,
    @required this.controller,
    @required this.widget,
  }) : super(key: key);

  final TextEditingController controller;
  final CommentWidget widget;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<SendCommentBloc>(context).add(SendCommentDoneEvent());
    return Row(
      children: [
        Expanded(
          child: TextField(
              decoration: new InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: myThemeData.primaryColorDark, width: 5.0),
                  ),
                  errorMaxLines: 0,
                  hintText: 'add a comment'),
              controller: controller,
              style: myThemeData.textTheme.bodyText1,
              minLines: 1,
              readOnly: false),
        ),
        BlocBuilder<SendCommentBloc, bool>(builder: (context, adding) {
          return Container(
            padding: EdgeInsets.only(left: 20),
            child: ButtonWithIcon(
                text: "comment",
                icon: Icons.send,
                onPressed: () async {
                  if (adding || controller.text.length == 0) {
                    return;
                  }
                  BlocProvider.of<SendCommentBloc>(context).add(SendCommentNewEvent());
                  await widget.sendComment(context, widget.user, controller.text);
                  controller.text = "";
                },
                width: Constants.SMALL_WIDTH,
                backgroundColor: adding ? Colors.grey[100] : Colors.white,
                textColor: adding ? Colors.grey: Colors.black,
                iconColor: adding ? Colors.grey: Colors.black),
          );
        })
      ],
    );
  }
}
