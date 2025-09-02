import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tome/logic/database.dart';
import 'package:tome/logic/tome.dart';
import 'package:tome/main.dart';
import 'package:tome/tomepage.dart';

class CreateTomeArgs{
  final Database db;
  const CreateTomeArgs({required this.db});
}

class CreateTome extends StatefulWidget{
  final Database db;
  const CreateTome({super.key, required this.db});
  static CreateTome fromArgs(CreateTomeArgs args){
    return CreateTome(db: args.db,);
  }

  @override
  State<StatefulWidget> createState() => CreateTomeState();
}

class CreateTomeState extends State<CreateTome>{

  Widget tappableBackground(FocusNode focus){
    return GestureDetector(
      child: Container(),
      onTap: ()=>focus.unfocus(),
    );
  }

  String? titleValidator(String? title){
    if(title == null || title.isEmpty){
      return 'necessario inserire testo';
    }
    return null;
  }

  Widget formElem(TextEditingController ctrl, FocusNode focus, String title, String? Function(String?) validator){
    return Row(children: [
      Expanded(child: Text(title, textAlign: TextAlign.center,),),
      Expanded(child: 
      TextFormField(
        controller: ctrl,
        focusNode: focus,
        validator: (value) => validator(value),
        keyboardType: TextInputType.name,
      ))
    ],);
  }

  Widget form(GlobalKey<FormState> key, FocusNode focus, List<Widget> formElems){
    return Form(
      key: key,
      child: Stack(
        children: [
          tappableBackground(focus),
          Column(children: formElems.map((Widget elem){
            return Expanded(child: elem); 
            }).toList()
          )
        ],
      )
    );
  }  

  Widget readDbProgressIndicator(BuildContext context){
    Size size = MediaQuery.of(context).size;
    double mindim = min(size.width, size.height);
    return Center(
      child: SizedBox(
        height: mindim / 2,
        width: mindim / 2,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buttons(GlobalKey<FormState> key, FocusNode focus, TextEditingController titleCtrl){
    return Row(children: [
      Expanded(child: TextButton(
        onPressed: () async {
          focus.unfocus();
          titleCtrl.text = titleCtrl.text.trim();
          if(!key.currentState!.validate()){
            return;
          }
          BuildContext ctxt = context;
          showDialog(context: ctxt, barrierDismissible: false, builder: (context){
            return AlertDialog(
              content: readDbProgressIndicator(context)
            );
          });
          Map<String, String?>? titleMatch = await widget.db.readJson(DbCollections.tomes, titleCtrl.text);
          if(!ctxt.mounted){
            return;
          }
          Navigator.of(ctxt).pop();
          if(titleMatch != null){
            await showDialog(context: ctxt, builder: (context){
              return AlertDialog(
                content: Text('Questo titolo è già stato scelto'),
                actions: [
                  TextButton(onPressed: ()=>Navigator.pop(ctxt), child: Text('Ok'))
                ],
              );
            });
          }
          else{
            await showDialog(context: ctxt, builder: (context){
              return AlertDialog(
                content: Text('Nuovo tomo creato'),
                actions: [
                  TextButton(onPressed: ()=>Navigator.pop(ctxt), child: Text('Ok'))
                ],
              );
            });
            if(!ctxt.mounted){
              return;
            }
            Tome newTome = Tome(title: titleCtrl.text);
            widget.db.createJson(newTome, DbCollections.tomes);
            Navigator.of(ctxt).pushNamedAndRemoveUntil(
              Routes.tomepage.name,
              (route){return !Navigator.of(context).canPop();},
              arguments: TomePageArgs(db: widget.db, tome: newTome));
          }
        }, 
        child: Text('Conferma')),)
    ],);
  }
  
  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    FocusNode focus = FocusNode();
    TextEditingController titleCtrl = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuovo Tomo'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(flex: 90, child: form(formKey, focus, [
            formElem(titleCtrl, focus, 'Nome:', titleValidator)
          ])),
          Expanded(flex: 10, child: buttons(formKey, focus, titleCtrl))
        ],
      )
      );
  }

}