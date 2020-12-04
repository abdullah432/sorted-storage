import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/adventure/adventure_event.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class UploadImageReturn {
  String id;
  EventImage image;

  UploadImageReturn(this.id, this.image);
}

class AdventureBloc extends Bloc<AdventureEvent, TimelineData> {
  TimelineData localCopy;
  TimelineData cloudCopy;
  DriveApi driveApi;
  TimelineData viewTimeline;

  AdventureBloc({this.cloudCopy}) : super(cloudCopy) {
    if (this.cloudCopy != null) {
      this.localCopy = TimelineData.clone(cloudCopy);
    }
  }

  @override
  Stream<TimelineData> mapEventToState(AdventureEvent event) async* {
    if (event is AdventureNewDriveEvent) {
      this.driveApi = event.driveApi;
    }
    if (event is AdventureUpdatedEvent) {
      yield TimelineData.clone(cloudCopy);
    }
    if (event is AdventureCancelEvent) {
      yield TimelineData.clone(cloudCopy);
    }
    if (event is AdventureSaveEvent) {
      _syncCopies();
    }
    if (event is AdventureEditEvent) {
      localCopy.locked = false;
      TimelineData copy = TimelineData.clone(localCopy);
      yield copy;
    }
    if (event is AdventureDeleteSubAdventureEvent) {
      localCopy.subEvents.removeAt(event.index);
      yield TimelineData.clone(localCopy);
    }
    if (event is AdventureCreateSubAdventureEvent) {
      localCopy.subEvents.add(
        EventContent(
            folderID: "temp_" + localCopy.subEvents.length.toString(),
            timestamp: localCopy.mainEvent.timestamp,
            images: Map(),
            comments: AdventureComments(
              comments: List()
            ),
            subEvents: List(),
        )
      );
      yield TimelineData.clone(localCopy);
    }
    if (event is AdventureCommentEvent) {
      TimelineData timelineEvent = event.event;
      EventContent eventContent = _getEvent(event.folderID, timelineEvent);
      await _sendComment(eventContent, event.comment);
      yield TimelineData.clone(timelineEvent);
    }

    if (event is AdventureRemoveImageEvent) {
      EventContent eventContent = _getEvent(event.folderID, localCopy);
      eventContent.images.remove(event.imageKey);
      yield TimelineData.clone(localCopy);
    }
    if (event is AdventureAddMediaEvent) {
      EventContent eventContent = _getEvent(event.folderID, localCopy);
      var file = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
          withData: true);
      if (file.files == null || file.files.length == 0) {
        return;
      }
      file.files.forEach((element) {
        print('inserting image ${element.name}');
        eventContent.images.putIfAbsent(element.name,
                () => EventImage(bytes: element.bytes));
      });
      yield TimelineData.clone(localCopy);
    }

    if (event is AdventureEditTitleEvent) {
      _getEvent(event.folderID, localCopy).title = event.title;
    }

    if (event is AdventureEditDescriptionEvent) {
      _getEvent(event.folderID, localCopy).description = event.description;
    }

    if (event is AdventureGetViewEvent) {
      if (viewTimeline == null) {
        viewTimeline = TimelineData();
        viewTimeline = await _getViewEvent(event.folderID);
        yield viewTimeline;
      }
    }
  }


  Future<TimelineData> _getViewEvent(String folderID) async {
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

    return TimelineData(mainEvent: mainEvent, subEvents: subEvents);
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

    AdventureSettings settings =
    AdventureSettings.fromJson(await getJsonFile(settingsID));

    AdventureComments comments =
    AdventureComments.fromJson(await getJsonFile(commentsID));

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



  EventContent _getEvent(String folderID, TimelineData timelineEvent) {
    if (timelineEvent.mainEvent.folderID == folderID) {
      return timelineEvent.mainEvent;
    } else {
      return timelineEvent.subEvents.singleWhere((element) => element.folderID ==
              folderID);
    }
  }

  Future<EventContent> _createEventFolder() async {
    try {
      File eventToUpload = File();
      eventToUpload.parents = [cloudCopy.mainEvent.folderID];
      eventToUpload.mimeType = "application/vnd.google-apps.folder";
      eventToUpload.name = cloudCopy.mainEvent.timestamp.toString();

      var folder = await driveApi.files.create(eventToUpload);
      return EventContent(
          comments: AdventureComments(comments: List()),
          folderID: folder.id,
          timestamp: cloudCopy.mainEvent.timestamp,
          subEvents: List(),
          images: Map());
    } catch (e) {
      print('error: $e');
      return null;
    }
  }

  _syncCopies() async {
    for (EventContent subEvent in localCopy.subEvents) {
      EventContent cloudSubEvent;
      if (subEvent.folderID.startsWith("temp_")){
        print('found local subevent');
        cloudSubEvent = await _createEventFolder();
        cloudCopy.subEvents.add(cloudSubEvent);
        subEvent.folderID = cloudSubEvent.folderID;
      } else {
        cloudSubEvent = cloudCopy.subEvents
            .singleWhere((element) => element.folderID == subEvent.folderID);
      }

      await _syncContent(subEvent, cloudSubEvent);
    }

    List<EventContent> eventsToDelete = List();
    for (EventContent subEvent in cloudCopy.subEvents) {
      EventContent localEvent;
      for (int i = 0; i < localCopy.subEvents.length; i++) {
        if (subEvent.folderID == localCopy.subEvents[i].folderID) {
          localEvent = localCopy.subEvents[i];
          break;
        }
      }
      if (localEvent == null) {
        await _deleteFile(subEvent.folderID);
        eventsToDelete.add(subEvent);
      }
    }

    for (EventContent subEvent in eventsToDelete) {
      cloudCopy.subEvents.remove(subEvent);
    }

    await _syncContent(localCopy.mainEvent, cloudCopy.mainEvent);
    localCopy = TimelineData.clone(cloudCopy);
    print(localCopy.mainEvent.images);

    this.add(AdventureUpdatedEvent());
  }

  Future _syncContent(EventContent localCopy, EventContent cloudCopy) async {
    List<Future> tasks = List();

    print('updating cloud storage');
    if (localCopy.timestamp != cloudCopy.timestamp) {
      tasks.add(
          _updateEventFolderTimestamp(localCopy.folderID, localCopy.timestamp)
              .then((value) {
        cloudCopy.timestamp = localCopy.timestamp;
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
      }, onError: (error) {
        print('error $error');
      }));
    }

    Map<String, EventImage> imagesToAdd = Map();
    List<String> imagesToDelete = [];
    if (localCopy.images != null) {
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

  Future _deleteFile(String fileId) async {
    return await driveApi.files.delete(fileId);
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
      // images.putIfAbsent(response.id, () => imageBytes);
      return UploadImageReturn(response.id, EventImage(bytes: imageBytes));
    });
  }

  Future _sendComment(EventContent event, AdventureComment comment) async {
    AdventureComments comments = AdventureComments.fromJson(await getJsonFile(event.commentsID));
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
      Permission anyone = Permission();
      anyone.type = "anyone";
      anyone.role = "writer";

      await driveApi.permissions.create(anyone, folder.id);
    } else {
      folder = await driveApi.files.update(null, event.commentsID,
          uploadMedia: Media(mediaStream, fileContent.length));
    }

    event.comments = comments;
    event.commentsID = folder.id;
    return folder.id;
  }
}
