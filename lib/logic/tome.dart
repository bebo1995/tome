import 'package:tome/logic/jsonable.dart';

class Tome extends Jsonable{
  final String title;
  final String? image;

  const Tome({required this.title, this.image}) : super(key: title);
  static Tome? fromJson(Map<String, String?> json){
    if(!json.containsKey('title')){
      return null;
    }
    String title = json['title']!;
    String? image = json['image'];
    return Tome(title: title, image: image);
  }

  @override
  Map<String, String?> toJson(){
    return <String, String?>{
      'title': title,
      'image': image
    };
  }
}