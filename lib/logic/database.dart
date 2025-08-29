import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:mastertome/logic/jsonable.dart';

enum DbCollections{
  tomes
}

class Database{
  final FlutterSecureStorage _storage;
  final Logger _log;
  static final Database _singleton = Database._internal(FlutterSecureStorage(), Logger("Database"));
  
  factory Database() {
    return _singleton;
  }
  
  Database._internal(this._storage, this._log);

  Future<String?> createJson(Jsonable jsonable, DbCollections path) async {
    String docId = path.name + jsonable.key;
    String? sameIdDoc = await _storage.read(key: docId);
    if(sameIdDoc != null){
      _log.warning('Warning: same id doc already existing');
      return null;
    }
    String jsonStr = jsonable.toJson().toString();
    _storage.write(key: jsonable.key, value: jsonStr);
    return jsonStr;
  }

  Future<String?> readJson(String path, String key){
    String docId = path + key;
    return _storage.read(key: docId);
  }
}