import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lab_3_todo/Calendar.dart';
import 'package:lab_3_todo/ParseEvents.dart';
import 'package:lab_3_todo/ToDoBase.dart';

import 'ToDoList.dart';

class ToDoAdd extends StatefulWidget {
  final Function() changePageBack;
  const ToDoAdd({super.key, required this.changePageBack});


  @override
  State<ToDoAdd> createState() => _ToDoAddState(changePageBack: changePageBack);
}

class _ToDoAddState extends State<ToDoAdd> {

  late Function() changePageBack;
  _ToDoAddState({required this.changePageBack});
  late Future<String> json;
  late Map<String, List<Map<String, bool>>> groupedEvents;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _taskTextController = TextEditingController();

  late String date = "blahblahblah";

  @override
  void initState() {
    super.initState();
    json = ParseEvents.readEvents();
  }

  void setNewDate(String d){
    date = d;
  }

  void addNewTask(String text){
    // Проверяем, существует ли уже список задач для данной даты
    if (!groupedEvents.containsKey(date)) {
      // Если нет, создаем новый список
      groupedEvents[date] = [];
    }

    String eventText = text;
    int copyNumber = 1;

    // Пока существует задача с таким же текстом, добавляем к тексту номер копии
    while (groupedEvents[date]!.any((event) => event.containsKey(eventText))) {
      eventText = '$text (${copyNumber++})';
    }

    // Создаем Map для новой задачи с модифицированным текстом и значением false
    Map<String, bool> newTask = {eventText: false};

    // Добавляем новую задачу в список задач для данной даты
    groupedEvents[date]!.add(newTask);

    // Выводим информацию для проверки
    
    ParseEvents.writeEventsToFile(jsonEncode(groupedEvents));

    changePageBack();
  }

  @override
  Widget build(BuildContext context) {
    _dateController.text = "2030-01-01";
    _taskTextController.text = "Тест_Тест_Тест_Тест_Тест_Тест_Тест";

    return FutureBuilder(
        future: json,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){


          if(snapshot.connectionState == ConnectionState.waiting){
            return CircularProgressIndicator();
          }else if(snapshot.hasError){
            return Text("${snapshot.error}");
          }else{
            groupedEvents = ToDoList.createMap(json: snapshot.data);
            return Container(
              child: Column(
                children: [
                  Calendar(setNewDate: setNewDate),
                  TextField(
                    controller: _taskTextController,
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  InkWell(
                    onTap: () => addNewTask(_taskTextController.text),
                    child: Container(
                      color: Colors.greenAccent,
                      child: Text("Добавить", style: TextStyle(
                          color: Colors.black
                      ),),
                    ),
                  )
                ],
              ),
            );
          }
        }
    );

  }
}
