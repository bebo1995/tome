import 'package:flutter/material.dart';

class Landmark {
  final double size;
  Function(Landmark)? onTap;
  Function(DraggableDetails, Landmark)? onDragEnd;
  Offset position;
  bool isDraggable;
  bool isTappable;
  bool isInEdit;
  Offset? _posStore;
  Landmark({required this.size, required this.position, this.onTap, this.onDragEnd, required this.isDraggable, required this.isTappable})
  : isInEdit = false;

  void disableDrag(){
    isDraggable = false;
  }

  void enableSelection(Function(Landmark) onSelection){
    onTap = onSelection;
  }

  void savePosition(){
    _posStore = position;
  }

  void restorePosition(){
    if(_posStore == null){
      return;
    }
    position = _posStore!;
    _posStore = null;
  }

  Widget getWidget(){
    Icon icon = Icon(Icons.location_on, size: size,);
    Widget dragIcon = isDraggable ? Draggable(
            feedback: icon,
            childWhenDragging: Container(),
            onDragEnd: (details){
              if(onDragEnd == null){
                return;
              }
              onDragEnd!(details, this);
            },
            child: icon,
          ) : icon;
    return Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onTap: () => onTap != null && isTappable ? onTap!(this) : null,
            child: dragIcon,
          )
        ); 
  }

}