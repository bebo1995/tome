import 'dart:convert';

import 'package:tome/logic/jsonable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart' as sb;

enum DbCollections{
  tomes
}

class Database{
  final sb.Database _db;
  final String separator = '\\';
  Database._(this._db);

  static Future<Database> getInstance() async{
    // get the application documents directory. Database will be placed in there
    final dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    final dbPath = join(dir.path, 'tome_db.db');
    // open the database
    return Database._(await sb.databaseFactoryIo.openDatabase(dbPath));
  }

  Future<String?> createJson(Jsonable jsonable, DbCollections path) async {
    String docId = "${path.name}$separator${jsonable.key}";
    sb.StoreRef<String, String> store = sb.StoreRef<String, String>.main();
    String? sameIdDoc = await store.record(docId).get(_db);
    if(sameIdDoc != null){
      //_log.warning('Warning: same id doc already existing');
      return null;
    }
    String jsonStr =  json.encode(jsonable.toJson());
    return store.record(docId).put(_db, jsonStr);
  }

  Map<String, String?>? _mapFromJson(String? jsonStr){
    if(jsonStr == null){
      return null;
    }
    Map? map = json.decode(jsonStr);
    return Map<String, String?>.from(map!);
  }

  Future<Map<String, String?>?> readJson(DbCollections path, String key) async{
    String docId = "${path.name}$separator$key";
    sb.StoreRef<String, String> store = sb.StoreRef<String, String>.main();
    String? jsonStr = await store.record(docId).get(_db);
    return _mapFromJson(jsonStr);
  }

  Future<List<Map<String, String?>>?> readCollection(DbCollections path) async{
    sb.StoreRef<String, String> store = sb.StoreRef<String, String>.main();
    sb.Filter searchFilter = sb.Filter.custom((snapshot){
      String key = snapshot.key as String;
      List<String> keyTokens = key.split(separator);
      if(keyTokens.isEmpty){
        return false;
      }
      if(keyTokens[0] == path.name){
        return true;
      }
      return false;
    });
    List<sb.RecordSnapshot<String, String>> results = await store.find(_db, finder: sb.Finder(filter: searchFilter));
    return results.map((snapshot){
      return _mapFromJson(snapshot.value);
    }).nonNulls.toList();
  }

  Future<String?> deleteJson(DbCollections path, String key){
    String docId = "${path.name}$separator$key";
    sb.StoreRef<String, String> store = sb.StoreRef<String, String>.main();
    return store.record(docId).delete(_db);
  }

  Future<void> cleanDb(){
    var store = sb.StoreRef.main();
    return store.drop(_db);
  }
}