import 'package:flutter/material.dart';

class Landmark {
  final double size;
  Function? onTap;
  Function(DraggableDetails)? onDragEnd;
  Offset position;
  bool isDraggable;
  Landmark({required this.size, required this.position, this.onTap, this.onDragEnd, required this.isDraggable});

  void disableDrag(){
    onDragEnd = null;
    isDraggable = false;
  }

  Widget getWidget(){
    Icon icon = Icon(Icons.location_on, size: size,);
    Widget dragIcon = isDraggable ? Draggable(
            feedback: icon,
            childWhenDragging: Container(),
            onDragEnd: (details) => onDragEnd,
            child: icon,
          ) : icon;
    return Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onTap: () => onTap,
            child: dragIcon,
          )
        ); 
  }

}