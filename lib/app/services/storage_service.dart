import 'dart:async';
import 'dart:math';

import 'package:googleapis/drive/v3.dart';
import 'package:web/ui/widgets/timeline_card.dart';

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

class GoogleStorageService{
  static Future<StorageInformation> getStorageInformation(DriveApi driveApi) async {
    About about = await driveApi.about.get($fields: 'storageQuota');

    return StorageInformation(
        limit: formatBytes(about.storageQuota.limit, 0),
        usage: formatBytes(about.storageQuota.usage, 0)
    );
  }

  static String formatBytes(String stringBytes, int decimals) {
    try {
      var bytes = int.parse(stringBytes);
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
      var i = (log(bytes) / log(1024)).floor();
      return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
          ' ' +
          suffixes[i];
    } catch (e) {
      return "";
    }
  }

}