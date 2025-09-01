import 'package:tome/logic/jsonable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart' as sb;

enum DbCollections{
  tomes
}

class Database{
  final sb.Database _db;
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
    String docId = "${path.name}\\${jsonable.key}";
    sb.StoreRef<String, String> store = sb.StoreRef<String, String>.main();
    String? sameIdDoc = await store.record(docId).get(_db);
    if(sameIdDoc != null){
      //_log.warning('Warning: same id doc already existing');
      return null;
    }
    String jsonStr = jsonable.toJson().toString();
    return store.record(docId).put(_db, jsonStr);
  }

  Future<String?> readJson(DbCollections path, String key){
    String docId = "${path.name}\\$key";
    sb.StoreRef<String, String> store = sb.StoreRef<String, String>.main();
    return Future.delayed(Duration(seconds: 3)).then((v){
      return store.record(docId).get(_db);
    });
  }

  Future<void> cleanDb(){
    var store = sb.StoreRef.main();
    return store.drop(_db);
  }
}