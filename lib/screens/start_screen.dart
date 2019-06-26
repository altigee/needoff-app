import 'package:flutter/material.dart';
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/app_state.dart';
import 'package:needoff/main.dart';
import 'package:needoff/services/leaves.dart' as leavesServ;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/widget_mixins.dart' show LoadingState;

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with LoadingState, RouteAware {
  int _wsId;
  bool _hasTodo = false;
  _onStorageUpdate() {
    storage.getWorkspace().then((wsId) {
      _wsId = wsId;
    });
    storage.getToken().then((token) {
      if (token == null) {
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setStateFn = setState;
    loading = true;
    storage.getWorkspace().then((wsId) {
      _wsId = wsId;
      return _wsId != null
          ? appState.fetchLeavesForApproval()
          : Future.delayed(Duration(milliseconds: 300), () {
              Navigator.of(context).pushNamed('/workspaces');
            });
    }).whenComplete(() {
      loading = false;
    });
    storage.changes.addListener(_onStorageUpdate);
    appState.changes.addListener(_checkTodo);
  }

  _checkTodo() async {
    _hasTodo = appState.leavesForApproval.length > 0;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.unsubscribe(this);
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    storage.changes.removeListener(_onStorageUpdate);
    appState.changes.removeListener(_checkTodo);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // TODO: make own route for start_screen
  // actually active route is '/', so login_screen may also trigger this method
  @override
  void didPopNext() {
    super.didPopNext();
    // HACK while start_screen on the same route as login_screen - '/'
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) appState.fetchLeavesForApproval();
    });
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Todo'),
                        if (_hasTodo)
                          Icon(Icons.brightness_1,
                              color: Theme.of(context).accentColor, size: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
