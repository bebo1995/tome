import 'package:flutter/material.dart';
import 'package:tome/createtome.dart';
import 'package:tome/loadtome.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/main.dart';

class HomePageArgs{
  final Database db;
  const HomePageArgs({required this.db});
}

class Homepage extends StatelessWidget{
  final Database db;
  const Homepage({super.key, required this.db});
  static Homepage fromArgs(HomePageArgs args){
    return Homepage(db: args.db,);
  }

  void createTome(BuildContext context){
    Navigator.pushNamed(context, Routes.createtome.name, arguments: CreateTomeArgs(db: db));
  }

  void loadTome(BuildContext context){
    Navigator.pushNamed(context, Routes.loadtome.name, arguments: LoadTomeArgs(db: db));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Tome'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(onPressed: (){createTome(context);}, child: Text("Nuovo tomo")),
            TextButton(onPressed: (){loadTome(context);}, child: Text("Carica tomo")),
            TextButton(onPressed: (){db.cleanDb();}, child: Text("Reset"))
          ],
        ),
      ),
    );
  }
}