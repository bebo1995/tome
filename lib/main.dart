import 'package:flutter/material.dart';
import 'package:tome/homepage.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/splashscreen.dart';
import 'package:tome/tomepage.dart';

void main() {
  runApp(const MyApp());
}

enum Routes{
  homepage,
  tomepage
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Object? getArgs(BuildContext context){
    return ModalRoute.of(context)!.settings.arguments;
  }

  Widget buildApp(Database db){
    final String appTitle = 'Tome';
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        Routes.homepage.name: (context) => Homepage(title: (getArgs(context) as HomePageArgs).title, db: (getArgs(context) as HomePageArgs).db),
        Routes.tomepage.name: (context) => TomePage(db: (getArgs(context) as TomePageArgs).db),
      },
      home: Homepage(title: appTitle, db: db,)
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // load the database before loading entire app
    return FutureBuilder(
      future: Database.getInstance(),
      builder: (BuildContext context, AsyncSnapshot<Database> dbSnapshot){
        if (dbSnapshot.connectionState == ConnectionState.waiting){
          return Splashscreen();
        }
        else{
          if(dbSnapshot.hasData){
            return buildApp(dbSnapshot.data!);
          }
          else{
            //log error: error loading documents folder
            return Splashscreen();
          }
        }
    });
  }
}