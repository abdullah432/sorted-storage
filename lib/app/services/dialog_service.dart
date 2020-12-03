import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/images/images_bloc.dart';
import 'package:web/app/blocs/images/images_event.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/blocs/sharing/sharing_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';

class DialogStreamContent {
  final String text;
  final int value;

  DialogStreamContent(this.text, this.value);
}

class ShareWidget extends StatefulWidget {
  final String folderID;
  final bool shared;

  const ShareWidget({Key key, this.folderID, this.shared}) : super(key: key);

  @override
  _ShareWidgetState createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  @override
  Widget build(BuildContext context) {
    bool shared = widget.shared;
    print('rebuilding $shared');
    TextEditingController controller = new TextEditingController();

    if (shared) {
      controller.text = "${Constants.WEBSITE_URL}/view/${widget.folderID}";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        shared
            ? Container(
                padding: EdgeInsets.all(20),
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy, size: 20),
                      iconSize: 20,
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: controller.text));
                      },
                    ),
                    SizedBox(width: 10),
                    Container(
                        width: 200,
                        child: new TextField(
                            controller: controller,
                            style: myThemeData.textTheme.bodyText1,
                            minLines: 2,
                            maxLines: 4,
                            readOnly: true))
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                    "To make this event publicly visible click the share button."),
              ),
        MaterialButton(
          minWidth: 100,
          onPressed: () async {
            if (shared) {
              BlocProvider.of<SharingBloc>(context).add(StopSharingEvent());
            } else {
              BlocProvider.of<SharingBloc>(context).add(StartSharingEvent());
            }
          },
          child: Text(
            shared ? "stop sharing" : "share",
            style: myThemeData.textTheme.button,
          ),
          color: myThemeData.primaryColorDark,
          textColor: Colors.white,
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: shared
              ? Text(
                  "Everyone with this link can see your content. Be careful who you give it to!")
              : Container(),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                    minWidth: 100,
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: Colors.black,
                        ),
                        SizedBox(width: 5),
                        Text("close"),
                      ],
                    ),
                    color: Colors.white,
                    textColor: Colors.black,
                    onPressed: () {
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent());
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Function onPressed;

  const CircleIconButton({Key key, this.icon, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 3, top: 3),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(40))),
        child: IconButton(
          iconSize: 18,
          splashRadius: 18,
          icon: Icon(
            icon,
            color: Colors.redAccent,
            size: 18,
          ),
          onPressed: this.onPressed,
        ),
      ),
    );
  }
}

class MediaViewer extends StatefulWidget {
  final List<String> mediaURLS;
  final int index;

  const MediaViewer({Key key, this.mediaURLS, this.index}) : super(key: key);

  @override
  _MediaViewerState createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer>
    with SingleTickerProviderStateMixin {
  int currentIndex;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  Widget imageWidget(Uint8List bytes) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 1000),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(child: child, opacity: animation);
      },
      child: GestureDetector(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleIconButton(
                    icon: Icons.clear,
                    onPressed: () {
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent());
                    }),
              ],
            ),
            ResponsiveBuilder(
              builder: (context, sizingInformation) => InteractiveViewer(
                child: Container(
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      image: DecorationImage(image: MemoryImage(bytes)),
                    ),
                    child: Container(
                      width: sizingInformation.screenSize.width,
                      height: sizingInformation.screenSize.height - 180,
                    )),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleIconButton(
                    icon: Icons.arrow_left,
                    onPressed: () {
                      setState(() {
                        currentIndex =
                            (currentIndex - 1) % widget.mediaURLS.length;
                      });
                    }),
                CircleIconButton(
                    icon: Icons.arrow_right,
                    onPressed: () {
                      setState(() {
                        currentIndex =
                            (currentIndex + 1) % widget.mediaURLS.length;
                      });
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ImagesBloc>(context).add(GetImagesEvent(widget.mediaURLS[currentIndex]));
    return  BlocBuilder<ImagesBloc, Uint8List>(builder: (context, image) {
      if (image == null) {
        return FullPageLoadingLogo();
      }
      return imageWidget(image);
    });
//
//    Uint8List localImage =
//        locator<StorageService>().getLocalImage(widget.mediaURLS[currentIndex]);
//
//    if (localImage != null) {
//      return imageWidget(localImage);
//    }
//
//    return AnimatedSwitcher(
//      duration: Duration(milliseconds: 1000),
//      transitionBuilder: (Widget child, Animation<double> animation) {
//        return FadeTransition(child: child, opacity: animation);
//      },
//      child: FutureBuilder(
//        future:
//            locator<StorageService>().getImage(widget.mediaURLS[currentIndex]),
//        builder: (context, snapshot) {
//          if (snapshot.hasError) {
//            return Center(
//                child: Text('Something went wrong ${snapshot.error}'));
//          }
//          // Once complete, show your application
//          if (snapshot.connectionState == ConnectionState.done) {
//            return imageWidget(snapshot.data);
//          }
//          return FullPageLoadingLogo(backgroundColor: Colors.white);
//        },
//      ),
//    );
  }
}

class DialogService {
  static cookieDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Image.asset("assets/images/cookie.png"),
                        Text(
                            "This site uses cookies, by continuing to use this site we assume you have read and agree with our:"),
                        InkWell(
                            child: new Text('Terms of conditions'),
                            onTap: () => launch(
                                'https://sortedstorage.com/#/terms-of-conditions')),
                        InkWell(
                            child: new Text('privacy policy'),
                            onTap: () => launch(
                                'https://sortedstorage.com/#/privacy-policy')),
                        SizedBox(height: 20),
                        MaterialButton(
                          color: myThemeData.primaryColorDark,
                          onPressed: () {
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigatorPopEvent());
                          },
                          child:
                              Text("ok", style: myThemeData.textTheme.button),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  static mediaDialog(BuildContext context, List<String> keys, int currentKey) {
    showDialog(
        context: context,
        barrierDismissible: true,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return BlocProvider(
            create: (BuildContext context) => ImagesBloc(
                BlocProvider.of<DriveBloc>(context).state),
            child: Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              elevation: 0,
              child: MediaViewer(mediaURLS: keys, index: currentKey),
            ),
          );
        });
  }

  static shareDialog(BuildContext context, String folderID) {
    showDialog(
        context: context,
        barrierDismissible: true,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return BlocProvider(
              create: (BuildContext context) => SharingBloc(
                  BlocProvider.of<DriveBloc>(context).state,
                  folderID),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
                elevation: 1,
                child:
                    BlocBuilder<SharingBloc, bool>(builder: (context, shared) {
                      print(shared);
                  if (shared == null) {
                    return FullPageLoadingLogo();
                  }
                  return ShareWidget(folderID: folderID, shared: shared);
                }),
              ));
        });
  }

  static popUpDialog(BuildContext context,
      StreamController<DialogStreamContent> streamController) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return simpleDialog(streamController);
      },
    );
  }

  static Widget simpleDialog(
      StreamController<DialogStreamContent> streamController) {
    int value = 0;
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      elevation: 1,
      child: StreamBuilder(
          stream: streamController.stream,
          builder: (context, snapshot) {
            String message = "";
            if (snapshot.data != null) {
              message = snapshot.data.text;
              value += snapshot.data.value;
            }

            return Container(
              width: 300,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: StaticLoadingLogo()),
                  Padding(
                    padding: const EdgeInsets.only(top: 28.0),
                    child: Column(
                      children: [
                        new Text("$message"),
                        Visibility(
                            visible: value > 0,
                            child: Text("$value tasks to do")),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
