import 'package:flutter/material.dart';
import 'package:tome/createtome.dart';
import 'package:tome/homepage.dart';
import 'package:tome/loadtome.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/settings.dart';
import 'package:tome/splashscreen.dart';
import 'package:tome/tomepage.dart';

void main() {
  runApp(const MyApp());
}

enum Routes{
  homepage,
  tomepage,
  createtome,
  loadtome,
  settings
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
        Routes.homepage.name: (context) => Homepage.fromArgs(getArgs(context) as HomePageArgs),
        Routes.tomepage.name: (context) => TomePage.fromArgs(getArgs(context) as TomePageArgs),
        Routes.createtome.name: (context) => CreateTome.fromArgs(getArgs(context) as CreateTomeArgs),
        Routes.loadtome.name: (context) => LoadTome.fromArgs(getArgs(context) as LoadTomeArgs),
        Routes.settings.name: (context) => Settings.fromArgs(getArgs(context) as SettingsArgs)
      },
      home: Homepage(db: db,)
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