import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:needoff/app_state.dart' as appState;
import 'package:needoff/models/user_model.dart';

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
    _state.addListener((){
      print(_state.profile);
      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProfile profile = _state.profile;
    return Scaffold(
      appBar: AppBar(
        title: Text('profile', style: TextStyle(fontFamily: 'Orbitron')),
        actions: <Widget>[
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed('/profile/edit');
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text(profile?.name ?? 'Unknown'),
            Text(profile?.email ?? 'Unknown'),
            Text(profile?.phone ?? 'Unknown'),
            Text(profile?.position ?? 'Unknown'),
            Text(profile?.startDate.toString() ?? 'Unknown'),
          ],
        ),
      ),
    );
  }
}