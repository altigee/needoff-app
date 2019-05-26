import 'package:flutter/material.dart';
import 'package:needoff/utils/ui.dart';

import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/parts/app_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'profile',
      body: Container(
        child: Column(
          children: <Widget>[
            Text(appState.profile?.name ?? 'Unknown'),
            Text(appState.profile?.email ?? 'Unknown'),
            Text(appState.profile?.phone ?? 'Unknown'),
            Text(appState.profile?.position ?? 'Unknown'),
            Text(appState.profile?.startDate.toString() ?? 'Unknown'),
            RaisedButton(
              onPressed: () async {
                try {
                  await appState.logout(); 
                  Navigator.of(context).popUntil((Route route) => route.settings.name == '/');
                } on AppStateException catch(e) {
                  snack(context, e.message);
                } catch (e) {
                  snack(context, 'Something went wrong :(');
                }
              },
              child: Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}