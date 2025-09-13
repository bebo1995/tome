import 'package:flutter/widgets.dart';
import 'package:tome/logic/jsonable.dart';

class Tome extends Jsonable{
  final String title;
  final String? image;
  late List<Offset> landmarks;

  Tome({required this.title, this.image, List<Offset>? landmarks}) 
  : landmarks = landmarks ?? List<Offset>.empty(growable: true), super(key: title);
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