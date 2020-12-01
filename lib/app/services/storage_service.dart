import 'dart:async';
import 'dart:typed_data';

import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/widgets/timeline_card.dart';
import 'package:web/app/models/user.dart';

class UploadImageReturn {
  String id;
  EventImage image;

  UploadImageReturn(this.id, this.image);
}

class EventComment {
  String user;
  String comment;

  EventComment({this.user = "", this.comment = ""});

  static EventComment fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return new EventComment();
    }

    String user = "";
    String comment = "";
    Map<String, int> emoji = Map();
    if (json.containsKey('u')) {
      user = json['u'];
    }
    if (json.containsKey('c')) {
      comment = json['c'];
    }

    return new EventComment(user: user, comment: comment);
  }

  Map<String, dynamic> toJson() {
    return {
      'u': user,
      'c': comment
    };
  }

}

class EventComments {
  List<EventComment> comments;

  EventComments({this.comments});

  EventComments.clone(EventComments comment)
      : this(comments: List.from(comment.comments));

  static EventComments fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return new EventComments(comments: List());
    }
    List<EventComment> comments = List();
    if (json.containsKey('c')) {
      for (dynamic comment in json['c']) {
        comments.add(EventComment.fromJson(comment));
      }
    }

    return new EventComments(comments: comments);
  }

  Map<String, dynamic> toJson() {
    return {
      'c': comments,
    };
  }
}

class EventSettings {
  String title;
  String description;

  EventSettings({this.title = "", this.description = ""});

  static EventSettings fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return new EventSettings();
    }

    String title = "";
    String description = "";
    if (json.containsKey('t')) {
      title = json['t'];
    }
    if (json.containsKey('d')) {
      description = json['d'];
    }

    return new EventSettings(title: title, description: description);
  }

  Map<String, dynamic> toJson() {
    return {
      't': title,
      'd': description,
    };
  }
}

class StorageInformation {
  final String usage;
  final String limit;

  StorageInformation({this.usage, this.limit});
}

abstract class StorageService {
  Future initialize(User user);
  Future<String> getMediaFolder(StreamController<DialogStreamContent> streamController);
  Future syncDrive(StreamController streamController, EventContent localCopy, EventContent cloudCopy);
  Future sendComment(EventContent event, EventComment comment);
  Future<StorageInformation> getStorageInformation();
  void sendToChangeProfile();
  void sendToUpgrade();

  Uint8List getLocalImage(String imageURL);
  Future<Uint8List> getImage(String key);

  Future<String> getPermissions(String folderID);
  Future<String> shareFolder(String folderID);
  Future stopSharingFolder(String folderID, String permissionID);

  Future<Map<String, TimelineEvent>> getEventsFromFolder(String folderID, StreamController<DialogStreamContent> streamController);
  Future<EventContent> createEventFolder(String parentId, int timestamp, bool mainEvent);
  Map<String, TimelineEvent> getEvents();
  Future deleteEvent(key);
  updateEvent(String folderId, TimelineEvent cloudCopy);

  Future<dynamic> getJsonFile(String settingsFile);

  Future<TimelineEvent> getViewEvent(String folderID);
}
