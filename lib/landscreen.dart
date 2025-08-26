import 'package:flutter/material.dart';

class LandScreen extends StatefulWidget{
  const LandScreen({super.key});
  
  @override
  State<StatefulWidget> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen>{
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double buttonsH = screenSize.height * 0.15;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Placeholder(),
        SizedBox(
          height: buttonsH,
          child:  Placeholder(),
        )
      ],
    );
  }
}