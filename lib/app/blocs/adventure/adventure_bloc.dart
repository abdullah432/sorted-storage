import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:mime/mime.dart';
import 'package:web/app/blocs/adventure/adventure_event.dart';
import 'package:web/app/blocs/adventure/adventure_state.dart';
import 'package:web/app/models/adventure.dart';
import 'package:web/constants.dart';
import 'package:web/ui/widgets/timeline_card.dart';


class TimelineDataSearchResponse {
  final EventContent eventContent;
  final int index;

  TimelineDataSearchResponse({this.eventContent, this.index});
}
class UploadImageReturn {
  String id;
  StoryMedia image;

  UploadImageReturn(this.id, this.image);
}

class AdventureBloc extends Bloc<AdventureEvent, AdventureState> {
  TimelineData localCopy;
  TimelineData cloudCopy;
  DriveApi driveApi;
  TimelineData viewTimeline;
  List<List<String>> uploadingImages;

  AdventureBloc({this.cloudCopy}) : super(null) {
    if (this.cloudCopy != null) {
      this.localCopy = TimelineData.clone(cloudCopy);
      _populateList(this.localCopy);
    }
  }

  _populateList(TimelineData data) {
    uploadingImages = List();
    uploadingImages.add(List());
    for (int i = 0; i< data.subEvents.length; i++) {
      uploadingImages.add(List());
    }
  }

  @override
  Stream<AdventureState> mapEventToState(AdventureEvent event) async* {
    if (event is AdventureUpdatedUploadedImagesEvent){
      yield AdventureUploadingState(uploadingImages);
    }
    if (event is AdventureNewDriveEvent) {
      this.driveApi = event.driveApi;
    }
    if (event is AdventureUpdatedEvent) {
      yield AdventureNewState(cloudCopy, uploadingImages);
    }
    if (event is AdventureCancelEvent) {
      localCopy = TimelineData.clone(cloudCopy);
      yield AdventureNewState(cloudCopy, uploadingImages);
    }
    if (event is AdventureSaveEvent) {
      _syncCopies();
    }
    if (event is AdventureEditEvent) {
      localCopy.locked = false;
      TimelineData copy = TimelineData.clone(localCopy);
      _populateList(copy);
      yield AdventureNewState(copy, uploadingImages);
    }
    if (event is AdventureDeleteSubAdventureEvent) {
      localCopy.subEvents.removeAt(event.index);
      uploadingImages.removeAt(event.index + 1);
      yield AdventureNewState(localCopy, uploadingImages);
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
      uploadingImages.add(List());
      yield AdventureNewState(localCopy, uploadingImages);
    }
    if (event is AdventureCommentEvent) {
      TimelineData timelineEvent = event.event;
      EventContent eventContent = _getTimelineData(event.folderID, timelineEvent).eventContent;
      await _sendComment(eventContent, event.comment);
      _populateList(timelineEvent);
      yield AdventureNewState(timelineEvent, uploadingImages);
    }

    if (event is AdventureRemoveImageEvent) {
      EventContent eventContent = _getTimelineData(event.folderID, localCopy).eventContent;
      eventContent.images.remove(event.imageKey);
      yield AdventureNewState(localCopy, uploadingImages);
    }
    if (event is AdventureAddMediaEvent) {
      print(event.folderID);
      print(event);
      var timelineDataSearchResponse = _getTimelineData(event.folderID, localCopy);
      EventContent eventContent = timelineDataSearchResponse.eventContent;
      print(eventContent);
      print(timelineDataSearchResponse.index);
      print(localCopy.subEvents.length);

      FilePickerResult file;
      try {
        file = await FilePicker.platform.pickFiles(
            type: FileType.media,
            allowMultiple: true,
            withReadStream: true);
      } catch (e) {
        print(e);
        return;
      }
      if (file == null || file.files == null || file.files.length == 0) {
        return;
      }
      for (int i = 0; i < file.files.length; i++) {
        PlatformFile element = file.files[i];
        print(element.extension);
        print(element.size);
        String mime = lookupMimeType(element.name);
        if (mime.startsWith("image/")) {
          Uint8List bytes = await getBytes(element.readStream);
          eventContent.images.putIfAbsent(element.name,
                  () => StoryMedia(bytes: bytes, isImage: true, size: element.size));
        } else {
          // TODO generate thumbnail
          ByteData bytes = await rootBundle.load('assets/images/placeholder.png');
          eventContent.images.putIfAbsent(element.name,
                  () => StoryMedia(bytes: bytes.buffer.asUint8List(),
                      stream: element.readStream, size: element.size, isImage: false));
        }
        print(uploadingImages);
        print(timelineDataSearchResponse.index);
        print(uploadingImages[timelineDataSearchResponse.index]);
        uploadingImages[timelineDataSearchResponse.index].add(element.name);

        print('1 inserting image ${element.name}');
        print('2 inserting image ${uploadingImages.toString()}');
        print('3 inserting image ${uploadingImages[timelineDataSearchResponse.index].toList()}');
      }
      yield AdventureNewState(localCopy, uploadingImages);
    }

    if (event is AdventureEditTitleEvent) {
      _getTimelineData(event.folderID, localCopy).eventContent.title = event.title;
    }

    if (event is AdventureEditDescriptionEvent) {
      _getTimelineData(event.folderID, localCopy).eventContent.description = event.description;
    }

    if (event is AdventureGetViewEvent) {
      if (viewTimeline == null) {
        viewTimeline = TimelineData();
        viewTimeline = await _getViewEvent(event.folderID);
        _populateList(viewTimeline);
        yield AdventureNewState(viewTimeline, uploadingImages);
      }
    }
  }

  Future<Uint8List> getBytes(Stream<List<int>> stream) async {
    List<int> bytesList = List();
    await for (List<int> bytes in stream) {
      bytesList.addAll(bytes);
    }
    return Uint8List.fromList(bytesList);
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
    Map<String, StoryMedia> images = Map();
    List<SubEvent> subEvents = List();
    for (File file in textFileList.files) {
      if ((file.mimeType.startsWith("image/") ||
          file.mimeType.startsWith("video/")) ) {
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

  TimelineDataSearchResponse _getTimelineData(String folderID, TimelineData timelineEvent) {
    EventContent content;
    int index = -1;
    if (timelineEvent.mainEvent.folderID == folderID) {
      content = timelineEvent.mainEvent;
      index = 0;
    } else {
      for (int i = 0; i < timelineEvent.subEvents.length; i++) {
        EventContent element = timelineEvent.subEvents[i];
        if (element.folderID == folderID) {
          content = element;
          index = i + 1;
          break;
        }
      }
    }
    return TimelineDataSearchResponse(
      eventContent: content,
      index: index
    );
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
    for (int i = 0; i < localCopy.subEvents.length; i++) {
      EventContent subEvent = localCopy.subEvents[i];
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

      await _syncContent(i, subEvent, cloudSubEvent);
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

    await _syncContent(0, localCopy.mainEvent, cloudCopy.mainEvent);
    localCopy = TimelineData.clone(cloudCopy);
    print(localCopy.mainEvent.images);

    this.add(AdventureUpdatedEvent());
  }

  Future _syncContent(int eventIndex, EventContent localCopy, EventContent cloudCopy) async {
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

    Map<String, StoryMedia> imagesToAdd = Map();
    List<String> imagesToDelete = [];
    if (localCopy.images != null) {
      print('uploading ${localCopy.images.length}');

      // TODO: progress bar and elegant way sending images
      int batchLength = 2;
      for (int i = 0; i < localCopy.images.length; i += batchLength) {
        for (int j = i;
            j < i + batchLength && j < localCopy.images.length;
            j++) {
          MapEntry<String, StoryMedia> image =
              localCopy.images.entries.elementAt(j);
          if (!cloudCopy.images.containsKey(image.key)) {

            this.add(AdventureUpdatedUploadedImagesEvent());
            tasks.add(_uploadMediaToFolder(
                    cloudCopy, image.key, image.value, 10)
                .then((uploadResponse) {
              // this causes a bug
              uploadingImages[eventIndex].remove(image.key);
              this.add(AdventureUpdatedUploadedImagesEvent());

                  if(uploadResponse != null) {

                    imagesToAdd.putIfAbsent(
                        uploadResponse.id, () => uploadResponse.image);
                  } else {
                    print('uploadResponse $uploadResponse');
                  }

              print('uploaded this image: ${image.key}');
            }, onError: (error) {
              print('error $error');
            }));
            print('created request $i');
          }
        }
      }

      for (MapEntry<String, StoryMedia> image in cloudCopy.images.entries) {
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
      String imageName, StoryMedia storyMedia, int delayMilliseconds) async {
    print('converting to list');
    Stream<List<int>> dataStream;
    if (storyMedia.isImage) {
      dataStream = Future.value(storyMedia.bytes.toList()).asStream();
    }else {
      dataStream = storyMedia.stream;
    }

    File originalFileToUpload = File();
    originalFileToUpload.parents = [eventContent.folderID];
    originalFileToUpload.name = imageName;
    Media image = Media(dataStream, storyMedia.size);

    var uploadMedia = await driveApi.files
        .create(originalFileToUpload, uploadMedia: image);

    return UploadImageReturn(uploadMedia.id, storyMedia);
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
