import 'package:mastertome/logic/jsonable.dart';

class Tome extends Jsonable{
  final String title;
  final String? image;

  const Tome({required super.key, required this.title, this.image});

  @override
  Map<String, String> toJson(){
    return <String, String>{
      'title': title,
      'image': image ?? ""
    };
  }
}