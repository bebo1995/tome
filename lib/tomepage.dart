import 'package:flutter/material.dart';

class TomePage extends StatefulWidget {
  const TomePage({super.key});

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
        title: Text("Universo"),
        actions: [IconButton(onPressed: () => {}, icon: Icon(Icons.settings))],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [landImage(), buttons()],
      ),
    );
  }
}
