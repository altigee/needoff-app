import 'package:flutter/material.dart';

import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/utils/ui.dart';

class WorkspacesScreen extends StatefulWidget {
  @override
  _WorkspacesScreenState createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  int _activeWSId;
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  _listOrEmptyMsg() {
    if (appState.workspaces.length == 0) {
      return Center(
        child: Text('No entries found.'),
      );
    }
    return ListView(
      children:
          ListTile.divideTiles(context: context, tiles: _buildList()).toList(),
    );
  }

  _setCurrentWorkspace(ws) async {
    if (ws.id != null) {
      try {
        int id = ws.id;
        if (await storage.setWorkspace(id)) {
          setState(() {
            _activeWSId = id;
          });
        }
      } catch (e) {
        print('![ERROR] Can not set active workspace');
      }
    }
  }

  List<Widget> _buildList() {
    return appState.workspaces.map((item) {
      bool current = false;
      try {
        current = _activeWSId == item.id ? true : false;
      } catch (e) {}
      return ListTile(
        onTap: () {
          _setCurrentWorkspace(item);
        },
        contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 4),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        trailing: Icon(current
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked),
      );
    }).toList();
  }

  void _updateStateListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    storage.getWorkspace().then((id) => setState(() {
          _activeWSId = id;
        }));
    appState.changes.addListener(_updateStateListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loading = true;
    try {
      appState.fetchWorkspaces();
    } on AppStateException catch (e) {
      snack(context, e.message);
    } catch (e) {
      snack(context, 'Something went wrong');
    }
    loading = false;
  }

  @override
  void dispose() {
    appState.changes.removeListener(_updateStateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'workspaces',
      body: Center(
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _listOrEmptyMsg(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () {
          // _handleAddSick(context);
          print('add workspace');
          Navigator.of(context).pushNamed('/workspace-edit');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
