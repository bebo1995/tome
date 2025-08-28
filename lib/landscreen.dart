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
    double buttonsH = screenSize.height * 0.1;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Universo"),
        actions: [
          IconButton(
            onPressed: ()=>{}, 
            icon: Icon(Icons.settings))
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Placeholder(),
          SizedBox(
            height: buttonsH,
            child:  Placeholder(),
          )
        ],
      ),
    );
  }
}