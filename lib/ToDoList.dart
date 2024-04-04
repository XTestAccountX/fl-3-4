import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:lab_3_todo/ParseEvents.dart';

class ToDoList extends StatefulWidget {
  late String type;
  ToDoList({super.key, required this.type});

  static Map<String, List<Map<String, bool>>> createMap({String json = ""}){

    Map<String, List<Map<String, bool>>> test = {
      '2023-12-02': [{'Купить морковь': true}, {'Сходить к доктору, 17:40': false}, {'Позвонить маме...': true}],
      '2023-12-03': [{'Пора переехать': true}],
      '2023-12-04': [{'Отправть кроссовки обратно': false}, {'Купить билеты в Париж!!!': true}],
      '2023-12-05': [{'Работать': false}],
      '2023-12-07': [{'Работать': false}],
      '2024-01-21': [{'Работать': false}],
      '2024-01-28': [{'Работать': false}],
      '2024-01-29': [{'Купить морковь': true}, {'Сходить к доктору, 17:40': false}, {'Позвонить маме...': true}],
      '2024-01-30': [{'Работать': false}],
    };

    json = json.isEmpty ? jsonEncode(test) : json;

    var decodedJson = jsonDecode(json);

    // Преобразование в нужный тип
    Map<String, List<Map<String, bool>>> decoded =
    decodedJson.map<String, List<Map<String, bool>>>( (key, value) {
      String stringKey = key; // ДАТА
      List list = value; // ЗАДАЧА:ФЛАГ
      return MapEntry( // МАПАЕМ
          stringKey, // ДАТА
          list.map<Map<String, bool>>((item) {
            // ЗАДАЧА:ФЛАГ
            return Map<String, bool>.from(item as Map);
          }).toList());
    },
    );

    print(decoded);
    // ParseEvents.writeEventsToFile(jsonEncode(test));
    return decoded;
  }

  @override
  State<ToDoList> createState() => _ToDoListState(type: type);
}

class _ToDoListState extends State<ToDoList>{
  late Future<String> json;
  late String type;
  _ToDoListState ({required this.type});

  Icon doneIcon = const Icon(
      Icons.circle,
      size: 18.0,
      color: Color.fromRGBO(6, 187, 108, 1)
  );
  Icon unDoneIcon = const Icon(
      Icons.circle_outlined,
      size: 18.0,
      color: Color.fromRGBO(66, 72, 82, 1)
  );
  Map<String, List<Map<String, bool>>> groupedEvents = {};

  @override
  void initState() {
    super.initState();
    json = ParseEvents.readEvents();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("deactivate");
    // ParseEvents.writeEventsToFile(jsonEncode(groupedEvents));
  }
  @override
  void dispose() {
    // ParseEvents.writeEventsToFile(jsonEncode(groupedEvents));
    super.dispose();
    print("dispose");
  }

  void changeGroupedEvents(List<String> a, {bool remove = false}){

    setState(() {
      if (!remove){
        groupedEvents[a[0]]?.forEach((element) {
          if (element.keys.single == a[1]){
            element.update(a[1], (value) => value ? false : true);
          }
        });
      }else{
        groupedEvents[a[0]]?.removeWhere((element) => element.containsKey(a[1]));
        if (groupedEvents[a[0]]!.isEmpty) {
          groupedEvents.remove(a[0]);
        }
      }

      ParseEvents.writeEventsToFile(jsonEncode(groupedEvents));
    });

  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: json,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          }else if(snapshot.hasError){
            return Text("Ошибка!!! ${snapshot.error}");
          }else{
            groupedEvents.isEmpty ? print("trueeeeeeeeeeeeee") : print("falseeeeeeeeeeeeeee");
            groupedEvents = groupedEvents.isEmpty ?
            ToDoList.createMap(json: snapshot.data) : groupedEvents;
            groupedEvents.isEmpty ? print("trueeeeeeeeeeeeee") : print("falseeeeeeeeeeeeeee");
            print(groupedEvents);
            Map<String, List<Map<String, bool>>> toView = defineSetByType(type, groupedEvents);

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      color: const Color.fromRGBO(36,36,51, 1),
                      width: double.infinity,
                      child: ListView(
                        children: toView.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  dateFormatting(entry.key),
                                  style: const TextStyle(
                                    color: Color.fromRGBO(66, 72, 82, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              ...entry.value.map((task) {

                                bool done = bool.parse(task.values.first.toString());

                                return InkWell(
                                  onTap: () => changeGroupedEvents(
                                      [entry.key,task.keys.first]
                                  ),
                                  onLongPress: () => changeGroupedEvents(
                                      [entry.key,task.keys.first], remove: true
                                  ),
                                  splashColor: Colors.red,
                                  focusColor: Colors.red,
                                  highlightColor: Colors.transparent,
                                  radius: 1,

                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          done ? doneIcon : unDoneIcon,
                                          const SizedBox(width: 10.0),
                                          Flexible(
                                            child: Text(
                                              task.keys.first,
                                              style: const TextStyle(
                                                color: Color.fromRGBO(119, 132, 150, 1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }
    );
  }
}



String dateFormatting(String s){

  DateTime dt = DateTime.parse(s);
  // print(dt);
  // print(dt.subtract(Duration(days: 7)));

  DateFormat df = DateFormat("d MMMM");
  // print(df.format(dt));

  return df.format(dt);
}

Map<String, List<Map<String, bool>>>
defineSetByType(String type, Map<String, List<Map<String, bool>>> original){

  Map<String, List<Map<String, bool>>> map = Map.from(original);

  switch(type){
    case "Today":
      DateTime now = DateTime.now();
      DateFormat df = DateFormat("y-MM-dd");
      map.removeWhere((key, value) => !key.startsWith(df.format(now)));
      return map;

    case "This week":
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday));
      print(startOfWeek);
      print(startOfWeek.add(const Duration(days: 6)));

      map.removeWhere((key, value) {
        DateTime dateKey = DateFormat("y-MM-dd").parse(key);
        return dateKey.isBefore(startOfWeek) || dateKey.isAfter(startOfWeek.add(const Duration(days: 6)));
      });
      return map;

    case "Completed":
      print("Completed");
      Map<String, List<Map<String, bool>>> filteredMap = {};
      original.forEach((date, list) {

        var filteredList = list.where((entry) => entry.values.any((value) => value)).toList();

        if (filteredList.isNotEmpty) {
          filteredMap[date] = filteredList;
        }
      });
      return filteredMap;
  }
  return map;
  //тест
}


