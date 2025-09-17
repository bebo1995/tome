import 'dart:async';

import 'package:flutter/material.dart';

class TomeMap{
  final List<Offset> _layerBack;
  final List<Offset> _layerFront;
  final StreamController<Offset> _layBStream;
  final StreamController<Offset?> _layFStream;
  final List<Offset> initialLandmarks;
  final double landmarkSize;

  TomeMap({required this.initialLandmarks, required this.landmarkSize}) : 
  _layerBack = initialLandmarks,
  _layerFront = List<Offset>.empty(growable: true),
  _layFStream = StreamController<Offset?>(),
  _layBStream = StreamController<Offset>();

  Offset _adjustMarkXY(BuildContext context, Offset globalPoint){
    RenderBox contextBox = context.findRenderObject() as RenderBox;
    Offset localPoint = contextBox.globalToLocal(globalPoint);
    double xTransl = 0;
    double yTransl = 0;
    if(!(localPoint.dx > 0 && (contextBox.size.width - landmarkSize) - localPoint.dx > 0)){
      xTransl = localPoint.dx < 0 ? -localPoint.dx : contextBox.size.width - (localPoint.dx + landmarkSize);
    }
    if(!(localPoint.dy > 0 && (contextBox.size.height - landmarkSize) - localPoint.dy > 0)){
      yTransl = localPoint.dy < 0 ? -localPoint.dy : contextBox.size.height - (localPoint.dy + landmarkSize);
    }
    Offset adjustedPoint = localPoint.translate(xTransl, yTransl); 
    return adjustedPoint;
  }

  void _resetFront(){
    _layerFront.clear();
    _layFStream.add(null);
  }

  void createLandmark(Offset position){
    _layerFront.add(position);
    _layFStream.add(position);
  }

  void moveLandmark(Offset position){
    _layFStream.add(position);
  }

  void cancelLandmarks(){
    _resetFront();
  }

  void confirmLandmarks(){
    for (Offset landmark in _layerFront) {
      _layBStream.add(landmark);
    }
    _resetFront();
  }

  Widget _landMark(Offset position, bool activateDrag, BuildContext context){
    Icon landmark = Icon(Icons.location_on, size: landmarkSize,);
    Widget returnWidget = landmark;
    if(!activateDrag){
      returnWidget = landmark;
    }
    else{
      returnWidget = Draggable(
            feedback: landmark,
            childWhenDragging: Container(),
            onDragEnd: (details) => moveLandmark(_adjustMarkXY(context, details.offset)),
            child: landmark,
          );
    }
    return Positioned(
          left: position.dx,
          top: position.dy,
          child: returnWidget
        ); 
  }

  Widget _layBack(BuildContext context){
    return StreamBuilder<Offset>(
      stream: _layBStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Offset> snap){
        if(snap.hasData){
          _layerBack.add(snap.data!);
        }
        return Stack(children: _layerBack.map((landmark)=>_landMark(landmark, false, context)).toList());
      });
  }

  Widget _layFront(BuildContext context){
    return StreamBuilder<Offset?>(
      stream: _layFStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Offset?> snap){
        _layerFront.clear();
        if(snap.hasData){
          _layerFront.add(snap.data!);
        }
        return Stack(children: _layerFront.map((landmark)=>_landMark(landmark, true, context)).toList());
      });
  }

  Widget getWidget(BuildContext context){
    Widget background = GestureDetector(
      onTapUp: (details){
        if(_layerFront.isEmpty){
          return;
        }
        Offset position = details.localPosition;
        position = position.translate(-landmarkSize/2, -landmarkSize);
        moveLandmark(position);
      },
      child: Container(color: Colors.amber,)
    );
    return Stack(
      children: [
        background,
        _layBack(context),
        _layFront(context)
      ],
    );
  }

  List<Offset> getCurrentLandmarks(){
    return _layerBack;
  }
}