import 'package:flutter/material.dart';
import 'package:mastertome/homepage.dart';
import 'package:mastertome/tomepage.dart';

void main() {
  runApp(const MyApp());
}

enum Routes{
  homepage,
  tomepage
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Object? getArgs(BuildContext context){
    return ModalRoute.of(context)!.settings.arguments;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final String appTitle = 'Mastertome';
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: Routes.homepage.name,
      routes: {
        Routes.homepage.name: (context) => Homepage(title: (getArgs(context) as HomePageArgs).title,),
        Routes.tomepage.name: (context) => const TomePage(),
      },
      home: Homepage(title: appTitle,)
    );
  }
}