import 'package:flutter/material.dart';
import 'package:tome/homepage.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/main.dart';

class SettingsArgs{
  final Database db;
  const SettingsArgs({required this.db});
}

class Settings extends StatelessWidget{
  final Database db;
  const Settings({super.key, required this.db});
  static Settings fromArgs(SettingsArgs args){
    return Settings(db: args.db,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Impostazioni'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: TextButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.homepage.name,
              (route){return !Navigator.of(context).canPop();},
              arguments: HomePageArgs(db: db)),
            child: Text('Torna al menù')
            )
          )
        ],
      ),
    );
  }
}