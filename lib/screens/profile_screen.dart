import 'package:flutter/material.dart';
import 'package:needoff/parts/info_row.dart';
import 'package:needoff/parts/widget_mixins.dart';
import 'package:needoff/utils/dates.dart';
import 'package:needoff/utils/ui.dart';

import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/parts/app_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with LoadingState {
  final _formKey = GlobalKey<FormState>();

  bool _autovalidate = false;

  TextEditingController _firstNameCtrl = TextEditingController();
  TextEditingController _lastNameCtrl = TextEditingController();
  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _phoneCtrl = TextEditingController();
  TextEditingController _positionCtrl = TextEditingController();

  _handleUpdate() async {
    if (_formKey.currentState.validate()) {
      print('update profile !!');
    }
  }

  _handleLogout() async {
    var res = await openConfirmation(context,
        title: 'Are you sure you want to logout?');
    if (res != null && res['ok']) {
      try {
        await appState.logout();
        Navigator.of(context)
            .popUntil((Route route) => route.settings.name == '/');
      } on AppStateException catch (e) {
        snack(context, e.message);
      } catch (e) {
        snack(context, 'Something went wrong :(');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _firstNameCtrl.text = appState?.profile?.firstName ?? '';
    _lastNameCtrl.text = appState?.profile?.lastName ?? '';
    _emailCtrl.text = appState?.profile?.email ?? '';
    _phoneCtrl.text = appState?.profile?.phone ?? '';
    _positionCtrl.text = appState?.profile?.position ?? '';
  }

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(
      height: 24,
    );
    return AppScaffold(
      'profile',
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        autovalidate: _autovalidate,
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              // autofocus: true,
                              decoration:
                                  InputDecoration(labelText: 'First Name'),
                              controller: _firstNameCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your first name.";
                                }
                              },
                            ),
                            TextFormField(
                              // autofocus: true,
                              decoration:
                                  InputDecoration(labelText: 'Last Name'),
                              controller: _lastNameCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your last name.";
                                }
                              },
                            ),
                            space,
                            InfoRow(
                                title: 'Email', value: appState.profile.email),
                            // space,
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Phone'),
                              controller: _phoneCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your phone.";
                                }
                              },
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Position'),
                              controller: _positionCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your position.";
                                }
                              },
                            ),
                            space,
                            space,
                            SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                onPressed: loading ? null : _handleUpdate,
                                child: Text('Update'),
                              ),
                            ),
                          ],
                        )),
                  ),
                  space,
                  FlatButton(
                    onPressed: loading ? null : _handleLogout,
                    child: Text('logout',
                        style: TextStyle(
                            inherit: true,
                            color: Theme.of(context).accentColor)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      // body: Container(
      //   child: Column(
      //     children: <Widget>[
      //       Text(appState.profile?.name ?? 'Unknown'),
      //       Text(appState.profile?.email ?? 'Unknown'),
      //       Text(appState.profile?.phone ?? 'Unknown'),
      //       Text(appState.profile?.position ?? 'Unknown'),
      //       Text(appState.profile?.startDate.toString() ?? 'Unknown'),
      //       RaisedButton(
      //         onPressed: () async {
      //           try {
      //             await appState.logout();
      //             Navigator.of(context)
      //                 .popUntil((Route route) => route.settings.name == '/');
      //           } on AppStateException catch (e) {
      //             snack(context, e.message);
      //           } catch (e) {
      //             snack(context, 'Something went wrong :(');
      //           }
      //         },
      //         child: Text('Logout'),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
