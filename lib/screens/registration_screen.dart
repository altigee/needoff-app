import 'package:flutter/material.dart';

import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/models/credentials.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/utils/ui.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _pwdCtrl = TextEditingController();
  TextEditingController _pwd2Ctrl = TextEditingController();

  void _loading(bool val) {
    setState(() {
      _isLoading = val;
    });
  }

  Future _handleCreateAccount() async {
    if (_formKey.currentState.validate()) {
      _loading(true);
      try {
        await appState.signup(Credentials(_emailCtrl.text, _pwdCtrl.text));
      } on AppStateException catch(e) {
        snack(_formKey.currentContext, e.message);
      } catch (e) {
        snack(_formKey.currentContext, 'Something went wrong :(');
      }
      _loading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'registration',
      banner: false,
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
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              // autofocus: true,
                              decoration: InputDecoration(labelText: 'Email'),
                              controller: _emailCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your email.";
                                }
                              },
                            ),
                            TextFormField(
                              obscureText: true,
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                              controller: _pwdCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your password.";
                                }
                              },
                            ),
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: 'Repeate Password'),
                              controller: _pwd2Ctrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your password.";
                                }
                                if (value != _pwdCtrl.text) {
                                  return 'Passwords do not match.';
                                }
                              },
                            ),
                          ],
                        )),
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: _isLoading ? null : _handleCreateAccount,
                    child: Text('Create Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
