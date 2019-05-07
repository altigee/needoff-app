import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:needoff/app_state.dart' as appState;

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  appState.AppStateModel _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = ScopedModel.of<appState.AppStateModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('command center', style: TextStyle(fontFamily: 'Orbitron')),
      ),
      body: Container(
        child: Column(
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
          ],
        ),
      ),
    );
  }
}
