import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/logic/landmark.dart';
import 'package:tome/logic/tome.dart';
import 'package:tome/main.dart';
import 'package:tome/settings.dart';

enum TomepageMode{
  base,
  landmarkMove,
  landmarkSelected
}

class LandmarkEvent{
  final Landmark? landmark;
  final TomepageMode mode;

  const LandmarkEvent({required this.landmark, required this.mode});
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

  Widget button(void Function()? onPressed, Icon icon) {
    return Expanded(
      child: Center(
        child: IconButton(onPressed: onPressed, icon: icon),
      ),
    );
  }

  Widget editLayer(StreamController<Offset?> posStream, Landmark? selected){
    if(selected == null){
      return Container();
    }
    return StreamBuilder(
      stream: posStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Offset?> snap){
        if(snap.hasData){
          selected.position = snap.data!;
        }
        return Stack(
          children: [selected.getWidget()],
        );
      });
  }

  Widget baseLayer(){
    List<Widget> landmarks = widget.tome.landmarks.map((elem)=>elem.getWidget()).toList();
    return Stack(
      children: landmarks,
    );
  }

  Offset adjustMarkXY(BuildContext context, Offset globalPoint, double landmarkSize){
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

  Offset? createLocation(GlobalKey landKey){
    BuildContext? landContext = landKey.currentContext;
    if(landContext == null){
      return null;
    }
    RenderBox box = landContext.findRenderObject() as RenderBox;
    Size landSize = box.size;
    Offset position = Offset(landSize.width/2, landSize.height/2);
    return position;
  }

  void markSelection(StreamController<LandmarkEvent> modeStream, Landmark selected, StreamController<Offset?> posStream){
    widget.tome.landmarks.remove(selected);
    selected.isDraggable = true;
    selected.isTappable = false;
    posStream.add(selected.position);
    modeStream.add(LandmarkEvent(landmark: selected, mode: TomepageMode.landmarkSelected));
  }

  void markUnSelection(StreamController<LandmarkEvent> modeStream, Landmark selected){
    selected.isDraggable = false;
    selected.isTappable = true;
    widget.tome.landmarks.add(selected);
    modeStream.add(LandmarkEvent(landmark: null, mode: TomepageMode.base ));
  }

  Widget baseButtons(StreamController<LandmarkEvent> modeStream, GlobalKey mapKey, double landmarkSize, StreamController<Offset?> posStream){
    return Row(
      children: [
        button(() => {}, Icon(Icons.book)),
        button(() => {}, Icon(Icons.add_photo_alternate)),
        button((){
          Offset newLocation = createLocation(mapKey)!;
          Landmark landmark = Landmark(
            size: landmarkSize, 
            position: newLocation, 
            onTap: (landmark) => markSelection(modeStream, landmark, posStream),
            onDragEnd: (details, landmark){
              Offset newPosition = adjustMarkXY(mapKey.currentContext!, details.offset, landmark.size);
              landmark.position = newPosition;
              posStream.add(landmark.position);
            },
            isDraggable: true,
            isTappable: false
          );
          modeStream.add(LandmarkEvent(landmark: landmark, mode: TomepageMode.landmarkMove));
          }, Icon(Icons.add_location)),
      ],
    );
  }

  Widget landmarkConfirmButtons(StreamController<LandmarkEvent> modeStream, StreamController<Offset?> posStream, Landmark selected){
    return Row(
      children: [
        button((){
          posStream.add(null);
          modeStream.add(LandmarkEvent(landmark: null, mode: TomepageMode.base));
        }, Icon(Icons.arrow_back)),
        button((){
          selected.isDraggable = false;
          selected.isTappable = true;
          widget.tome.landmarks.add(selected);
          posStream.add(null);
          modeStream.add(LandmarkEvent(landmark: null, mode: TomepageMode.base));
        }, 
        Icon(Icons.check)),
      ],
    );
  }

  Widget landmarkSelectedButtons(StreamController<LandmarkEvent> modeStream, Landmark selected){
    return Row(
      children: [
        button((){
          modeStream.add(LandmarkEvent(landmark: selected, mode: TomepageMode.landmarkMove));
        }, Icon(Icons.edit_location_alt)),
        button((){}, Icon(Icons.edit)),
        button((){
          modeStream.add(LandmarkEvent(landmark: null, mode: TomepageMode.base));
        }, Icon(Icons.delete)),
      ],
    );
  }

  Widget map(StreamController<LandmarkEvent> modeStream, StreamController<Offset?> posStream, Landmark? selected, TomepageMode mode){
    Widget background = GestureDetector(
      onTapUp: (details){
        if(selected == null){
          return;
        }
        if(mode == TomepageMode.landmarkSelected){
          markUnSelection(modeStream, selected);
          return;
        }
        Offset position = details.localPosition;
        position = position.translate(-selected.size/2, -selected.size);
        selected.position = position;
        posStream.add(selected.position);
      },
      child: Container(color: Colors.amber,),
    );
    return Stack(
      children: [
        background,
        editLayer(posStream, selected),
        baseLayer()
      ],
    );
  }

  Widget tomepageBody(GlobalKey mapKey, Widget buttons, StreamController<Offset?> posStream, Landmark? selected, TomepageMode mode, StreamController<LandmarkEvent> modeStream){
    return Column(
      children: [
        Expanded(flex: 90, key: mapKey, child: map(modeStream, posStream, selected, mode)), 
        Expanded(flex: 10, child: buttons)],
    ); 
  }

  @override
  Widget build(BuildContext context) {
    double landmarkSize = MediaQuery.of(context).size.shortestSide/15;
    StreamController<LandmarkEvent> modeStream = StreamController<LandmarkEvent>.broadcast();
    StreamController<Offset?> posStream = StreamController<Offset?>.broadcast();
    LandmarkEvent initialMode = LandmarkEvent(landmark: null, mode: TomepageMode.base);
    GlobalKey mapKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.tome.title),
        actions: [IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.settings.name, arguments: SettingsArgs(db: widget.db)), 
          icon: Icon(Icons.settings))],
      ),
      body: StreamBuilder<LandmarkEvent>(
        stream: modeStream.stream,
        initialData: initialMode,
        builder: (context, modeUpdate) {
          Widget buttons;
          if(modeUpdate.connectionState == ConnectionState.none || modeUpdate.connectionState == ConnectionState.waiting){
            buttons = baseButtons(modeStream, mapKey, landmarkSize, posStream);
          }
          else{
            switch(modeUpdate.data!.mode){
              case TomepageMode.base:
                buttons = baseButtons(modeStream, mapKey, landmarkSize, posStream);
                break;
              case TomepageMode.landmarkMove:
                buttons = landmarkConfirmButtons(modeStream, posStream, modeUpdate.data!.landmark!);
                break;
              case TomepageMode.landmarkSelected:
                buttons = landmarkSelectedButtons(modeStream, modeUpdate.data!.landmark!);
                break;
            }
          }
          return tomepageBody(mapKey, buttons, posStream, modeUpdate.data!.landmark, modeUpdate.data!.mode, modeStream);
        }
      ),
    );
  }
}