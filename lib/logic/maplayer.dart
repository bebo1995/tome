import 'dart:async';

import 'package:flutter/material.dart';

class MapLayer{
  late List<Offset> landmarks;
  final StreamController<Offset> _marksStream;
  final bool activateDrag;
  final double landmarksSize;
  MapLayer({required this.activateDrag, required this.landmarksSize, required this.landmarks}) 
  : _marksStream = StreamController<Offset>();

  Offset _adjustMarkXY(BuildContext context, Offset globalPoint){
    RenderBox contextBox = context.findRenderObject() as RenderBox;
    Offset localPoint = contextBox.globalToLocal(globalPoint);
    double xTransl = 0;
    double yTransl = 0;
    if(!(localPoint.dx > 0 && contextBox.size.width - localPoint.dx > 0)){
      xTransl = localPoint.dx < 0 ? -localPoint.dx : contextBox.size.width - (localPoint.dx + landmarksSize);
    }
    if(!(localPoint.dy > 0 && contextBox.size.height - localPoint.dy > 0)){
      yTransl = localPoint.dy < 0 ? -localPoint.dy : contextBox.size.height - (localPoint.dy + landmarksSize);
    }
    Offset adjustedPoint = localPoint.translate(xTransl, yTransl); 
    return adjustedPoint;
  }

  Widget _landMark(Offset position){
    Icon landmark = Icon(Icons.location_on, size: landmarksSize,);
    Widget returnWidget = landmark;
    if(!activateDrag){
      returnWidget = landmark;
    }
    else{
      returnWidget = Draggable(
            feedback: landmark,
            childWhenDragging: Container(),
            onDragEnd: (details) => moveLandmark(details.offset),
            child: landmark,
          );
    }
    returnWidget = Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable(
            feedback: landmark,
            childWhenDragging: Container(),
            onDragEnd: (details) => moveLandmark(details.offset),
            child: landmark,
          )
        ); 
    return returnWidget;
  } 

  void moveLandmark(Offset landmark){
    _marksStream.add(landmark);
  }

  Widget getWidget(){
    List<Widget> widgets = List<Widget>.empty(growable: true); 
    widgets.addAll(landmarks.map((elem) => _landMark(elem)).toList());
    return StreamBuilder<Offset>(
      stream: _marksStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Offset> snapshot){
        if(snapshot.data != null){
          widgets.clear();
          widgets.addAll(landmarks.map((elem) => _landMark(snapshot.data!)).toList());
        }
        return Stack(
          children: widgets,
        );
      });
  }
}