import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:needoff/app_state.dart';
import 'package:needoff/parts/app_scaffold.dart';

class WorkSpacesScreen extends StatefulWidget {
  @override
  _WorkSpacesScreenState createState() => _WorkSpacesScreenState();
}

class _WorkSpacesScreenState extends State<WorkSpacesScreen> {
  AppStateModel _state;
  _listOrEmptyMsg() {
    if (_state.profile.workspaces == null || _state.profile.workspaces.length == 0) {
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
    List data = _state.profile.workspaces;
    if (data == null) {
      data = [];
    }
    return data.map((item) {
      return ListTile(
        onTap: () {},
        contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 4),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
      );
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('SICK LEAVES SCREEN :: didChangeDependencies()');
    _state = ScopedModel.of<AppStateModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'workspaces',
      body: Center(
        child: _listOrEmptyMsg(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () {
          // _handleAddSick(context);
          print('add workspace');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
