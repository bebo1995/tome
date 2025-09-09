import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/logic/tome.dart';
import 'package:tome/main.dart';
import 'package:tome/settings.dart';

enum TomepageMode{
  base,
  landmarkOn,
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

  Icon landMark(){
    double landmarkSquare = MediaQuery.of(context).size.shortestSide/25;
    return Icon(Icons.location_on, size: landmarkSquare,);
  }

  Offset adjustMarkXY(BuildContext context, Offset globalPoint){
    RenderBox contextBox = context.findRenderObject() as RenderBox;
    Offset localPoint = contextBox.globalToLocal(globalPoint);
    double xTransl = 0;
    double yTransl = 0;
    if(!(localPoint.dx > 0 && contextBox.size.width - localPoint.dx > 0)){
      xTransl = localPoint.dx < 0 ? -localPoint.dx : contextBox.size.width - (localPoint.dx + landMark().size!);
    }
    if(!(localPoint.dy > 0 && contextBox.size.height - localPoint.dy > 0)){
      yTransl = localPoint.dy < 0 ? -localPoint.dy : contextBox.size.height - (localPoint.dy + landMark().size!);
    }
    Offset adjustedPoint = localPoint.translate(xTransl, yTransl); 
    return adjustedPoint;
  }

  Widget land(StreamController<Offset> marksStream, List<Offset> landmarks, BuildContext context){
    List<Widget> widgets = List<Widget>.empty(growable: true); 
    widgets.add(Container(
        color: Colors.amber
    ));
    widgets.addAll(landmarks.map((elem) => Positioned(
      left: elem.dx,
      top: elem.dy,
      child: Draggable(
        feedback: landMark(),
        childWhenDragging: Container(),
        onDragEnd: (details) => marksStream.add(adjustMarkXY(context, details.offset)),
        child: landMark(),
      )
    )).toList());
    return GestureDetector(
      onTapUp: (details) => marksStream.add(details.localPosition),
      child: Stack(
        children: widgets,
      )
    );
  }

  Widget landImage(StreamController<Offset> marksStream, TomepageMode mode, List<Offset> landmarks) {
    return StreamBuilder<Offset>(
      stream: marksStream.stream,
      builder: ((context, snapshot){
        if(mode != TomepageMode.landmarkMove || snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none){
          return land(marksStream, landmarks, context);
        }
        landmarks.last = Offset(snapshot.data!.dx, snapshot.data!.dy);
        return land(marksStream, landmarks, context);
      })
    );
  }

  Widget button(void Function()? onPressed, Icon icon) {
    return Expanded(
      child: Center(
        child: IconButton(onPressed: onPressed, icon: icon),
      ),
    );
  }

  Offset? addLocation(StreamController<Offset> markStream, GlobalKey landKey){
    BuildContext? landContext = landKey.currentContext;
    if(landContext == null){
      return null;
    }
    RenderBox box = landContext.findRenderObject() as RenderBox;
    Size landSize = box.size;
    Offset position = Offset(landSize.width/2, landSize.height/2);
    markStream.add(position);
    return position;
  }

  Widget baseButtons(StreamController<TomepageMode> modeStream) {
    return Row(
      children: [
        button(() => {}, Icon(Icons.book)),
        button(() => {}, Icon(Icons.add_photo_alternate)),
        button(() => modeStream.add(TomepageMode.landmarkOn), Icon(Icons.location_on)),
      ],
    );
  }

  Widget landmarkOnButtons(StreamController<TomepageMode> modeStream, StreamController<Offset> markStream, GlobalKey landKey, List<Offset> landmarks){
    //TODO: enable landmark selection
    return Row(
      children: [
        button(() => modeStream.add(TomepageMode.base), Icon(Icons.arrow_back)),
        button((){
          modeStream.add(TomepageMode.landmarkMove);
          Offset? newLocation = addLocation(markStream, landKey);
          landmarks.add(newLocation!);
          }, Icon(Icons.add_location)),
      ],
    );
  }

  Widget landmarkNewButtons(StreamController<TomepageMode> modeStream, List<Offset> landMarks){
    return Row(
      children: [
        button(() => modeStream.add(TomepageMode.landmarkOn), Icon(Icons.arrow_back)),
        button(() => modeStream.add(TomepageMode.landmarkOn), Icon(Icons.check)),
      ],
    );
  }

  Widget tomepageBody(GlobalKey landKey, Widget buttons, StreamController<Offset> marksStream, TomepageMode mode, List<Offset> landmarks){
    return Column(
      children: [
        Expanded(flex: 90, key: landKey, child: landImage(marksStream, mode, landmarks)), 
        Expanded(flex: 10, child: buttons)],
    ); 
  }

  @override
  Widget build(BuildContext context) {
    StreamController<Offset> markStream = StreamController<Offset>();
    StreamController<TomepageMode> modeStream = StreamController<TomepageMode>();
    List<Offset> landmarks = List<Offset>.empty(growable: true);
    GlobalKey landKey = GlobalKey();
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
        initialData: TomepageMode.base,
        builder: (context, modeUpdate) {
          if(modeUpdate.connectionState == ConnectionState.none || modeUpdate.connectionState == ConnectionState.waiting){
            return tomepageBody(landKey, baseButtons(modeStream), markStream, modeUpdate.data!, landmarks);      
          }
          switch(modeUpdate.data!){
            case TomepageMode.base:
              return tomepageBody(landKey, baseButtons(modeStream), markStream, modeUpdate.data!, landmarks);
            case TomepageMode.landmarkOn:
              return tomepageBody(landKey, landmarkOnButtons(modeStream, markStream, landKey, landmarks), markStream, modeUpdate.data!, landmarks);
            case TomepageMode.landmarkMove:
              return tomepageBody(landKey, landmarkNewButtons(modeStream, landmarks), markStream, modeUpdate.data!, landmarks);
          }
        }
      ),
    );
  }
}