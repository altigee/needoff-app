import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/utils/ui.dart';

class TeamCalendar extends StatefulWidget {
  @override
  _TeamCalendarState createState() => _TeamCalendarState();
}

class _TeamCalendarState extends State<TeamCalendar> {
  DateTime _currentDate;
  List get _currentLeaves => _leaves[_currentDate];
  bool get _hasCurrentLeaves => _currentLeaves != null;

  bool _isLoading = false;
  bool get loading => _isLoading;
  set loading(val) {
    setState((){
      _isLoading = val;
    });
  }

  final _scaffKey = GlobalKey<ScaffoldState>();

  void _setDate(DateTime date, List<Event> events) {
    setState(() {
      _currentDate = _currentDate == date ? null : date;
    });
  }

  @override
  void initState() {
    super.initState();
    loading = true;
    appState.fetchTeamLeaves()
    .then((res){
      print(res);
    })
    .catchError((e) {
      if (e is AppStateException) {
        snack(_scaffKey.currentState, e.message);
      } else {
        snack(_scaffKey.currentState, 'Something went wrong :(');
      }
    });
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'Team Calendar',
      key: _scaffKey,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[_buildCalendar(), Divider(), _buildEvents()],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    Color accent = Theme.of(context).accentColor;
    Color primary = Theme.of(context).primaryColor;
    TextStyle ts =
        TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500);
    TextStyle tsa = ts.copyWith(color: accent);
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: CalendarCarousel<Event>(
          onDayPressed: _setDate,
          weekFormat: _hasCurrentLeaves,
          markedDatesMap: _markedDateMap,
          markedDateMoreCustomTextStyle: tsa,
          markedDateShowIcon: false,
          markedDateIconBuilder: (event) {
            return event.icon ?? Container();
          },
          selectedDateTime: _currentDate,
          daysHaveCircularBorder: true,
          todayTextStyle: TextStyle(color: Colors.black),
          todayButtonColor: Colors.blueGrey[100],
          todayBorderColor: Colors.blueGrey[100],
          weekendTextStyle: tsa,
          daysTextStyle: ts,
          weekdayTextStyle: tsa,
          headerTextStyle: ts.copyWith(
              color: primary, fontWeight: FontWeight.w900, fontSize: 24),
          iconColor: primary,
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
            .pushNamed('/person-leaves', arguments: {'user': _user});
      },
    );
  }

  // MOCKED DATA
  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {
      new DateTime(2019, DateTime.may, 20): [
        new Event(
            date: new DateTime(2019, DateTime.may, 20),
            icon: Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: TypeColor[LeaveType.illness],
              ),
            )),
        new Event(
            date: new DateTime(2019, DateTime.may, 20),
            title: 'test',
            icon: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: TypeColor[LeaveType.vacation],
              ),
            )),
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

const TypeColor = {
  LeaveType.vacation: Colors.blueGrey,
  LeaveType.dayoff: Colors.blueGrey,
  LeaveType.illness: Colors.deepOrange,
  LeaveType.wfh: Colors.grey
};
