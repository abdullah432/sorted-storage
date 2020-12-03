import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/app/models/user.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/app/blocs/authentication/authentication_bloc.dart';
import 'package:web/app/blocs/authentication/authentication_event.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class CommentWidget extends StatefulWidget {
  final Function(String comment) sendComment;
  final AdventureComments comments;
  final double width;
  final double height;

  const CommentWidget(
      {Key key, this.sendComment, this.comments, this.width, this.height})
      : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Container(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.comments.comments.length,
                itemBuilder: (context, index) {
                  String user = widget.comments.comments[index].user;
                  if (user == null || user == "") {
                    user = "Anonymous";
                  }
                  return Container(
                    child: Row(
                      children: [
                        Text(
                          '$user',
                          style: myThemeData.textTheme.headline4,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '${widget.comments.comments[index].comment}',
                          style: myThemeData.textTheme.bodyText1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            BlocBuilder<AuthenticationBloc, User>(builder: (context, user) {
              print('------------------');
              if (user == null) {
                return ButtonWithIcon(
                    text: "Sign in to comment",
                    icon: Icons.login,
                    onPressed: () {
                      BlocProvider.of<AuthenticationBloc>(context)
                          .add(AuthenticationSignInEvent());
                    },
                    width: Constants.SMALL_WIDTH,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    iconColor: Colors.black);
              }
              print(user.toJson());
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                        decoration: new InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: myThemeData.primaryColorDark,
                                  width: 5.0),
                            ),
                            errorMaxLines: 0,
                            hintText: 'add a comment'),
                        controller: controller,
                        style: myThemeData.textTheme.bodyText1,
                        minLines: 1,
                        readOnly: false),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20),
                    child: ButtonWithIcon(
                        text: "comment",
                        icon: Icons.send,
                        onPressed: () async {
                          await widget.sendComment(controller.text);
                          controller.text = "";
                        },
                        width: Constants.SMALL_WIDTH,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        iconColor: Colors.black),
                  )
                ],
              );
            })
          ],
        ),
      ),
    );
  }
}
