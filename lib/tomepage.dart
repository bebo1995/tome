import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  final StreamController<LandmarkEvent> _modeStream;
  final StreamController<Offset?> _posStream;
  final StreamController<Image> _imgStream;
  final StreamController<double> _scaleStream;
  TomePage({super.key, required this.db, required this.tome}) : 
  _modeStream = StreamController<LandmarkEvent>.broadcast(),
  _posStream = StreamController<Offset?>.broadcast(),
  _imgStream = StreamController<Image>.broadcast(),
  _scaleStream = StreamController<double>.broadcast();
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

  void markSelection(Landmark selected){
    widget.tome.landmarks.remove(selected);
    selected.isDraggable = false;
    selected.isTappable = false;
    selected.isInEdit = true;
    selected.savePosition();
    widget._posStream.add(selected.position);
    widget._modeStream.add(LandmarkEvent(landmark: selected, mode: TomepageMode.landmarkSelected));
  }

  void markUnSelection(Landmark selected){
    selected.isDraggable = false;
    selected.isTappable = true;
    selected.isInEdit = false;
    selected.restorePosition();
    widget.tome.landmarks.add(selected);
    widget._modeStream.add(LandmarkEvent(landmark: null, mode: TomepageMode.base ));
  }

  Widget baseButtons(GlobalKey mapKey, double landmarkSize){
    return Row(
      children: [
        button(() => {}, Icon(Icons.book)),
        button(() async{
          var result = await FilePicker.platform.pickFiles();
          if(result != null){
            widget._imgStream.add(Image.file(File(result.files.single.path!)));
          }
        }, Icon(Icons.add_photo_alternate)),
        button((){
          Offset newLocation = createLocation(mapKey)!;
          Landmark landmark = Landmark(
            size: landmarkSize, 
            position: newLocation, 
            onTap: (landmark) => markSelection(landmark),
            onDragEnd: (details, landmark){
              Offset newPosition = adjustMarkXY(mapKey.currentContext!, details.offset, landmark.size);
              landmark.position = newPosition;
              widget._posStream.add(landmark.position);
            },
            isDraggable: true,
            isTappable: false
          );
          widget._modeStream.add(LandmarkEvent(landmark: landmark, mode: TomepageMode.landmarkMove));
          }, Icon(Icons.add_location)),
      ],
    );
  }

  Widget landmarkConfirmButtons(Landmark selected){
    return Row(
      children: [
        button((){
          if(selected.isInEdit){
            selected.isDraggable = false;
            selected.isTappable = true;
            selected.isInEdit = false;  
            selected.restorePosition();
            widget.tome.landmarks.add(selected);  
          }
          widget._posStream.add(null);
          widget._modeStream.add(LandmarkEvent(landmark: null, mode: TomepageMode.base));
        }, Icon(Icons.arrow_back)),
        button((){
          selected.isDraggable = false;
          selected.isTappable = true;
          selected.isInEdit = false;
          widget.tome.landmarks.add(selected);
          widget._posStream.add(null);
          widget._modeStream.add(LandmarkEvent(landmark: null, mode: TomepageMode.base));
        }, 
        Icon(Icons.check)),
      ],
    );
  }

  Widget landmarkSelectedButtons(Landmark selected){
    return Row(
      children: [
        button((){
          selected.isDraggable = true;
          widget._modeStream.add(LandmarkEvent(landmark: selected, mode: TomepageMode.landmarkMove));
        }, Icon(Icons.edit_location_alt)),
        button((){}, Icon(Icons.edit)),
        button((){
          widget._modeStream.add(LandmarkEvent(landmark: null, mode: TomepageMode.base));
        }, Icon(Icons.delete)),
      ],
    );
  }

  Widget mapImage(Landmark? selected, TomepageMode mode){
    return StreamBuilder(
      stream: widget._imgStream.stream, 
      builder: (BuildContext context, AsyncSnapshot<Image> snap){
        double baseScale = 1.0;
        double currScale = 1.0;
        widget._scaleStream.add(baseScale);
        return GestureDetector(
          onTapUp: (details){
            if(selected == null){
              return;
            }
            if(mode == TomepageMode.landmarkSelected){
              markUnSelection(selected);
              return;
            }
            Offset position = details.localPosition;
            position = position.translate(-selected.size/2, -selected.size);
            selected.position = position;
            widget._posStream.add(selected.position);
          },
          onScaleUpdate: (details) {
            currScale = baseScale * details.scale;
            if(currScale < 1.0){
              currScale = 1.0;
              return;
            }
            widget._scaleStream.add(currScale);
          },
          onScaleEnd: (details){
            baseScale = currScale;
          },
          child: StreamBuilder(
            stream: widget._scaleStream.stream,
            initialData: baseScale,
            builder: (context, AsyncSnapshot<double> scaleSnap){
              return !snap.hasData 
              ? Container(color: Colors.white,)
              : Stack(
                  children: [
                    Container(color: Colors.white,),
                    Center(
                      child: Transform.scale(
                        scale: scaleSnap.data!,
                        child: snap.data!
                      ), 
                    )
                  ],
              );
            },
          )
        );
      }
    );
  }

  Widget map(Landmark? selected, TomepageMode mode){
    return Stack(
      children: [
        mapImage(selected, mode),
        editLayer(widget._posStream, selected),
        baseLayer()
      ],
    );
  }

  Widget tomepageBody(GlobalKey mapKey, Widget buttons, Landmark? selected, TomepageMode mode){
    return Column(
      children: [
        Expanded(flex: 90, key: mapKey, child: map(selected, mode)), 
        Expanded(flex: 10, child: Container(color: Colors.white, child: buttons,))
      ]
    ); 
  }

  @override
  Widget build(BuildContext context) {
    double landmarkSize = MediaQuery.of(context).size.shortestSide/15;
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
        stream: widget._modeStream.stream,
        initialData: initialMode,
        builder: (context, modeUpdate) {
          Widget buttons;
          if(modeUpdate.connectionState == ConnectionState.none || modeUpdate.connectionState == ConnectionState.waiting){
            buttons = baseButtons(mapKey, landmarkSize);
          }
          else{
            switch(modeUpdate.data!.mode){
              case TomepageMode.base:
                buttons = baseButtons(mapKey, landmarkSize);
                break;
              case TomepageMode.landmarkMove:
                buttons = landmarkConfirmButtons(modeUpdate.data!.landmark!);
                break;
              case TomepageMode.landmarkSelected:
                buttons = landmarkSelectedButtons(modeUpdate.data!.landmark!);
                break;
            }
          }
          return tomepageBody(mapKey, buttons, modeUpdate.data!.landmark, modeUpdate.data!.mode);
        }
      ),
    );
  }
}