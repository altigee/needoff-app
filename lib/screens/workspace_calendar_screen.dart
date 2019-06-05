import 'package:flutter/material.dart';
import 'package:needoff/app_state.dart';
import 'package:needoff/models/profile.dart';
import 'package:needoff/models/workspace.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/utils/ui.dart';

class WorkspaceCalendarScreen extends StatefulWidget {
  @override
  _WorkspaceCalendarScreenState createState() =>
      _WorkspaceCalendarScreenState();
}

class _WorkspaceCalendarScreenState extends State<WorkspaceCalendarScreen> {
  int _calendarId;
  Calendar _calendar;
  List<Holiday> _holidays;
  Profile _owner;
  GlobalKey _scaffKey = GlobalKey<ScaffoldState>();
  Future loadCalendar() async {
    try {
      var res = await workspaceServ.fetchCalendar(_calendarId);
      if (res.hasErrors || res.data == null) {
        snack(_scaffKey.currentState, 'Failed to load calendar.');
        return;
      } else {
        _calendar = Calendar.fromJson(res.data['calendar']);
        _holidays = (res.data['holidays'] as List).map((item) {
          return Holiday.fromJson(item);
        }).toList();
        var ownerData = await workspaceServ.fetchOwner(_calendar.workspaceId);
        if (!ownerData.hasErrors && ownerData.data != null) {
          _owner = Profile(ownerData.data['owner']);
        }
      }
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map args = ModalRoute.of(context).settings.arguments;
      if (args != null && (_calendarId = Map.from(args)['id']) != null) {
        loadCalendar().whenComplete(() {
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = _owner != null ? _owner.id == appState.profile.id : false;
    return AppScaffold(
      _calendar?.name ?? 'Calendar',
      key: _scaffKey,
      body: Container(),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              label: Text('+ date'),
              backgroundColor: Theme.of(context).accentColor,
              onPressed: () {
                print('add holiday');
              },
            )
          : null,
    );
  }
}
