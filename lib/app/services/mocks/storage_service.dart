import 'dart:async';
import 'dart:typed_data';

import 'package:web/app/services/dialog_service.dart';
import 'package:web/app/services/storage_service.dart';
import 'package:web/ui/widgets/event_comments.dart';
import 'package:web/ui/widgets/timeline_card.dart';

class MockStorageService implements StorageService {
  Map<String, TimelineEvent> events;
  Map<String, Uint8List> images;

  Future initialize() async {
    images = Map();
  }

  Uint8List getLocalImage(String imageURL) {
    if (images.containsKey(imageURL)) {
      return images[imageURL];
    }
    return null;
  }

  Future<String> getMediaFolder(
      StreamController<DialogStreamContent> streamController) async {
    streamController.close();
    return "";
  }

  Future<String> getPermissions(String folderID) async {
    return null;
  }

  Future<String> shareFolder(String folderID) async {
    return "";
  }

  Future stopSharingFolder(String folderID, String permissionID) async {}

  Future<Map<String, TimelineEvent>> getEventsFromFolder(String folderID,
      StreamController<DialogStreamContent> streamController) async {
    if (events != null && events.length > 0) {
      streamController.close();
      return events;
    }

    try {
      events = Map();
      return events;
    } catch (e) {
      print('error: $e');
      return null;
    } finally {
      streamController.close();
    }
  }

  Future<EventContent> createEventFolder(
      String parentId, int timestamp, bool mainEvent) async {
    try {
      EventContent event = EventContent(
          folderID: "12345",
          timestamp: timestamp,
          description: '',
          title: '',
          subEvents: List(),
          images: Map());

      if (mainEvent) {
        TimelineEvent timelineEvent =
            TimelineEvent(mainEvent: event, subEvents: []);
        events.putIfAbsent("12345", () => timelineEvent);
      }

      return event;
    } catch (e) {
      print('error: $e');
      return null;
    }
  }

  Future<dynamic> getJsonFile(String settingsFile) async {
    EventSettings event = EventSettings();
    return event;
  }

  Future<TimelineEvent> getViewEvent(String folderID) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (timestamp == null) {
      print(timestamp);
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
    Map<String, EventImage> images = Map();
    images.putIfAbsent(
        "logo", () => EventImage(imageURL: "assets/images/logo.png"));
    List<SubEvent> subEvents = List();

    EventSettings settings = EventSettings();

    print("settings ${settings.title}");
    return EventContent(
        timestamp: timestamp,
        title: settings.title,
        images: images,
        description: settings.description,
        folderID: folderID,
        settingsID: "settings",
        subEvents: subEvents);
  }

  Future syncDrive(StreamController streamController, EventContent localCopy,
      EventContent cloudCopy) async {
    cloudCopy.images.addAll(localCopy.images);
    cloudCopy.images.forEach((key, value) {
      images.putIfAbsent(key, () => value.bytes);
    });

    return Future.delayed(new Duration(milliseconds: 10), () {});
  }

  Map<String, TimelineEvent> getEvents() {
    return events;
  }

  Future deleteEvent(key) async {
    events.remove(key);
  }

  void updateEvent(String folderId, TimelineEvent cloudCopy) {
    events.update(folderId, (value) => cloudCopy);
  }

  @override
  Future<Uint8List> getImage(String imageURL) {
    throw UnimplementedError();
  }

  @override
  Future sendComment(EventContent event, EventComment comment) {
    throw UnimplementedError();
  }
}
