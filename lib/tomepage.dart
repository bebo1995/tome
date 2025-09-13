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
    double landmarkSquare = MediaQuery.of(context).size.shortestSide/15;
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

  Widget land(StreamController<Offset> marksStream, BuildContext context, Offset? update){
    List<Widget> widgets = List<Widget>.empty(growable: true); 
    widgets.add(Container(
        color: Colors.amber
    ));
    widgets.addAll(widget.tome.landmarks.map((elem) => Positioned(
      left: elem.dx,
      top: elem.dy,
      child: landMark()
    )).toList());
    if(update != null){
      widgets.add(
        Positioned(
          left: update.dx,
          top: update.dy,
          child: Draggable(
            feedback: landMark(),
            childWhenDragging: Container(),
            onDragEnd: (details) => marksStream.add(adjustMarkXY(context, details.offset)),
            child: landMark(),
          )
        ) 
      );
    }
    return GestureDetector(
      onTapUp: (details) => marksStream.add(details.localPosition),
      child: Stack(
        children: widgets,
      )
    );
  }

  Widget landImage(StreamController<Offset> marksStream, TomepageMode mode) {
    return StreamBuilder<Offset>(
      stream: marksStream.stream,
      builder: ((context, snapshot){
        return land(marksStream, context, snapshot.data);
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

  Offset? createLocation(StreamController<Offset> markStream, GlobalKey landKey){
    BuildContext? landContext = landKey.currentContext;
    if(landContext == null){
      return null;
    }
    RenderBox box = landContext.findRenderObject() as RenderBox;
    Size landSize = box.size;
    Offset position = Offset(landSize.width/2, landSize.height/2);
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

  Widget landmarkOnButtons(StreamController<TomepageMode> modeStream, StreamController<Offset> markStream, GlobalKey landKey){
    //TODO: enable landmark selection
    return Row(
      children: [
        button(() => modeStream.add(TomepageMode.base), Icon(Icons.arrow_back)),
        button((){
          modeStream.add(TomepageMode.landmarkMove);
          Offset newLocation = createLocation(markStream, landKey)!;
          markStream.add(newLocation);
          }, Icon(Icons.add_location)),
      ],
    );
  }

  Widget landmarkConfirmButtons(StreamController<TomepageMode> modeStream){
    return Row(
      children: [
        button(() => modeStream.add(TomepageMode.landmarkOn), Icon(Icons.arrow_back)),
        button(() => modeStream.add(TomepageMode.landmarkOn), Icon(Icons.check)),
      ],
    );
  }

  Widget tomepageBody(GlobalKey landKey, Widget buttons, StreamController<Offset> marksStream, TomepageMode mode){
    return Column(
      children: [
        Expanded(flex: 90, key: landKey, child: landImage(marksStream, mode)), 
        Expanded(flex: 10, child: buttons)],
    ); 
  }

  @override
  Widget build(BuildContext context) {
    StreamController<Offset> markStream = StreamController<Offset>();
    StreamController<TomepageMode> modeStream = StreamController<TomepageMode>();
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
          Widget buttons;
          if(modeUpdate.connectionState == ConnectionState.none || modeUpdate.connectionState == ConnectionState.waiting){
            buttons = baseButtons(modeStream);
          }
          else{
            switch(modeUpdate.data!){
              case TomepageMode.base:
                buttons = baseButtons(modeStream);
                break;
              case TomepageMode.landmarkOn:
                buttons = landmarkOnButtons(modeStream, markStream, landKey);
                break;
              case TomepageMode.landmarkMove:
                buttons = landmarkConfirmButtons(modeStream);
                break;
            }
          }
          return tomepageBody(landKey, buttons, markStream, modeUpdate.data!);
        }
      ),
    );
  }
}