import 'package:flutter/material.dart';
import 'package:needoff/parts/app_scaffold.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'command center',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/profile');
              },
              child: Text('Profile'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/leaves');
              },
              child: Text('Leaves'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/workspaces');
              },
              child: Text('Workspaces'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/team-calendar');
              },
              child: Text('Team calendar'),
            ),
          ],
        ),
      ),
    );
  }
}
