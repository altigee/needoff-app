import 'package:flutter/material.dart';

import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/models/credentials.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/widget_mixins.dart';
import 'package:needoff/utils/ui.dart';
import 'package:needoff/utils/validation.dart' show isValidEmail;

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with LoadingState {
  final _formKey = GlobalKey<FormState>();

  bool _autovalidate = false;

  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _firstNameCtrl = TextEditingController();
  TextEditingController _lastNameCtrl = TextEditingController();
  TextEditingController _pwdCtrl = TextEditingController();
  TextEditingController _pwd2Ctrl = TextEditingController();

  Future _handleCreateAccount() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });
      try {
        await appState.signup(Credentials(_emailCtrl.text, _pwdCtrl.text),
            userData: {
              'firstName': _firstNameCtrl.text,
              'lastName': _lastNameCtrl.text
            });
        Navigator.of(context).pop();
      } on AppStateException catch (e) {
        snack(_formKey.currentContext, e.message);
      } catch (e) {
        snack(_formKey.currentContext, 'Something went wrong :(');
      }
      setState(() {
        loading = false;
      });
    } else {
      _autovalidate = true;
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
                        autovalidate: _autovalidate,
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              // autofocus: true,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(labelText: 'Email'),
                              controller: _emailCtrl,
                              validator: (value) {
                                if (value.isEmpty || !isValidEmail(value)) {
                                  return "Please enter valid email.";
                                }
                              },
                            ),
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
                            SizedBox(height: 48,),
                            SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                onPressed:
                                    loading ? null : _handleCreateAccount,
                                child: Text('Create Account'),
                              ),
                            ),
                          ],
                        )),
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
