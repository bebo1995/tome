import 'dart:async';

import 'package:flutter/material.dart';

class TomeMap{
  List<Offset> _layerBack;
  List<Offset> _layerFront;
  StreamController<Offset> _layBStream;
  StreamController<Offset> _layFStream;
  final List<Offset> initialLandmarks;
  final double landmarkSize;
  final GlobalKey key;

  TomeMap({required this.key, required this.initialLandmarks, required this.landmarkSize}) : 
  _layerBack = initialLandmarks,
  _layerFront = List<Offset>.empty(growable: true),
  _layFStream = StreamController<Offset>(),
  _layBStream = StreamController<Offset>();

  void _resetFront(){
    _layerFront.clear();
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

  Widget _landMark(Offset position, bool activateDrag){
    Icon landmark = Icon(Icons.location_on, size: landmarkSize,);
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

  Widget _layBack(){
    return StreamBuilder<Offset>(
      stream: _layBStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Offset> snap){
        if(snap.hasData){
          _layerBack.add(snap.data!);
        }
        return Stack(children: _layerBack.map((landmark)=>_landMark(landmark, false)).toList());
      });
  }

  Widget _layFront(){
    return StreamBuilder<Offset>(
      stream: _layFStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Offset> snap){
        if(snap.hasData){
          _layerFront.clear();
          _layerFront.add(snap.data!);
        }
        return Stack(children: _layerFront.map((landmark)=>_landMark(landmark, true)).toList());
      });
  }

  Widget getWidget(){
    return Stack(
      children: [
        GestureDetector(
          onTapUp: (details){
            Offset position = details.localPosition;
            position = position.translate(-landmarkSize/2, -landmarkSize);
            moveLandmark(position);
          },
          child: Container(color: Colors.amber,)
        ),
        _layBack(),
        _layFront()
      ],
    );
  }

  List<Offset> getCurrentLandmarks(){
    return _layerBack;
  }
}