import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/app/blocs/adventure/adventure_bloc.dart';
import 'package:web/app/blocs/adventure/adventure_event.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class EventCard extends StatefulWidget {
  final Widget controls;
  final double width;
  final double height;
  final EventContent event;
  final bool locked;
  final bool saving;
  final List<String> uploadingImages;

  const EventCard(
      {Key key,
      this.width,
      this.height = double.infinity,
      this.event,
      this.locked,
      this.controls, this.saving, this.uploadingImages})
      : super(key: key);

  @override
  _TimelineEventCardState createState() => _TimelineEventCardState();
}

class _TimelineEventCardState extends State<EventCard> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate;
  final _formKey = GlobalKey<FormState>();
  final formatter = new DateFormat('dd MMMM, yyyy');
  String formattedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.event.timestamp);
    formattedDate = formatter.format(selectedDate);
    titleController.text = widget.event.title;
    descriptionController.text = widget.event.description;
  }

  Widget timeStamp() {
    return Container(
      padding: EdgeInsets.all(0),
      height: 30,
      width: 130,
      child: DateTimeFormField(
        decoration: new InputDecoration(
            errorBorder: InputBorder.none,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero),
        enabled: !widget.locked,
        textStyle: myThemeData.textTheme.caption,
        label: null,
        mode: DateFieldPickerMode.date,
        initialValue: selectedDate,
        onDateSelected: (DateTime date) {
          if (widget.saving) {
            return;
          }
          setState(() {
            selectedDate = date;
            widget.event.timestamp = date.millisecondsSinceEpoch;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];
    if (widget.event.images != null) {
      for (MapEntry<String, EventImage> image in widget.event.images.entries) {
        cards.add(ImageCard(image.key, image.value));
      }
    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            this.widget.width > Constants.SMALL_WIDTH
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    timeStamp(),
                    this.widget.controls,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    this.widget.controls,
                    timeStamp(),
                  ],
                ), Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                  textAlign: TextAlign.center,
                  autofocus: false,
                  maxLines: null,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                      color: myThemeData.primaryColorDark),
                  decoration: new InputDecoration(
                      errorMaxLines: 0,
                      errorBorder: InputBorder.none,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Enter a title'),
                  readOnly: widget.locked || widget.saving,
                  controller: titleController,
                  onChanged: (string) {
                    BlocProvider.of<AdventureBloc>(context).add(AdventureEditTitleEvent(widget.event.folderID, string));
                    //widget.event.title = string;
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: cards,
                ),
              ),
              Visibility(
                visible: !widget.locked,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 140,
                        child: ButtonWithIcon(
                            text: "add picture",
                            icon: Icons.image,
                            onPressed: () async {
                              if (widget.saving) {
                                return;
                              }
                              BlocProvider.of<AdventureBloc>(context).add(
                                  AdventureAddMediaEvent(widget.event.folderID)
                              );
                            },
                            width: Constants.SMALL_WIDTH,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            iconColor: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              TextFormField(
                  textAlign: TextAlign.center,
                  controller: descriptionController,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'OpenSans',
                      color: myThemeData.primaryColorDark),
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Enter a description'),
                  readOnly: widget.locked || widget.saving,
                  onChanged: (string) {
                    BlocProvider.of<AdventureBloc>(context).add(AdventureEditDescriptionEvent(widget.event.folderID, string));
                  },
                  maxLines: null)
            ],
          ),
        ]
        ),
      ),
    );
  }

  Widget ImageCard(String key, EventImage image) {
    bool isNetworkImage = image.bytes == null;

    if (isNetworkImage) {
      return imageWidget(key, imageURL: image.imageURL);
    } else {
      return imageWidget(key, data: image.bytes);
    }
  }

  Widget imageWidget(String imageKey, {Uint8List data, String imageURL}) {
    print("5 ${widget.uploadingImages}");
    return GestureDetector(
      onTap: () {
        if (widget.locked) {
          List<String> urls = List();
          int index = 0;
          int counter = 0;
          widget.event.images.forEach((key, value) {
            urls.add(key);
            if (imageKey == key) {
              index = counter;
            }
            counter++;
          });
          DialogService.mediaDialog(context, urls, index);
        }
      },
      child: Container(
        height: 150.0,
        width: 150.0,
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          image: DecorationImage(
            image: data != null
                ? new MemoryImage(data)
                : CachedNetworkImageProvider(imageURL),
            fit: BoxFit.cover,
          ),
        ),
        child: Visibility(
            child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3, top: 3),
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    child: IconButton(
                      iconSize: 18,
                      splashRadius: 18,
                      icon: Icon(
                        widget.saving ? Icons.cloud_upload : Icons.clear,
                        color: widget.saving ? (widget.uploadingImages.contains(imageKey) ? Colors.orange : Colors.green) : Colors.redAccent,
                        size: 18,
                      ),
                      onPressed: () {
                        if (widget.saving) {
                          return;
                        }
                        BlocProvider.of<AdventureBloc>(context).add(AdventureRemoveImageEvent(widget.event.folderID, imageKey));
                      },
                    ),
                  ),
                )),
            visible: !widget.locked),
      ),
    );
  }
}
