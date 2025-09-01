import 'package:flutter/material.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/logic/tome.dart';
import 'package:tome/main.dart';
import 'package:tome/tomepage.dart';

class HomePageArgs{
  final String title;
  final Database db;
  const HomePageArgs({required this.title, required this.db});
}

class Homepage extends StatelessWidget{
  final String title;
  final Database db;
  const Homepage({super.key, required this.title, required this.db});

  void createTome(){
    String tomeTitle = 'newtome';
    Tome newTome = Tome(key: tomeTitle, title: tomeTitle);
    db.createJson(newTome, DbCollections.tomes);
  }

  void loadTome(BuildContext context){
    Navigator.pushNamed(context, Routes.tomepage.name, arguments: TomePageArgs(db: db));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(onPressed: createTome, child: Text("Nuovo tomo")),
            TextButton(onPressed: (){loadTome(context);}, child: Text("Carica tomo"))
          ],
        ),
      ),
    );
  }
}