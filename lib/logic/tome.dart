import 'package:tome/logic/jsonable.dart';
import 'package:tome/logic/landmark.dart';

class Tome extends Jsonable{
  final String title;
  final String? image;
  late List<Landmark> landmarks;

  Tome({required this.title, this.image, List<Landmark>? landmarks}) 
  : landmarks = landmarks ?? List<Landmark>.empty(growable: true), super(key: title);
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