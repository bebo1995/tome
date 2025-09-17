import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tome/logic/landmark.dart';

class TomeMap{
  final List<Landmark> _layerBack;
  final List<Offset> _layerFront;
  final StreamController<Landmark> _layBStream;
  final StreamController<Offset?> _layFStream;
  final List<Landmark> initialLandmarks;
  final double landmarkSize;
  final Function onLMarkSelection;
  final Function onLMarkUnSelection;

  TomeMap({required this.initialLandmarks, required this.landmarkSize, required this.onLMarkSelection, required this.onLMarkUnSelection}) : 
  _layerBack = initialLandmarks,
  _layerFront = List<Offset>.empty(growable: true),
  _layFStream = StreamController<Offset?>(),
  _layBStream = StreamController<Landmark>();

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

  void createLandmark(Offset landmarkPosition){
    _layerFront.add(landmarkPosition);
    _layFStream.add(landmarkPosition);
  }

  void moveLandmark(Offset newPosition){
    _layFStream.add(newPosition);
  }

  void cancelLandmarks(){
    _resetFront();
  }

  void confirmLandmarks(){
    for (Offset position in _layerFront) {
      _layBStream.add(Landmark(
        size: landmarkSize, 
        position: position, 
        isDraggable: false,
        onTap: onLMarkSelection
        ));
    }
    _resetFront();
  }

  void _onDragLandmark(BuildContext context, DraggableDetails details){
    moveLandmark(_adjustMarkXY(context, details.offset));
  }

  Widget _layBack(){
    return StreamBuilder<Landmark>(
      stream: _layBStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Landmark> snap){
        if(snap.hasData){
          _layerBack.add(snap.data!);
        }
        return Stack(children: _layerBack.map((landmark)=>landmark.getWidget()).toList());
      });
  }

  Widget _layFront(){
    return StreamBuilder<Offset?>(
      stream: _layFStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Offset?> snap){
        if(snap.hasData){
          _layerFront.last = snap.data!;
        }
        return Stack(children: _layerFront.map((position)=>Landmark(
          size: landmarkSize, 
          position: position,
          onDragEnd: (details) => _onDragLandmark(context, details),
          isDraggable: true
        ).getWidget()).toList());
      });
  }

  Widget getWidget(BuildContext context){
    Widget background = GestureDetector(
      onTapUp: (details){
        if(_layerFront.isEmpty){
          onLMarkUnSelection();
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
        _layBack(),
        _layFront()
      ],
    );
  }

  List<Landmark> getCurrentLandmarks(){
    return _layerBack;
  }
}