import 'package:flutter/material.dart';
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/widget_mixins.dart' show LoadingState;

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with LoadingState {
  int _wsId;
  _onStorageUpdate() {
    storage.getWorkspace().then((wsId) {
      _wsId = wsId;
    });
  }

  @override
  void initState() {
    super.initState();
    loading = true;
    storage.getWorkspace().then((wsId) {
      _wsId = wsId;
      return Future.delayed(Duration(milliseconds: 300), () {
        if (wsId == null) {
          Navigator.of(context).pushNamed('/workspaces');
        }
      });
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    });
    storage.changes.addListener(_onStorageUpdate);
  }

  @override
  void dispose() {
    storage.changes.removeListener(_onStorageUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'command center',
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                    child: Text('Profile'),
                  ),
                  FlatButton(
                    onPressed: _wsId == null
                        ? null
                        : () {
                            Navigator.of(context).pushNamed('/leaves');
                          },
                    child: Text('Leaves'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/workspaces');
                    },
                    child: Text('Workspaces'),
                  ),
                  FlatButton(
                    onPressed: _wsId == null
                        ? null
                        : () {
                            Navigator.of(context).pushNamed('/team-calendar');
                          },
                    child: Text('Team calendar'),
                  ),
                  FlatButton(
                    onPressed: _wsId == null
                        ? null
                        : () {
                            Navigator.of(context).pushNamed('/todo');
                          },
                    child: Text('Todo'),
                  ),
                ],
              ),
            ),
    );
  }
}
