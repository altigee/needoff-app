import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/models/leave.dart';
import 'package:needoff/utils/dates.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/utils/ui.dart';

class SickLeavesScreen extends StatefulWidget {
  @override
  _SickLeavesScreenState createState() => _SickLeavesScreenState();
}

class _SickLeavesScreenState extends State<SickLeavesScreen> {
  bool _addSickDialogOpened = false;
  final String sickLeaveType = 'LEAVE_SICK_LEAVE';
  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  _listOrEmptyMsg() {
    if (appState.leaves.length == 0) {
      return Center(
        child: Text('No entries found.'),
      );
    }
    return ListView(
      children:
          ListTile.divideTiles(context: context, tiles: _buildList()).toList(),
    );
  }

  List<Widget> _buildList() {
    List<Leave> data = appState.leaves;
    if (data == null) {
      data = [];
    }
    return data.map((item) {
      Duration diff = item.endDate.difference(item.startDate);
      String dates = '${formatDate(item.startDate)}';
      String days = '${(diff.inDays + 1).toString()} d';
      if (diff.inDays != 0) {
        dates += ' - ${formatDate(item.endDate)}';
      }
      return ListTile(
        onTap: () {},
        contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 4),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(dates),
            Text(days),
          ],
        ),
        subtitle: Text(item.comment ?? ''),
      );
    }).toList();
  }

  Future _showAddSickDialog(context) async {
    print('>> show add sick modal');
    _addSickDialogOpened = true;
    var result = await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final Widget actions = ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  print('cancel');
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  print('ok');
                  if (_formKey.currentState.validate()) {
                    // if (Form.of(context).validate()) {
                    var df = DateFormat.yMMMd();
                    Navigator.pop(
                        context,
                        Leave(sickLeaveType, df.parse(_startInpCtrl.text),
                            df.parse(_endInpCtrl.text), _commentInpCtrl.text));
                  }
                },
              ),
            ],
          ),
        );

        FocusNode fn = FocusNode();

        return SimpleDialog(
          title: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "I'm sick :(",
                style: Theme.of(context)
                    .textTheme
                    .title
                    .apply(color: Colors.white),
              ),
            ),
          ),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.fromLTRB(16, 32, 16, 0),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                  height: 250,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextField(
                          onTap: () async {
                            fn.unfocus();
                            var res = await _showDatePicker();
                            print('[DATE SELECTED] :: ');
                            print(res);
                            if (res != null) {
                              _startInpCtrl.text = formatDate(res);
                            }
                          },
                          controller: _startInpCtrl,
                          focusNode: fn,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            labelText: 'From:',
                          ),
                        ),
                        TextField(
                          onTap: () async {
                            fn.unfocus();
                            var res = await _showDatePicker();
                            print('[DATE SELECTED] :: ');
                            print(res);
                            if (res != null) {
                              _endInpCtrl.text = formatDate(res);
                            }
                          },
                          controller: _endInpCtrl,
                          focusNode: fn,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            labelText: 'To:',
                          ),
                        ),
                        TextFormField(
                          controller: _commentInpCtrl,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a comment';
                            }
                          },
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Comment:',
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            actions,
          ],
        );
      },
    );
    _addSickDialogOpened = false;
    return result;
  }

  Future _showDatePicker() {
    return showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2020),
        initialDate: DateTime.now());
  }

  _handleAddSick(context) async {
    if (_addSickDialogOpened == true) {
      return null;
    }
    Leave newLeave = await _showAddSickDialog(context);
    if (newLeave != null) {
      try {
        await appState.addLeave(newLeave);
      } on AppStateException catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((timestamp) {
          snack(_scaffoldKey.currentState, e.message);
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((timestamp) {
          snack(_scaffoldKey.currentState, 'Something went wrong :(');
        });
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _startInpCtrl =
      TextEditingController(text: formatDate(DateTime.now()));
  TextEditingController _endInpCtrl =
      TextEditingController(text: formatDate(DateTime.now()));
  TextEditingController _commentInpCtrl = TextEditingController(text: 'test');

  void _updateListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      Map args = ModalRoute.of(context).settings.arguments;
      var ctx = context;
      Future.delayed(Duration(milliseconds: 100), () {
        print(args);
        try {
          if (args != null && Map.from(args)['addSickToday'] == true) {
            _handleAddSick(ctx);
          }
        } catch (e) {}
      });
    });

    appState.changes.addListener(_updateListener);
    appState.fetchLeaves();
  }

  @override
  void dispose() {
    appState.changes.removeListener(_updateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'sick days',
      key: _scaffoldKey,
      body: Container(
        child: _listOrEmptyMsg(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () {
          _handleAddSick(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
