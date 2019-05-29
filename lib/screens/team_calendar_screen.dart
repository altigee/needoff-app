import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/utils/ui.dart';
import 'package:needoff/models/leave.dart'
    show LeaveTypes, LeaveTypeColors, LeaveTypeLabels;
import 'package:needoff/parts/widget_mixins.dart' show LoadingState;

class TeamCalendar extends StatefulWidget {
  @override
  _TeamCalendarState createState() => _TeamCalendarState();
}

class _TeamCalendarState extends State<TeamCalendar> with LoadingState {
  DateTime _currentDate;

  EventList<Event> _eventList;
  Map<DateTime, List> _leavesByDate;

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
    appState.fetchTeamLeaves().then((res) {
      print(res);
      _mapToEvents(res);
      setState(() {});
    }).catchError((e) {
      if (e is AppStateException) {
        snack(_scaffKey.currentState, e.message);
      } else {
        snack(_scaffKey.currentState, 'Something went wrong :(');
      }
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  _buildEventIcon(color) {
    return Container(
      width: 4,
      height: 4,
      margin: EdgeInsets.only(right: 2, left: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: color,
      ),
    );
  }

  _mapToEvents(data) {
    Map<String, List> leavesByType = {
      LeaveTypes.SICK_LEAVE: [],
      LeaveTypes.VACATION: [],
      LeaveTypes.DAY_OFF: [],
      LeaveTypes.WFH: [],
    };

    for (var item in data) {
      if (leavesByType[item['leaveType']] != null) {
        leavesByType[item['leaveType']].add(item);
      }
    }

    _eventList = EventList<Event>(events: {});
    _leavesByDate = {};

    Map<String, List> addedTypes = {};

    for (var type in leavesByType.keys) {
      addedTypes[type] = [];
      for (var leave in leavesByType[type]) {
        DateTime startDate = DateTime.parse(leave['startDate']);
        DateTime endDate = DateTime.parse(leave['endDate']);
        int duration = endDate.difference(startDate).inDays + 1;
        if (duration < 0) {
          continue;
        }
        for (var i = 0; i < duration; i++) {
          DateTime d = startDate.add(Duration(days: i));
          if (d.weekday > 5) continue; //skip weekend
          if (_leavesByDate[d] == null) {
            _leavesByDate[d] = [];
          }
          _leavesByDate[d].add(leave);
          if (!addedTypes[type].contains(d)) {
            _eventList.add(
                d,
                Event(
                  date: d,
                  icon: _buildEventIcon(LeaveTypeColors[type]),
                ));
            addedTypes[type].add(d);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'Team Calendar',
      key: _scaffKey,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildCalendar(),
                  if (_currentDate != null) ...[Divider(), _buildEvents()]
                ],
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
          weekFormat: _currentDate != null,
          markedDatesMap: _eventList,
          markedDateMoreCustomTextStyle: tsa,
          markedDateShowIcon: false,
          markedDateIconBuilder: (event) {
            return event.icon ?? Container();
          },
          selectedDateTime: _currentDate,
          daysHaveCircularBorder: true,
          todayTextStyle: TextStyle(color: Colors.black),
          todayButtonColor: Colors.blueGrey[50],
          todayBorderColor: Colors.blueGrey[50],
          weekendTextStyle: tsa,
          daysTextStyle: ts,
          weekdayTextStyle: tsa,
          selectedDayButtonColor: null,
          selectedDayBorderColor: primary,
          selectedDayTextStyle: ts.copyWith(color: primary),
          headerTextStyle: ts.copyWith(
              color: primary, fontWeight: FontWeight.w900, fontSize: 24),
          iconColor: primary,
        ),
      ),
    );
  }

  Widget _buildEvents() {
    List dayLeaves = _leavesByDate[_currentDate] ?? [];

    List<Widget> _events = dayLeaves.map((leave) {
      return _buildUser(leave);
    }).toList();

    return Expanded(
      flex: 3,
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    iconSize: 16,
                    color: Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentDate = null;
                      });
                    },
                    icon: Icon(Icons.close),
                  )
                ],
              ),
            ),
            Expanded(
                child: dayLeaves.length > 0
                    ? ListView(children: _events)
                    : Center(
                        child: Text('No entries.',
                            style: Theme.of(context).textTheme.body1))),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildUser(leave) {
    Map user = leave["user"];
    int days = 2;
    var type = leave['leaveType'];

    String _userInits = user["name"] ?? user['email'][0];

    Widget _userAvatar = CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      child: Text(
        '$_userInits',
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );

    String typeLabel = LeaveTypeLabels[type];
    String daysLabel = Intl.plural(days, one: '$days day', other: '$days days');

    return ListTile(
      leading: _userAvatar,
      title: Text('${user["email"]}'),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$typeLabel - ($daysLabel)',
            style: TextStyle(color: LeaveTypeColors[type]),
          ),
          Text(
            leave['comment'] ?? '',
            style: Theme.of(context).textTheme.caption,
          )
        ],
      ),
      isThreeLine: true,
      onTap: () {
        Navigator.of(context)
            .pushNamed('/person-leaves', arguments: {'user': user});
      },
    );
  }
}
