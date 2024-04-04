import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_3_todo/ToDoAdd.dart';
import 'package:lab_3_todo/ToDoList.dart';
import 'package:lab_3_todo/ToDoMain.dart';

class Calendar extends StatefulWidget {
  final Function(String) setNewDate;
  const Calendar({super.key, required Function(String) this.setNewDate});

  @override
  State<Calendar> createState() => _CalendarState(setNewDate : setNewDate);
}

class _CalendarState extends State<Calendar> {
  final Function(String) setNewDate;
  _CalendarState ({required this.setNewDate});

  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentDate;
  }

  List<Widget> _buildDaysName() {
    return ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
        .map((day) => Expanded(child: Center(child: Text(day, style: TextStyle(color: Colors.white),))))
        .toList();
  }

  List<Widget> _buildCalendarDays(DateTime date) {
    List<Widget> dayWidgets = [];
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);

    int firstWeekdayOfMonth = firstDayOfMonth.weekday % 7;
    DateTime lastDayOfLastMonth = firstDayOfMonth.subtract(Duration(days: firstWeekdayOfMonth));

    for (var i = 0; i < 35; i++) {
      DateTime day = lastDayOfLastMonth.add(Duration(days: i));

      BoxDecoration decoration = BoxDecoration();
      TextStyle textStyle = TextStyle(color: Colors.blueGrey);

      if (day.isAtSameMomentAs(_selectedDate)) {
        DateFormat df = DateFormat("y-MM-dd");
        setNewDate(df.format(day));
        decoration = BoxDecoration(color: Colors.blue, shape: BoxShape.circle);
        textStyle = TextStyle(color: Colors.white);
      }else if (day.month == _currentDate.month) {
        textStyle = TextStyle(color: Colors.white);
      }
        //s
      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedDate = day;
              print("CLICKED TO $day");
            }),
            child: Container(
              decoration: decoration,
              child: Center(
                child: Text(
                  DateFormat('d').format(day),
                  style: textStyle,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  List<Row> _buildCalendar() {
    List<Row> calendarRows = [];
    List<Widget> weekDays = _buildDaysName();
    calendarRows.add(Row(children: weekDays));

    for (var i = 0; i < 5; i++) {
      var weekDays = _buildCalendarDays(_currentDate).sublist(i * 7, (i + 1) * 7);
      calendarRows.add(Row(children: weekDays));
    }

    return calendarRows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(36,36,51, 1),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
                  });
                },
              ),
              Text(DateFormat('MMMM y').format(_currentDate), style: TextStyle(color: Colors.white),),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
                  });
                },
              ),
            ],
          ),
          ..._buildCalendar(),
        ],
      ),
    );
  }
}
