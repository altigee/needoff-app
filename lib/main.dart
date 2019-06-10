import 'package:flutter/material.dart';

import 'package:needoff/app_state.dart' show appState;
import 'package:needoff/screens/leaves_balance_screen.dart';
import 'package:needoff/screens/person_leaves_screen.dart';
import 'package:needoff/screens/team_calendar_screen.dart';
import 'package:needoff/screens/start_screen.dart';
import 'package:needoff/screens/login_screen.dart';
import 'package:needoff/screens/registration_screen.dart';
import 'package:needoff/screens/forgot_password_screen.dart';
import 'package:needoff/screens/profile_screen.dart';
import 'package:needoff/screens/profile_edit_screen.dart';
import 'package:needoff/screens/workspaces_screen.dart';
import 'package:needoff/screens/workspace_create_screen.dart';
import 'package:needoff/screens/workspace_profile_screen.dart';
import 'package:needoff/parts/leaves_screen_base.dart';

import 'package:needoff/models/leave.dart' show LeaveTypes;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Theme.of(context).copyWith(
        primaryColor: Color(0xff030322),
        accentColor: Color(0xffff0033),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Montserrat'),
      ),
      routes: {
        '/': (BuildContext context) => Root(),
        '/profile': (BuildContext context) => ProfileScreen(),
        '/profile/edit': (BuildContext context) => ProfileEditScreen(),
        '/leaves': (BuildContext context) => LeavesBalanceScreen(),
        '/leaves/sick': (BuildContext context) => LeavesScreenBase(
              leaveType: LeaveTypes.SICK_LEAVE,
              screenTitle: 'sick days',
            ),
        '/leaves/vac': (BuildContext context) => LeavesScreenBase(
              leaveType: LeaveTypes.VACATION,
              screenTitle: 'vacations',
            ),
        '/leaves/wfh': (BuildContext context) => LeavesScreenBase(
              leaveType: LeaveTypes.WFH,
              screenTitle: 'work from *',
            ),
        '/registration': (BuildContext context) => RegistrationScreen(),
        '/forgot-pwd': (BuildContext context) => ForgotPasswordScreen(),
        '/workspaces': (BuildContext context) => WorkspacesScreen(),
        '/workspace-edit': (BuildContext context) => WorkspaceCreateScreen(),
        '/workspace-profile': (BuildContext context) => WorkspaceProfileScreen(),
        '/team-calendar': (BuildContext context) => TeamCalendar(),
        '/person-leaves': (BuildContext context) => PersonLeaves(),
      },
      initialRoute: '/',
    );
  }
}

class Root extends StatefulWidget {
  Root({Key key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  var _profileFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileFuture = appState.fetchProfile();
  }

  get _body {
    Widget body;
    if (appState.profile == null) {
      body = LoginScreen();
    } else {
      print('***HAS PROFILE***');
      body = StartScreen();
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _profileFuture,
        builder: (context, snapshot) {
          print(' MAIN FUTURE BUILDER ');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return _body;
        });
  }
}
