import 'package:tome/logic/jsonable.dart';

class Tome extends Jsonable{
  final String title;
  final String? image;

  const Tome({required this.title, this.image}) : super(key: title);

  @override
  Map<String, String> toJson(){
    return <String, String>{
      'title': title,
      'image': image ?? ""
    };
  }
}