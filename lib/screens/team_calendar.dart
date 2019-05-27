import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

class TeamCalendar extends StatefulWidget {
  @override
  _TeamCalendarState createState() => _TeamCalendarState();
}

class _TeamCalendarState extends State<TeamCalendar> {
  DateTime _currentDate;
  List get _currentLeaves => _leaves[_currentDate];
  bool get _hasCurrentLeaves => _currentLeaves != null;

  void _setDate(DateTime date, List<Event> events) {
    setState(() {
      _currentDate = _currentDate == date ? null : date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Calendar'),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[_buildCalendar(), Divider(), _buildEvents()],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: CalendarCarousel<Event>(
          onDayPressed: _setDate,
          weekFormat: _hasCurrentLeaves,
          markedDatesMap: _markedDateMap,
          selectedDateTime: _currentDate,
          daysHaveCircularBorder: true,
          todayTextStyle: TextStyle(color: Colors.black),
          todayButtonColor: Colors.blueGrey[100],
          todayBorderColor: Colors.blueGrey[100],
          weekendTextStyle: TextStyle(color: Colors.red),
          markedDateMoreCustomTextStyle: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildEvents() {
    if (_currentLeaves == null) {
      return Container();
    }

    List<Widget> _events = _currentLeaves.map((leave) {
      return _buildUser(leave);
    }).toList();

    return Expanded(
      flex: 3,
      child: Container(
        child: ListView(children: _events),
        margin: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildUser(leave) {
    Map _leave = leave["leave"];
    Map _user = leave["user"];

    LeaveType _leaveType = _leave["type"];
    String _userInits = _user["name"][0];
    int _days = _leave["days"];

    Widget _userAvatar = CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      child: Text(
        '$_userInits',
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );

    const TypeColor = {
      LeaveType.vacation: Colors.blueGrey,
      LeaveType.dayoff: Colors.blueGrey,
      LeaveType.illness: Colors.deepOrange,
      LeaveType.wfh: Colors.grey
    };

    String _daysLabel =
        Intl.plural(_days, one: '$_days day', other: '$_days days');

    return ListTile(
      leading: _userAvatar,
      title: Text('${_user["name"]}'),
      subtitle: Text(
        '${LeaveTypeLabel[_leaveType]} - ($_daysLabel)',
        style: TextStyle(color: TypeColor[_leaveType]),
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed('/person_leaves', arguments: {'user': _user});
      },
    );
  }

  // MOCKED DATA
  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {
      new DateTime(2019, DateTime.may, 20): [
        new Event(date: new DateTime(2019, DateTime.may, 20)),
        new Event(date: new DateTime(2019, DateTime.may, 20)),
        new Event(date: new DateTime(2019, DateTime.may, 20)),
      ],
      new DateTime(2019, DateTime.may, 21): [
        new Event(date: new DateTime(2019, DateTime.may, 21)),
      ],
      new DateTime(2019, DateTime.may, 22): [
        new Event(date: new DateTime(2019, DateTime.may, 22)),
        new Event(date: new DateTime(2019, DateTime.may, 22)),
      ],
    },
  );

  Map _leaves = {
    new DateTime(2019, DateTime.may, 20): [
      {
        "user": {"name": 'Vasiliy Grigorovic'},
        "leave": {"type": LeaveType.illness, "days": 4}
      },
      {
        "user": {"name": 'Ben Maksymenko'},
        "leave": {"type": LeaveType.dayoff, "days": 1}
      },
      {
        "user": {"name": 'Konan Varvarius'},
        "leave": {"type": LeaveType.vacation, "days": 13}
      },
    ]
  };
}

enum LeaveType { vacation, dayoff, illness, wfh }
const LeaveTypeLabel = {
  LeaveType.vacation: 'Vacation',
  LeaveType.dayoff: 'Day Off',
  LeaveType.illness: 'Ilness',
  LeaveType.wfh: 'Work from home',
};
