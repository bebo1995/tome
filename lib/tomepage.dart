import 'package:flutter/material.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/logic/tome.dart';
import 'package:tome/main.dart';
import 'package:tome/settings.dart';

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
  Widget landImage() {
    return Container();
  }

  Widget button(void Function()? onPressed, Icon icon) {
    return Expanded(
      child: Center(
        child: IconButton(onPressed: onPressed, icon: icon),
      ),
    );
  }

  Widget buttons() {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsH = screenSize.height * 0.1;
    return SizedBox(
      height: buttonsH,
      child: Row(
        children: [
          button(() => {}, Icon(Icons.book)),
          button(() => {}, Icon(Icons.add_photo_alternate)),
          button(() => {}, Icon(Icons.add_location)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.tome.title),
        actions: [IconButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.settings.name, arguments: SettingsArgs(db: widget.db)), 
          icon: Icon(Icons.settings))],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [landImage(), buttons()],
      ),
    );
  }
}