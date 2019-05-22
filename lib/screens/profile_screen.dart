import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:needoff/app_state.dart' as appState;
import 'package:needoff/models/user_model.dart';
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/parts/app_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  appState.AppStateModel _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = ScopedModel.of<appState.AppStateModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    UserProfile profile = _state.profile;
    return AppScaffold(
      'profile',
      body: Container(
        child: Column(
          children: <Widget>[
            Text(profile?.name ?? 'Unknown'),
            Text(profile?.email ?? 'Unknown'),
            Text(profile?.phone ?? 'Unknown'),
            Text(profile?.position ?? 'Unknown'),
            Text(profile?.startDate.toString() ?? 'Unknown'),
            RaisedButton(
              onPressed: () {
                storage.removeToken();
                storage.removeWorkspace();
                _state.profile = null;
                Navigator.of(context).popUntil((Route route) => route.settings.name == '/');
              },
              child: Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}