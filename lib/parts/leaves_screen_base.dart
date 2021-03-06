import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/models/leave.dart';
import 'package:needoff/utils/dates.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/widget_mixins.dart' show LoadingState;
import 'package:needoff/utils/ui.dart';

class LeavesScreenBase extends StatefulWidget {
  final String leaveType;
  final String screenTitle;
  LeavesScreenBase({String leaveType, String screenTitle, Key key})
      : this.leaveType = leaveType,
        this.screenTitle = screenTitle,
        super(key: key);
  @override
  _LeavesScreenBaseState createState() => _LeavesScreenBaseState();
}

class _LeavesScreenBaseState extends State<LeavesScreenBase> with LoadingState {
  bool _addLeaveDialogOpened = false;
  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Leave> _leaves = [];

  _listOrEmptyMsg() {
    if ((_leaves ?? []).length == 0) {
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
    List<Leave> data = _leaves ?? [];
    return data.map((item) {
      Duration diff = item.endDate.difference(item.startDate);
      String dates = '${formatDate(item.startDate)}';
      String days = '${(diff.inDays + 1).toString()} d';
      if (diff.inDays != 0) {
        dates += ' - ${formatDate(item.endDate)}';
      }
      String approvalStr;
      if (item.approverData != null) {
        approvalStr =
            'Approved by ${item.approverData['firstName']}  ${item.approverData['lastName']}';
      } else {
        approvalStr = 'Pending approval';
      }
      return ListTile(
        onTap: () {},
        contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 4),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(dates),
            Text(days,
                style: TextStyle(
                    inherit: true,
                    color: item.approverData != null
                        ? LeaveTypeColors[widget.leaveType]
                        : Colors.grey)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(item.comment ?? ''),
            Text(approvalStr,
                style: TextStyle(
                  inherit: true,
                  fontSize: 10,
                )),
          ],
        ),
      );
    }).toList();
  }

  Future _showAddLeaveDialog(context) async {
    _addLeaveDialogOpened = true;
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
                        Leave(widget.leaveType, df.parse(_startInpCtrl.text),
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
                "Choose timeframe",
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
                            if (res != null) {
                              _startInpCtrl.text = formatDate(res);
                            }
                          },
                          controller: _startInpCtrl,
                          focusNode: fn,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            labelText: 'First day:',
                          ),
                        ),
                        TextField(
                          onTap: () async {
                            fn.unfocus();
                            var res = await _showDatePicker();
                            if (res != null) {
                              _endInpCtrl.text = formatDate(res);
                            }
                          },
                          controller: _endInpCtrl,
                          focusNode: fn,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            labelText: 'Last day:',
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
    _addLeaveDialogOpened = false;
    return result;
  }

  Future _showDatePicker() {
    return showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2020),
        initialDate: DateTime.now());
  }

  _showValidationResults(errors, warnings, notes) {
    return showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ...errors
                      .map((txt) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 24,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Flexible(
                                  child: Text(
                                txt,
                                softWrap: true,
                              )),
                            ],
                          )))
                      .toList(),
                  ...warnings
                      .map((txt) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 24,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Flexible(
                                  child: Text(
                                txt,
                                softWrap: true,
                              )),
                            ],
                          )))
                      .toList(),
                  ...notes
                      .map((txt) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 24,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.info,
                                    color: Colors.blueGrey,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Flexible(
                                  child: Text(
                                txt,
                                softWrap: true,
                              )),
                            ],
                          )))
                      .toList(),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _handleAddLeave(context) async {
    if (_addLeaveDialogOpened == true) {
      return null;
    }
    Leave newLeave = await _showAddLeaveDialog(context);
    if (newLeave != null) {
      loading = true;
      try {
        var res = await appState.addLeave(newLeave);
        var data = res.data['createDayOff'];
        if (data != null) {
          var errors = data['errors'];
          var warnings = data['warnings'];
          var notes = data['notes'];
          if (errors != null || warnings != null || notes != null) {
            await _showValidationResults(errors ?? [], warnings ?? [], notes ?? []);
            if (data['dayOff'] != null) {
              snack(_scaffoldKey, 'Request submitted for approval.');
            } else {
              snack(_scaffoldKey, 'Failed to add day off.');
            }
          }
        } else {
          snack(_scaffoldKey, 'Something went wrong :(');
        }
      } on AppStateException catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((timestamp) {
          snack(_scaffoldKey.currentState, e.message);
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((timestamp) {
          snack(_scaffoldKey.currentState, 'Something went wrong :(');
        });
      }
      loading = false;
    }
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _startInpCtrl =
      TextEditingController(text: formatDate(DateTime.now()));
  TextEditingController _endInpCtrl =
      TextEditingController(text: formatDate(DateTime.now()));
  TextEditingController _commentInpCtrl = TextEditingController();

  void _updateListener() {
    setState(() {
      _filterByType();
    });
  }

  @override
  void initState() {
    super.initState();
    setStateFn = setState;
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      Map args = ModalRoute.of(context).settings.arguments;
      var ctx = context;
      Future.delayed(Duration(milliseconds: 100), () {
        print(args);
        try {
          if (args != null && Map.from(args)['addLeave'] == true) {
            _handleAddLeave(ctx);
          }
        } catch (e) {}
      });
    });

    appState.changes.addListener(_updateListener);
    loadLeaves();
  }

  void loadLeaves() {
    loading = true;
    appState.fetchLeaves().then((res) {
      _filterByType();
    }).catchError((e) {
      if (e is AppStateException) {
        snack(_scaffoldKey.currentState, e.message);
      } else {
        snack(_scaffoldKey.currentState, 'Something went wrong :(');
      }
    }).whenComplete(() {
      loading = false;
    });
  }

  void _filterByType() {
    _leaves =
        appState.leaves.where((item) => item.type == widget.leaveType).toList();
  }

  @override
  void dispose() {
    appState.changes.removeListener(_updateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      widget.screenTitle,
      key: _scaffoldKey,
      body: Container(
        child: loading
            ? Center(child: CircularProgressIndicator())
            : _listOrEmptyMsg(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () {
          _handleAddLeave(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
