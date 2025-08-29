import 'package:flutter/material.dart';
import 'package:mastertome/logic/database.dart';
import 'package:mastertome/logic/tome.dart';
import 'package:mastertome/main.dart';

class HomePageArgs{
  final String title;
  const HomePageArgs({required this.title});
}

class Homepage extends StatelessWidget{
  final String title;
  const Homepage({super.key, required this.title});

  void createTome(){
    String tomeTitle = 'newtome';
    Tome newTome = Tome(key: tomeTitle, title: tomeTitle);
    Database db = Database();
    db.createJson(newTome, DbCollections.tomes);
  }

  void loadTome(BuildContext context){
    Navigator.pushNamed(context, Routes.tomepage.name);
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