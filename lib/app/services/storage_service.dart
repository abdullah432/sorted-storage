import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;
import 'package:web/app/models/http_client.dart';
import 'package:web/app/services/authenticate_service.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/locator.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class UploadImageReturn {
  String id;
  EventImage image;

  UploadImageReturn(this.id, this.image);
}

class EventSettings {
  String title;
  String description;

  EventSettings({this.title = "", this.description = ""});

  static EventSettings fromJson(Map<String, dynamic> json) {
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

abstract class StorageService {
  Future initialize();
  Future<String> getMediaFolder(StreamController<DialogStreamContent> streamController);
  Future syncDrive(StreamController streamController, EventContent localCopy, EventContent cloudCopy);

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

  Future<EventSettings> getSettings(String settingsFile);

  Future<TimelineEvent> getViewEvent(String folderID);
}
