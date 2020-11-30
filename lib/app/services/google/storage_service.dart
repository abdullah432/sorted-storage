import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'dart:html' as html;
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart' as http;
import 'package:web/app/models/http_client.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/constants.dart';
import 'package:web/locator.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class GoogleStorageService implements StorageService {
  DriveApi driveApi;
  Map<String, TimelineEvent> events;
  String mediaFolderID;
  http.Client client;
  Map<String, Uint8List> images;

  Future initialize(Map<String, String> headers) async {
    if (headers != null) {
      client = ClientWithAuthHeaders(headers);
    } else {
      client = ClientWithGoogleDriveKey();
    }

    driveApi = DriveApi(client);
    if (images == null) {
      images = Map();
    }
  }

  Uint8List getLocalImage(String imageURL) {
    if (images.containsKey(imageURL)) {
      return images[imageURL];
    }
    return null;
  }

  @override
  Future<Uint8List> getImage(String key) async {
    Uint8List localImage = getLocalImage(key);
    if (localImage != null) {
      return localImage;
    }

    Media mediaFile = await driveApi.files
        .get(key, downloadOptions: DownloadOptions.FullMedia);

    List<int> dataStore = [];
    await for (var data in mediaFile.stream) {
      // TODO: progress bar: update receiving
      print('receiving ${data.length}');
      dataStore.insertAll(dataStore.length, data);
    }
    Uint8List image = Uint8List.fromList(dataStore);
    images.putIfAbsent(key, () => image);
    return image;
  }

  Future<String> getMediaFolder(
      StreamController<DialogStreamContent> streamController) async {
    if (mediaFolderID != null) {
      streamController.close();
      return mediaFolderID;
    }

    try {
      streamController
          .add(DialogStreamContent("Connecting to Google Drive", 0));
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

        streamController
            .add(DialogStreamContent("Creating Sorted Storage folder", 0));
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

        streamController.add(DialogStreamContent("Creating Media folder", 0));
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
    } finally {
      streamController.close();
    }
  }

  Future<String> getPermissions(String folderID) async {
    PermissionList list = await driveApi.permissions.list(folderID);

    for (Permission permission in list.permissions) {
      if (permission.type == "anyone" && permission.role == "reader") {
        return permission.id;
      }
    }
    return null;
  }

  Future<String> shareFolder(String folderID) async {
    return _shareFile(folderID, "anyone", "reader");
  }

  Future<String> _shareFile(String fileID, String type, String role) async {
    Permission anyone = Permission();
    anyone.type = type;
    anyone.role = role;

    Permission permission = await driveApi.permissions.create(anyone, fileID);
    return permission.id;
  }

  Future stopSharingFolder(String folderID, String permissionID) async {
    await driveApi.permissions.delete(folderID, permissionID);
  }

  Future<Map<String, TimelineEvent>> getEventsFromFolder(String folderID,
      StreamController<DialogStreamContent> streamController) async {
    if (events != null && events.length > 0) {
      streamController.close();
      return events;
    }

    try {
      events = Map();

      streamController
          .add(DialogStreamContent("Connecting to Google Drive", 0));
      FileList eventList = await driveApi.files.list(
          q: "mimeType='application/vnd.google-apps.folder' and '$folderID' in parents and trashed=false");

      print('found ${eventList.files.length} event folders');
      List<String> folderIds = [];

      streamController.add(DialogStreamContent(
          "Downloading ${eventList.files.length} events", 0));
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
                    TimelineEvent(mainEvent: mainEvent, subEvents: subEvents));
            streamController.add(DialogStreamContent(
                "Downloading ${folderIds.length - events.length} events", 0));
          });
        }
      }

      await _waitUntil(
          () => events.length == folderIds.length, Duration(milliseconds: 500));

      print('got ${events.length} events');
      return events;
    } catch (e) {
      print('error: $e');
      return null;
    } finally {
      streamController.close();
    }
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

  Future<EventContent> createEventFolder(
      String parentId, int timestamp, bool mainEvent) async {
    try {
      File eventToUpload = File();
      eventToUpload.parents = [parentId];
      eventToUpload.mimeType = "application/vnd.google-apps.folder";
      eventToUpload.name = timestamp.toString();

      var folder = await driveApi.files.create(eventToUpload);

      EventContent event = EventContent(
          comments: EventComments(comments: List()),
          folderID: folder.id,
          timestamp: timestamp,
          description: '',
          title: '',
          subEvents: List(),
          images: Map());
      event.settingsID = await _uploadSettingsFile(folder.id, event);
      await _uploadSettingsFile(folder.id, event);

      if (mainEvent) {
        TimelineEvent timelineEvent =
            TimelineEvent(mainEvent: event, subEvents: []);
        events.putIfAbsent(folder.id, () => timelineEvent);
        _uploadCommentsFile(event, null);
      }

      return event;
    } catch (e) {
      print('error: $e');
      return null;
    }
  }

  Future<String> _updateEventFolderTimestamp(
      String fileID, int timestamp) async {
    try {
      File eventToUpload = File();
      eventToUpload.name = timestamp.toString();

      var folder = await driveApi.files.update(eventToUpload, fileID);
      print('updated folder: $folder');

      return folder.id;
    } catch (e) {
      print('error: $e');
      return e.toString();
    }
  }

  Future<dynamic> getJsonFile(String fileId) async {
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

  Future<String> _uploadSettingsFile(
      String parentId, EventContent content) async {
    EventSettings settings =
        EventSettings(title: content.title, description: content.description);
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

  Future<TimelineEvent> getViewEvent(String folderID) async {
    var folder = await driveApi.files.get(folderID);
    if (folder == null) {
      return null;
    }
    int timestamp = int.tryParse(folder.name);
    if (timestamp == null) {
      return null;
    }
    var mainEvent = await _createEventFromFolder(folderID, timestamp);

    List<EventContent> subEvents = List();
    for (SubEvent subEvent in mainEvent.subEvents) {
      subEvents
          .add(await _createEventFromFolder(subEvent.id, subEvent.timestamp));
    }

    return TimelineEvent(mainEvent: mainEvent, subEvents: subEvents);
  }

  Future<EventContent> _createEventFromFolder(
      String folderID, int timestamp) async {
    FileList textFileList = await driveApi.files.list(
        q: "'$folderID' in parents and trashed=false",
        $fields: 'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink)');

    print('folder.files.length ${textFileList.files.length}');
    String settingsID;
    String commentsID;
    Map<String, EventImage> images = Map();
    List<SubEvent> subEvents = List();
    for (File file in textFileList.files) {
      if ((file.mimeType.startsWith("image/") ||
              file.mimeType.startsWith("video/")) &&
          file.hasThumbnail) {
        images.putIfAbsent(
            file.id, () => EventImage(imageURL: file.thumbnailLink));
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

    EventSettings settings =
        EventSettings.fromJson(await getJsonFile(settingsID));

    EventComments comments =
        EventComments.fromJson(await getJsonFile(commentsID));

    print("settings $settingsID: $settings");
    print("comments $commentsID: $comments");

    print("settings ${settings.title}");
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

  Future _deleteFile(String fileId) async {
    return await driveApi.files.delete(fileId);
  }

  Future<UploadImageReturn> _uploadMediaToFolder(EventContent eventContent,
      String imageName, Uint8List imageBytes, int delayMilliseconds) async {
    print('converting to list');
    List<int> byteList = imageBytes.toList();

    File originalFileToUpload = File();
    originalFileToUpload.parents = [eventContent.folderID];
    originalFileToUpload.name = imageName;
    print('converting to media');
    Media image = Media(Future.value(byteList).asStream(), byteList.length);
    print('converted media');

    return driveApi.files
        .create(originalFileToUpload, uploadMedia: image)
        .then((response) {
      images.putIfAbsent(response.id, () => imageBytes);
      return UploadImageReturn(response.id, EventImage(bytes: imageBytes));
    });
  }

  Future syncDrive(StreamController streamController, EventContent localCopy,
      EventContent cloudCopy) async {
    List<Future> tasks = List();

    print('updating cloud storage');
    streamController.add(DialogStreamContent("Connecting to Google Drive", 0));

    if (localCopy.timestamp != cloudCopy.timestamp) {
      tasks.add(
          _updateEventFolderTimestamp(localCopy.folderID, localCopy.timestamp)
              .then((value) {
        cloudCopy.timestamp = localCopy.timestamp;
        streamController.add(DialogStreamContent("updated timestamp", 0));
      }, onError: (error) {
        print('error $error');
      }));
      print("timestamp is different!");
    }

    if (localCopy.title != cloudCopy.title ||
        localCopy.description != cloudCopy.description) {
      print('updating settings storage');
      tasks.add(
          _uploadSettingsFile(cloudCopy.folderID, localCopy).then((settingsId) {
        cloudCopy.settingsID = settingsId;
        cloudCopy.title = localCopy.title;
        cloudCopy.description = localCopy.description;
        streamController.add(DialogStreamContent("updated settings file", 0));
      }, onError: (error) {
        print('error $error');
      }));
    }

    Map<String, EventImage> imagesToAdd = Map();
    List<String> imagesToDelete = [];
    if (localCopy.images != null) {
      streamController.add(DialogStreamContent("Uploading images", 0));
      print('uploading ${localCopy.images.length}');

      // TODO: progress bar and elegant way sending images
      int batchLength = 2;
      for (int i = 0; i < localCopy.images.length; i += batchLength) {
        for (int j = i;
            j < i + batchLength && j < localCopy.images.length;
            j++) {
          MapEntry<String, EventImage> image =
              localCopy.images.entries.elementAt(j);
          if (!cloudCopy.images.containsKey(image.key)) {
            tasks.add(_uploadMediaToFolder(
                    cloudCopy, image.key, image.value.bytes, 10)
                .then((uploadResponse) {
              imagesToAdd.putIfAbsent(
                  uploadResponse.id, () => uploadResponse.image);
              print('uploaded this image: ${image.key}');
            }, onError: (error) {
              print('error $error');
            }));
            print('created request $i');
          }
        }
      }

      for (MapEntry<String, EventImage> image in cloudCopy.images.entries) {
        if (!localCopy.images.containsKey(image.key)) {
          print('delete this image: ${image.key}');
          tasks.add(_deleteFile(image.key).then((value) {
            imagesToDelete.add(image.key);
            streamController.add(DialogStreamContent("deleted a image", -1));
          }, onError: (error) {
            print('error $error');
          }));
        }
      }
    }

    return Future.wait(tasks).then((_) {
      cloudCopy.images.addAll(imagesToAdd);
      cloudCopy.images
          .removeWhere((key, value) => imagesToDelete.contains(key));
    });
  }

  Map<String, TimelineEvent> getEvents() {
    return events;
  }

  Future deleteEvent(key) async {
    await _deleteFile(key);
    events.remove(key);
  }

  void updateEvent(String folderId, TimelineEvent cloudCopy) {
    events.update(folderId, (value) => cloudCopy);
  }

  @override
  Future sendComment(EventContent event, EventComment comment) async {
    return _uploadCommentsFile(event, comment);
  }

  Future<String> _uploadCommentsFile(
      EventContent event, EventComment comment) async {
    print('1 ${event.commentsID}');
    EventComments comments =
        EventComments.fromJson(await getJsonFile(event.commentsID));
    if (comments == null) {
      comments = EventComments();
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

  @override
  Future<StorageInformation> getStorageInformation() async {
    About about = await driveApi.about.get($fields: 'storageQuota');

    return StorageInformation(
      limit: formatBytes(about.storageQuota.limit, 0),
      usage: formatBytes(about.storageQuota.usage, 0)
    );
  }

  @override
  void sendToChangeProfile() {
    html.window.open("https://myaccount.google.com/personal-info", 'Account');
  }

  @override
  void sendToUpgrade() {
    html.window.open("https://one.google.com/about/plans", 'Upgrade');
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
