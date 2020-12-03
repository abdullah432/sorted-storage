
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/images/images_event.dart';

class ImagesBloc extends Bloc<ImagesEvent, Uint8List> {
  Map<String, Uint8List> images;
  DriveApi driveApi;

  ImagesBloc(this.driveApi) : super(null) {
    images = Map();
  }

  @override
  Stream<Uint8List> mapEventToState(ImagesEvent event) async* {
    if (event is GetImagesEvent){
      yield await getImage(event.imageURL);
    }
  }

  Future<Uint8List> getImage(String key) async {
    if (images.containsKey(key)) {
      return images[key];
    }

    Media mediaFile = await driveApi.files
        .get(key, downloadOptions: DownloadOptions.FullMedia);

    List<int> dataStore = [];
    await for (var data in mediaFile.stream) {
      print('receiving ${data.length}');
      dataStore.insertAll(dataStore.length, data);
    }
    Uint8List image = Uint8List.fromList(dataStore);
    images.putIfAbsent(key, () => image);
    return image;
  }

}