import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/logic/tome.dart';
import 'package:tome/main.dart';
import 'package:tome/logic/tomemap.dart';
import 'package:tome/settings.dart';

enum TomepageMode{
  base,
  landmarkMove
}

class TomePageArgs{
  final Database db;
  final Tome tome;
  const TomePageArgs({required this.db, required this.tome});
}

class TomePage extends StatefulWidget {
  final Database db;
  final Tome tome;
  const TomePage({super.key, required this.db, required this.tome});
  static TomePage fromArgs(TomePageArgs args){
    return TomePage(db: args.db, tome: args.tome);
  }

  @override
  State<StatefulWidget> createState() => _TomePageState();
}

class _TomePageState extends State<TomePage> {

  Widget button(void Function()? onPressed, Icon icon) {
    return Expanded(
      child: Center(
        child: IconButton(onPressed: onPressed, icon: icon),
      ),
    );
  }

  Offset? createLocation(GlobalKey landKey){
    BuildContext? landContext = landKey.currentContext;
    if(landContext == null){
      return null;
    }
    RenderBox box = landContext.findRenderObject() as RenderBox;
    Size landSize = box.size;
    Offset position = Offset(landSize.width/2, landSize.height/2);
    return position;
  }


  Widget baseButtons(StreamController<TomepageMode> modeStream, TomeMap map, GlobalKey mapKey){
    //TODO: enable landmark selection
    return Row(
      children: [
        button(() => {}, Icon(Icons.book)),
        button(() => {}, Icon(Icons.add_photo_alternate)),
        button((){
          modeStream.add(TomepageMode.landmarkMove);
          Offset newLocation = createLocation(mapKey)!;
          map.createLandmark(newLocation);
          }, Icon(Icons.add_location)),
      ],
    );
  }

  Widget landmarkConfirmButtons(StreamController<TomepageMode> modeStream, TomeMap map){
    return Row(
      children: [
        button((){
          map.cancelLandmarks();
          modeStream.add(TomepageMode.base);
        }, Icon(Icons.arrow_back)),
        button((){
          map.confirmLandmarks();
          for(Offset landmark in map.getCurrentLandmarks()){
            if(!widget.tome.landmarks.contains(landmark)){
              widget.tome.landmarks.add(landmark);
            }
          }
          modeStream.add(TomepageMode.base);
        }, 
        Icon(Icons.check)),
      ],
    );
  }

  Widget tomepageBody(GlobalKey mapKey, Widget buttons, TomeMap map){
    return Column(
      children: [
        Expanded(flex: 90, key: mapKey, child: map.getWidget(context)), 
        Expanded(flex: 10, child: buttons)],
    ); 
  }

  @override
  Widget build(BuildContext context) {
    double landmarkSize = MediaQuery.of(context).size.shortestSide/15;
    StreamController<TomepageMode> modeStream = StreamController<TomepageMode>();
    TomepageMode initialMode = TomepageMode.base;
    GlobalKey mapKey = GlobalKey();
    TomeMap map = TomeMap(
      landmarkSize: landmarkSize, 
      initialLandmarks: widget.tome.landmarks, 
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.tome.title),
        actions: [IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.settings.name, arguments: SettingsArgs(db: widget.db)), 
          icon: Icon(Icons.settings))],
      ),
      body: StreamBuilder<TomepageMode>(
        stream: modeStream.stream,
        initialData: initialMode,
        builder: (context, modeUpdate) {
          Widget buttons;
          if(modeUpdate.connectionState == ConnectionState.none || modeUpdate.connectionState == ConnectionState.waiting){
            buttons = baseButtons(modeStream, map, mapKey);
          }
          else{
            switch(modeUpdate.data!){
              case TomepageMode.base:
                buttons = baseButtons(modeStream, map, mapKey);
                break;
              case TomepageMode.landmarkMove:
                buttons = landmarkConfirmButtons(modeStream, map);
                break;
            }
          }
          return tomepageBody(mapKey, buttons, map);
        }
      ),
    );
  }
}