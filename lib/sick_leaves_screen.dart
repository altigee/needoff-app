import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:needoff/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:needoff/app_state.dart';
import 'package:needoff/utils/dates.dart';

class SickLeavesScreen extends StatefulWidget {
  @override
  _SickLeavesScreenState createState() => _SickLeavesScreenState();
}

class _SickLeavesScreenState extends State<SickLeavesScreen> {
  AppStateModel _state;
  // _formatDate(DateTime date) {
  //   return intl.DateFormat.yMMMd().format(date);
  // }

  List<Widget> _buildList() {
    List<Leave> data = _state.profile.leaves['sick_days'];
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
        subtitle: Text(item.comment),
      );
    }).toList();
  }

  Future _showDatePicker() {
    return showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime(2020),
        initialDate: DateTime.now());
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _startInpCtrl =
      TextEditingController(text: formatDate(DateTime.now()));
  TextEditingController _endInpCtrl =
      TextEditingController(text: formatDate(DateTime.now()));
  TextEditingController _commentInpCtrl = TextEditingController();

  void _updateListener() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = ScopedModel.of<AppStateModel>(context);
    _state.addListener(_updateListener);
  }

  @override
  void dispose() {
    super.dispose();
    _state.removeListener(_updateListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sick days', style: TextStyle(fontFamily: 'Orbitron')),
      ),
      body: Container(
        child: ListView(
          children: ListTile.divideTiles(context: context, tiles: _buildList())
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('[ACTION] :: add sick leave');
          Leave newLeave = await showDialog(
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
                          var df = DateFormat.yMMMd();
                          Navigator.pop(
                              context,
                              Leave(
                                  df.parse(_startInpCtrl.text),
                                  df.parse(_endInpCtrl.text),
                                  _commentInpCtrl.text));
                        }
                      },
                    ),
                  ],
                ),
              );

              FocusNode fn = FocusNode();

              return SimpleDialog(
                title: Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
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
          print('[NEW LEAVE] ::');
          print([newLeave?.startDate, newLeave?.endDate, newLeave?.comment]);
          if (newLeave != null) {
            _state.addSickLeave(newLeave);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
