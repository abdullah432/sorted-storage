import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class TimelineBloc extends Bloc<TimelineEvent, Map<String, TimelineData>> {
  Map<String, TimelineData> events;
  DriveApi driveApi;
  Map<String, Uint8List> images;
  String mediaFolderID;

  TimelineBloc() : super(null);

  @override
  Stream<Map<String, TimelineData>> mapEventToState(event) async* {
    if (event is TimelineUpdatedEvent) {
      print('new event received!');
      yield Map.from(events);
    }
    if (event is TimelineCreateAdventureEvent) {
      _createEventFolder(event.parentId, event.timestamp, event.mainEvent);
    }
    if (event is TimelineDeleteAdventureEvent) {
      _deleteEvent(event.folderId);
    }
    if (event is TimelineInitializeEvent) {
      driveApi = event.driveApi;
    }
    if (event is TimelineGetAllEvent) {
      if (events == null) {
        events = Map();
        _initilize();
      }
    }
  }

  _initilize() {
    print("whyyyy");
    getMediaFolder().then((value) {
      mediaFolderID = value;
      _getEventsFromFolder(mediaFolderID);
    });
  }

  Future _deleteEvent(fileId) async {
    await driveApi.files.delete(fileId);
    events.remove(fileId);
    this.add(TimelineUpdatedEvent());
  }

  Future _getEventsFromFolder(String folderID) async {
    try {
      FileList eventList = await driveApi.files.list(
          q: "mimeType='application/vnd.google-apps.folder' and '$folderID' in parents and trashed=false");

      print('found ${eventList.files.length} event folders');
      List<String> folderIds = [];
      for (File file in eventList.files) {
        int timestamp = int.tryParse(file.name);

        if (timestamp != null) {
          folderIds.add(file.id);
          _createEventFromFolder(file.id, timestamp).then((mainEvent) async {
            List<EventContent> subEvents = List();
            for (SubEvent subEvent in mainEvent.subEvents) {
              subEvents.add(await _createEventFromFolder(
                  subEvent.id, subEvent.timestamp));
            }

            events.putIfAbsent(
                file.id,
                () =>
                    TimelineData(mainEvent: mainEvent, subEvents: subEvents));
          });
        }
      }

      await _waitUntil(
          () => events.length == folderIds.length, Duration(milliseconds: 500));

      print('got ${events.length} events');
      this.add(TimelineUpdatedEvent());
    } catch (e) {
      print('error: $e');
    } finally {}
  }

  Future<String> getMediaFolder() async {
    try {
      String mediaFolderID;
      print('getting media folder');

      String query =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.ROOT_FOLDER}' and trashed=false";
      var folderPArent = await driveApi.files.list(q: query);
      String parentId;

      if (folderPArent.files.length == 0) {
        File fileMetadata = new File();
        fileMetadata.name = Constants.ROOT_FOLDER;
        fileMetadata.mimeType = "application/vnd.google-apps.folder";
        fileMetadata.description = "please don't modify this folder";
        var rt = await driveApi.files.create(fileMetadata);
        parentId = rt.id;
      } else {
        parentId = folderPArent.files.first.id;
      }

      String query2 =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.MEDIA_FOLDER}' and '$parentId' in parents and trashed=false";
      var folder = await driveApi.files.list(q: query2);

      if (folder.files.length == 0) {
        File fileMetadataMedia = new File();
        fileMetadataMedia.name = Constants.MEDIA_FOLDER;
        fileMetadataMedia.parents = [parentId];
        fileMetadataMedia.mimeType = "application/vnd.google-apps.folder";
        fileMetadataMedia.description = "please don't modify this folder";

        var folder = await driveApi.files.create(fileMetadataMedia);
        mediaFolderID = folder.id;
      } else {
        mediaFolderID = folder.files.first.id;
      }

      print('media folder: $mediaFolderID');
      return mediaFolderID;
    } catch (e) {
      print('error: $e');
      return e.toString();
    } finally {}
  }

  Future<EventContent> _createEventFromFolder(
      String folderID, int timestamp) async {
    FileList textFileList = await driveApi.files.list(
        q: "'$folderID' in parents and trashed=false",
        $fields: 'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink)');

    print('folder.files.length ${textFileList.files.length}');
    String settingsID;
    String commentsID;
    Map<String, StoryMedia> images = Map();
    List<SubEvent> subEvents = List();
    for (File file in textFileList.files) {
      if (file.mimeType.startsWith("image/") ||
              file.mimeType.startsWith("video/")) {
        StoryMedia media = StoryMedia();
        media.isImage = file.mimeType.startsWith("image/");
        if (file.hasThumbnail) {
          media.imageURL = file.thumbnailLink;
        } else {
          ByteData bytes = await rootBundle.load('assets/images/placeholder.png');
          media.bytes = bytes.buffer.asUint8List();
        }
        images.putIfAbsent(file.id, () => media);

      } else if (file.name == Constants.SETTINGS_FILE) {
        settingsID = file.id;
      } else if (file.name == Constants.COMMENTS_FILE) {
        commentsID = file.id;
      } else if (file.mimeType == 'application/vnd.google-apps.folder') {
        int timestamp = int.tryParse(file.name);
        if (timestamp != null) {
          subEvents.add(SubEvent(file.id, timestamp));
        }
      }
      print("file name ${file.name}");
    }

    AdventureSettings settings =
        AdventureSettings.fromJson(await _getJsonFile(settingsID));

    AdventureComments comments =
        AdventureComments.fromJson(await _getJsonFile(commentsID));

    return EventContent(
        timestamp: timestamp,
        images: images,
        title: settings.title,
        comments: comments,
        commentsID: commentsID,
        description: settings.description,
        subEvents: subEvents,
        settingsID: settingsID,
        folderID: folderID);
  }

  Future _waitUntil(bool test(), [Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (test()) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }

  Future _createEventFolder(
      String parentId, int timestamp, bool mainEvent) async {
    try {
      if (mainEvent) {
        parentId = mediaFolderID;
      }
      File eventToUpload = File();
      eventToUpload.parents = [parentId];
      eventToUpload.mimeType = "application/vnd.google-apps.folder";
      eventToUpload.name = timestamp.toString();

      var folder = await driveApi.files.create(eventToUpload);

      EventContent event = EventContent(
          comments: AdventureComments(comments: List()),
          folderID: folder.id,
          timestamp: timestamp,
          description: '',
          title: '',
          subEvents: List(),
          images: Map());
      event.settingsID = await _uploadSettingsFile(folder.id, event);
      await _uploadSettingsFile(folder.id, event);

      if (mainEvent) {
        TimelineData timelineEvent =
            TimelineData(mainEvent: event, subEvents: []);
        events.putIfAbsent(folder.id, () => timelineEvent);
        await _uploadCommentsFile(event, null);
      }
      this.add(TimelineUpdatedEvent());
    } catch (e) {
      print('error: $e');
    }
  }

  Future<String> _uploadSettingsFile(
      String parentId, EventContent content) async {
    AdventureSettings settings =
        AdventureSettings(title: content.title, description: content.description);
    String jsonString = jsonEncode(settings);

    print(jsonString);

    List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future.value(fileContent).asStream().asBroadcastStream();

    if (content.settingsID != null) {
      var folder = await driveApi.files.update(null, content.settingsID,
          uploadMedia: Media(mediaStream, fileContent.length));
      return folder.id;
    }

    File eventToUpload = File();
    eventToUpload.parents = [parentId];
    eventToUpload.mimeType = "application/json";
    eventToUpload.name = Constants.SETTINGS_FILE;
    var folder = await driveApi.files.create(eventToUpload,
        uploadMedia: Media(mediaStream, fileContent.length));
    return folder.id;
  }

  Future<dynamic> _getJsonFile(String fileId) async {
    Map<String, dynamic> event;
    if (fileId != null) {
      Media mediaFile = await driveApi.files
          .get(fileId, downloadOptions: DownloadOptions.FullMedia);

      List<int> dataStore = [];
      await for (var data in mediaFile.stream) {
        dataStore.insertAll(dataStore.length, data);
      }
      event = jsonDecode(utf8.decode(dataStore));
    }
    return event;
  }

  Future<String> _uploadCommentsFile(
      EventContent event, AdventureComment comment) async {
    print('1 ${event.commentsID}');
    AdventureComments comments =
        AdventureComments.fromJson(await _getJsonFile(event.commentsID));
    if (comments == null) {
      comments = AdventureComments();
    }
    if (comments.comments == null) {
      comments.comments = List();
    }
    if (comment != null) {
      comments.comments.add(comment);
    }

    File eventToUpload = File();
    eventToUpload.parents = [event.folderID];
    eventToUpload.mimeType = "application/json";
    eventToUpload.name = Constants.COMMENTS_FILE;

    String jsonString = jsonEncode(comments);
    print(jsonString);

    List<int> fileContent = utf8.encode(jsonString);
    final Stream<List<int>> mediaStream =
        Future.value(fileContent).asStream().asBroadcastStream();

    var folder;
    if (event.commentsID == null) {
      folder = await driveApi.files.create(eventToUpload,
          uploadMedia: Media(mediaStream, fileContent.length));
      await _shareFile(folder.id, "anyone", "writer");
    } else {
      folder = await driveApi.files.update(null, event.commentsID,
          uploadMedia: Media(mediaStream, fileContent.length));
    }

    event.comments = comments;
    event.commentsID = folder.id;
    return folder.id;
  }

  Future<String> _shareFile(String fileID, String type, String role) async {
    Permission anyone = Permission();
    anyone.type = type;
    anyone.role = role;

    Permission permission = await driveApi.permissions.create(anyone, fileID);
    return permission.id;
  }
}
