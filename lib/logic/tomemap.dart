import 'package:flutter/material.dart';
import 'package:tome/logic/maplayer.dart';
import 'package:tome/logic/tome.dart';

class TomeMap{
  final MapLayer _layerBack;
  MapLayer _layerFront;
  final Tome tome;
  final double landmarkSize;
  final GlobalKey key;

  TomeMap({required this.key, required this.tome, required this.landmarkSize}) : 
  _layerBack = MapLayer(activateDrag: false, landmarksSize: landmarkSize, landmarks: tome.landmarks),
  _layerFront = MapLayer(activateDrag: true, landmarksSize: landmarkSize, landmarks: List<Offset>.empty(growable: true));

  void createLandmark(Offset landmark){
    _layerFront.landmarks.add(landmark);
    _layerFront.moveLandmark(landmark);
  }

  void _resetFront(){
    _layerFront = MapLayer(activateDrag: true, landmarksSize: landmarkSize, landmarks: List<Offset>.empty(growable: true));
  }

  void cancelLandmarks(){
    _resetFront();
  }

  void confirmLandmarks(){
    for (var landmark in _layerFront.landmarks) {
      _layerBack.moveLandmark(landmark);
    }
    _resetFront();
  }

  Widget getWidget(){
    return Stack(
      children: [
        GestureDetector(
          onTapUp: (details){
            Offset position = details.localPosition;
            position = position.translate(-landmarkSize/2, -landmarkSize);
            _layerFront.moveLandmark(position);
          },
          child: Container(color: Colors.amber,)
        ),
        _layerBack.getWidget(),
        _layerFront.getWidget()
      ],
    );
  }

  List<Offset> getActiveLandmarks(){
    return _layerFront.landmarks;
  }
}