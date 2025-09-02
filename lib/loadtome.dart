import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/logic/tome.dart';
import 'package:tome/main.dart';
import 'package:tome/tomepage.dart';

class LoadTomeArgs{
  final Database db;
  const LoadTomeArgs({required this.db});
}

class LoadTome extends StatefulWidget{
  final Database db;
  const LoadTome({super.key, required this.db});
  static LoadTome fromArgs(LoadTomeArgs args){
    return LoadTome(db: args.db);
  }

  @override
  State<StatefulWidget> createState() => LoadTomeState();
}

class LoadTomeState extends State<LoadTome>{

  Widget delDbProgressIndicator(BuildContext context){
    Size size = MediaQuery.of(context).size;
    double mindim = min(size.width, size.height);
    return Center(
      child: SizedBox(
        height: mindim / 2,
        width: mindim / 2,
        child: CircularProgressIndicator(),
      ),
    );
  }

  void loadTome(Tome tome){
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.tomepage.name,
      (route){return !Navigator.of(context).canPop();},
      arguments: TomePageArgs(db: widget.db, tome: tome));
  }

  void deleteTome(Tome tome) async{
    BuildContext ctxt = context;
    showDialog(context: ctxt, barrierDismissible: false, builder: (context){
      return AlertDialog(
        content: delDbProgressIndicator(context)
      );
    });
    String? res = await widget.db.deleteJson(DbCollections.tomes, tome.key);
    if(!ctxt.mounted){
      return;
    }
    Navigator.of(ctxt).pop();
    if(res != null){
      setState(() {});
    }
  }

  Widget tomeWidget(Tome tome, double height){
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(child: Text(tome.title)),
          Expanded(child: 
            Row(children: [
              TextButton(
                child: Text('Carica'),
                onPressed: () => loadTome(tome),
              ), 
              TextButton(
                child: Text('Elimina'),
                onPressed: () => deleteTome(tome), 
              )
            ],),)
        ],
      ),
    );
  }

  Widget tomesList(List<Tome> tomes){
    Size screenSize = MediaQuery.of(context).size;
    double tomeHeight = screenSize.height * 0.1;
    return ListView.builder(
      itemCount: tomes.length,
      itemBuilder: (context, ix){
        return tomeWidget(tomes[ix], tomeHeight);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carica Tomo'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, String?>>?>(
        future: widget.db.readCollection(DbCollections.tomes), 
        builder: (context, AsyncSnapshot<List<Map<String, String?>>?> snapshot){
          if( snapshot.connectionState == ConnectionState.none || snapshot.connectionState == ConnectionState.waiting ){
            return Center(child: CircularProgressIndicator(),);
          }
          List<Tome> tomes = snapshot.data!.map((json) => Tome.fromJson(json),).nonNulls.toList();
          return tomesList(tomes);
        })
    );
  }
}