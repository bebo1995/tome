import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/logic/tome.dart';
import 'package:tome/main.dart';
import 'package:tome/settings.dart';

enum MarkEventType{
  creation,
  movement
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

  Widget land(StreamController<Offset> marksStream){
    return GestureDetector(
      onTapUp: (details) => marksStream.add(details.localPosition),
      child: Container(
        color: Colors.amber
      ),
    );
  }

  Widget landImage(StreamController<Offset> marksStream) {
    return StreamBuilder<Offset>(
      stream: marksStream.stream,
      builder: ((context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none){
          return land(marksStream);
        }
        return Stack(
          children: [
            land(marksStream),
            Positioned(
              left: snapshot.data?.dx,
              top: snapshot.data?.dy,
              child: Draggable(
                feedback: landMark(),
                childWhenDragging: Container(),
                onDragEnd: (details) => marksStream.add(adjustMarkXY(context, details.offset)),
                child: landMark(),
              )
            )
          ],
        );
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

  void addLocation(StreamController<Offset> markStream, GlobalKey landKey){
    BuildContext? landContext = landKey.currentContext;
    if(landContext == null){
      return;
    }
    RenderBox box = landContext.findRenderObject() as RenderBox;
    Size landSize = box.size;
    markStream.add(Offset(landSize.width/2, landSize.height/2));
  }

  Widget buttons(StreamController<Offset> markStream, GlobalKey landKey) {
    return Row(
      children: [
        button(() => {}, Icon(Icons.book)),
        button(() => {}, Icon(Icons.add_photo_alternate)),
        button(() => addLocation(markStream, landKey), Icon(Icons.add_location)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    StreamController<Offset> markStream = StreamController<Offset>();
    GlobalKey landKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.tome.title),
        actions: [IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.settings.name, arguments: SettingsArgs(db: widget.db)), 
          icon: Icon(Icons.settings))],
      ),
      body: Column(
        children: [
          Expanded(flex: 90, key: landKey, child: landImage(markStream)), 
          Expanded(flex: 10, child: buttons(markStream, landKey))],
      ),
    );
  }
}