
import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';

class SharingBloc extends Bloc<ShareEvent, bool> {
  String folderID;
  DriveApi driveApi;
  String permissionID;

  SharingBloc(this.driveApi, this.folderID) : super(null) {
    this.add(InitialEvent());
  }

  @override
  Stream<bool> mapEventToState(ShareEvent event) async* {
    if (event is InitialEvent){
      yield await _getPermissions();
    }
    if (event is StartSharingEvent){
      yield await _shareFolder();
    }
    if (event is StopSharingEvent){
      yield await _stopSharingFolder();
    }
  }

  Future<bool> _getPermissions() async {
    PermissionList list = await driveApi.permissions.list(folderID);

    for (Permission permission in list.permissions) {
      if (permission.type == "anyone" && permission.role == "reader") {
        permissionID = permission.id;
        return true;
      }
    }
    return false;
  }

  Future<bool> _shareFolder() async {
    return _shareFile(folderID, "anyone", "reader");
  }

  Future<bool> _shareFile(String fileID, String type, String role) async {
    Permission anyone = Permission();
    anyone.type = type;
    anyone.role = role;

    Permission permission = await driveApi.permissions.create(anyone, fileID);
    permissionID = permission.id;
    return true;
  }

  Future<bool> _stopSharingFolder() async {
    await driveApi.permissions.delete(folderID, permissionID);
    return false;
  }

}