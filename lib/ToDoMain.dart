import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lab_3_todo/ParseEvents.dart';
import 'package:lab_3_todo/ToDoList.dart';

class ToDoMain extends StatefulWidget {

  final Function(String, Widget) changePage;
  const ToDoMain ({super.key, required this.changePage});



  @override
  State<ToDoMain> createState() => _ToDoMainState(changePage);
}

class _ToDoMainState extends State<ToDoMain> {
  final Function(String, Widget) changePage;
  _ToDoMainState (this.changePage);
  late Future<String> json;

  @override
  void initState() {
    super.initState();
    json = ParseEvents.readEvents();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: json,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          }else if(snapshot.hasError){
            return Text("Ошибка ${snapshot.error}");
          }else{

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createLists(
                    genBlocks(ToDoList.createMap(json: snapshot.data)),
                    changePage,
                    snapshot.data
                ),
                // ToDoList(json: snapshot.data),
              ],
            );
          }
        }
    );
  }
}

Expanded createLists(List blocks, Function(String, Widget) changePage, String json){
  return Expanded(

    child: GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 6,
      mainAxisSpacing: 12,

      children: getAllLists(blocks, changePage, json),
    ),

  );
}

List<Widget> getAllLists(List arr, Function(String, Widget) changePage, String json){
  List<Widget> lists = [];

  arr.forEach((e) {
    lists.add(getList(e, changePage, json));
  });

  return lists;
}

Widget getList(List arr, Function(String, Widget) changePage, String json){
  int type = arr[0];
  int num = arr[1];
  String descr = arr[2];

  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: GestureDetector(
      onTap: () => changePage(descr, ToDoList(type: descr)),
      child: Container(
          color: type == 0 ? Color.fromRGBO(6, 187, 108, 1) :
          Color.fromRGBO(36,36,51, 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    num.toString(),
                    style: TextStyle(
                        color: type == 0 ? Colors.white : Color.fromRGBO(119, 132, 150, 1),
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    descr.toString(),
                    style: TextStyle(
                        color: type == 0 ? Colors.white :
                        Color.fromRGBO(119, 132, 150, 1),
                        fontSize: 15,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    ),
  );
}

List<List> genBlocks(Map map){
  return [
    getTodayBlock(map),
    getWeekBlock(map),
    getAllTasksBlock(map),
    getCompletedBlock(map),
  ];
}

List getTodayBlock(Map map){
  DateTime now = DateTime.now();
  DateFormat df = DateFormat("y-MM-dd");

  return [
    0,
    map[df.format(now)]?.length ?? 0,
    "Today"
  ];
}

List getWeekBlock(Map map){
  DateTime now = DateTime.now();
  DateFormat df = DateFormat("y-MM-dd");
  now = DateTime.parse(df.format(now));

  DateTime startOfWeek = now.subtract(Duration(days: now.weekday-1));
  
  DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

  int countTasks = 0;


    map.forEach((key, value) {
      DateTime dateKey = DateFormat("y-MM-dd").parse(key);
      bool isAfterOrSame = dateKey.isAfter(startOfWeek) ||
          dateKey.isAtSameMomentAs(startOfWeek);
      bool isBefore = dateKey.isBefore(endOfWeek);

      if (isAfterOrSame &&  isBefore){
        countTasks += map[key]?.length as int;
      }
    });


  return [
    1,
    countTasks,
    "This week"
  ];
}

List getAllTasksBlock(Map map){
  int countAllTasks = 0;

  map.forEach((key, value) {
    if (map[key]?.length != null) {
      countAllTasks += map[key]?.length as int;
    }
  });

  return [
    1,
    countAllTasks,
    "All"
  ];
}

List getCompletedBlock(Map map){

  int countCompleted = RegExp(r'true').allMatches(map.toString()).length;
  return [
    0,
    countCompleted,
    "Completed"
  ];
}