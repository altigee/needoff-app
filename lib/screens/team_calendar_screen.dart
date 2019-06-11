import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/utils/dates.dart';
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
  Map<DateTime, List> _leavesByDate = {};
  Map<DateTime, List> _workspaceDatesByDate = {};

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
    _makeEvents().whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  Future<dynamic> _makeEvents() async {
    try {
      _eventList = EventList<Event>(events: {});
      var leaves = await appState.fetchTeamLeaves();
      _mapLeavesToEvents(leaves);
      var workspaceDates = await appState.fetchTeamWorkspaceDates();
      _mapWorkspaceDatesToEvents(workspaceDates);
      setState(() {});
    } on AppStateException catch (e) {
      snack(_scaffKey.currentState, e.message);
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    }
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

  _mapLeavesToEvents(data) {
    Map<String, List> leavesByType = {
      LeaveTypes.SICK_LEAVE: [],
      LeaveTypes.VACATION: [],
      LeaveTypes.DAY_OFF: [],
      LeaveTypes.WFH: [],
    };

    for (var item in data) {
      if (leavesByType[item.type] != null) {
        leavesByType[item.type].add(item);
      }
    }

    _leavesByDate = {};

    Map<String, List> addedTypes = {};

    for (var type in leavesByType.keys) {
      addedTypes[type] = [];
      for (var leave in leavesByType[type]) {
        DateTime startDate = leave.startDate;
        DateTime endDate = leave.endDate;
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

  _mapWorkspaceDatesToEvents(List workspaceDatesData) {
    print('map workspaceDates');
    _workspaceDatesByDate = {};
    workspaceDatesData.asMap().forEach((idx, day) {
      if (_workspaceDatesByDate[day.date] == null) {
        _workspaceDatesByDate[day.date] = [];
      }
      var color = Colors.black54;
      _workspaceDatesByDate[day.date].add({
        'workspaceDate': day,
        'color': color,
      });
      _eventList.add(
          day.date,
          Event(
            date: day.date,
            icon: _buildEventIcon(color),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'Team Calendar',
      key: _scaffKey,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () {
                return _makeEvents();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildCalendar(),
                      if (_currentDate != null) ...[Divider(), _buildEvents()]
                    ],
                  ),
                ),
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
      flex: 2,
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

    List dayWorkspaceDates = _workspaceDatesByDate[_currentDate] ?? [];
    _events.addAll(dayWorkspaceDates.map((item) {
      return ListTile(
        leading: Icon(
          Icons.calendar_today,
          size: 32,
        ),
        title: Text(item['workspaceDate'].name),
        subtitle: Text(
            item['workspaceDate'].isOfficialHoliday
                ? 'Public Holiday'
                : 'Workday',
            style: TextStyle(
              inherit: true,
              color: item['color'],
            )),
      );
    }));

    return Expanded(
      flex: 5,
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
                child: _events.length > 0
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
    Map user = leave.userData;
    var type = leave.type;

    String userDisplay = '${user['firstName']} ${user['lastName']}';
    if (userDisplay.isEmpty) {
      userDisplay = user['email'];
    } 

    String _userInits = user["name"] ?? user['email'][0];

    Widget _userAvatar = CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      child: Text(
        '$_userInits',
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );

    String typeLabel = LeaveTypeLabels[type];
    var start = leave.startDate;
    var end = leave.endDate;
    String daysLabel =
        start != end ? '${formatDate(start)} - ${formatDate(end)}' : '1 day';

    return ListTile(
      leading: _userAvatar,
      title: Text(userDisplay),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$typeLabel ${start == end ? '($daysLabel)' : ''}',
            style: TextStyle(color: LeaveTypeColors[type]),
          ),
          if (start != end) Text(
            daysLabel,
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
