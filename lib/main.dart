import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lab_3_todo/ToDoBase.dart';
import 'ToDoMain.dart';
import 'ParseEvents.dart';

Future<void> main() async {

  runApp(const ToDoApp());

}

class ToDoApp extends StatelessWidget {

  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromRGBO(26,26,38,1),
        systemNavigationBarIconBrightness: Brightness.light
    ));

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ToDoBase(),
    );
  }
}