import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:needoff/app_state.dart';
import 'package:needoff/models/profile.dart';
import 'package:needoff/models/workspace.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/info_row.dart';
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/utils/dates.dart';
import 'package:needoff/utils/ui.dart';

class WorkspaceCalendarScreen extends StatefulWidget {
  @override
  _WorkspaceCalendarScreenState createState() =>
      _WorkspaceCalendarScreenState();
}

class _WorkspaceCalendarScreenState extends State<WorkspaceCalendarScreen> {
  int _calendarId;
  Calendar _calendar;
  List<Holiday> _holidays = [];
  Profile _owner;
  GlobalKey _scaffKey = GlobalKey<ScaffoldState>();
  // GlobalKey _formKey = GlobalKey<FormState>();
  // TextEditingController _nameCtrl = TextEditingController();

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
        // _nameCtrl.text = _calendar.name;
      }
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    }
    setState(() {});
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

  _handleAddHoliday() async {
    var formKey = GlobalKey<FormState>();
    var nameCtrl = TextEditingController();
    var dateCtrl = TextEditingController();
    var fn = FocusNode();
    var holidayData = await openEditFormDialog(context,
        dialogTitle: 'Add date',
        form: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: nameCtrl,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a name';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Title:',
                ),
              ),
              TextField(
                onTap: () async {
                  fn.unfocus();
                  var res = await openDatePicker(context,
                      firstDate: DateTime.now().subtract(Duration(days: 365)));
                  if (res != null) {
                    dateCtrl.text = formatDate(res);
                  }
                },
                controller: dateCtrl,
                focusNode: fn,
                enableInteractiveSelection: false,
                decoration: InputDecoration(labelText: 'Date:'),
              ),
            ],
          ),
        ), onCancel: () {
      Navigator.of(context).pop();
    }, onOk: () {
      if (formKey.currentState.validate()) {
        Navigator.of(context).pop(
            {'name': nameCtrl.text, 'date': parseFormatted(dateCtrl.text)});
      }
    });
    try {
      var res = await workspaceServ.addHoliday(
        _calendar.id,
        holidayData['date'],
        holidayData['name'],
      );
      if (res.hasErrors) {
        snack(_scaffKey.currentState, 'Failed to add holiday.');
      }
      await loadCalendar();
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    }
  }

  _handleRemoveHoliday(int id) async {
    try {
      var res = await workspaceServ.removeHoliday(id);
      if (res.hasErrors) {
        snack(_scaffKey, 'Failed to remove holiday from calendar.');
      } else {
        loadCalendar();
      }
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = _owner != null ? _owner.id == appState.profile.id : false;
    var listTiles = _holidays.map((item) {
      return Dismissible(
        key: ValueKey('${item.id}'),
        confirmDismiss: (direction) async {
          var res = await openConfirmation(context,
              title: 'Are you sure?', okLabel: 'remove');
          if (res != null && res['ok']) {
            return true;
          } else {
            return false;
          }
        },
        direction: DismissDirection.endToStart,
        dismissThresholds: {DismissDirection.endToStart: 0.2},
        background: Container(
          // padding: EdgeInsets.only(right: 24),
          child: ListTile(
            title: Text(item.name, style: TextStyle(inherit: true, color: Colors.white),),
            trailing: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
          ),
          color: Theme.of(context).accentColor,
        ),
        onDismissed: (_) {
          print('${item.name} dismissed');
          _handleRemoveHoliday(item.id);
        },
        child: ListTile(
          title: Text(item.name),
          trailing: Text(formatDate(item.date)),
        ),
      );
    });
    return AppScaffold(
      _calendar?.name ?? 'Calendar',
      key: _scaffKey,
      body: Container(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: listTiles,
          ).toList(),
        ),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              label: Text('+ date'),
              backgroundColor: Theme.of(context).accentColor,
              onPressed: () {
                print('add holiday');
                _handleAddHoliday();
              },
            )
          : null,
    );
  }
}
