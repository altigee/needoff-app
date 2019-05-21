import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:needoff/app_state.dart' as appState;
import 'package:needoff/parts/app_scaffold.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var _state;

  TextEditingController _emailCtrl = TextEditingController();
  TextEditingController _pwdCtrl = TextEditingController();
  TextEditingController _pwd2Ctrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = ScopedModel.of<appState.AppStateModel>(context);
  }

  void _loading(bool val) {
    setState(() {
      _isLoading = val;
    });
  }

  void _snack(String text) {
    Scaffold.of(_formKey.currentContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future _handleCreateAccount() async {
    if (_formKey.currentState.validate()) {
      try {
        _loading(true);
        _state.profile =
            await appState.auth.signUp(_emailCtrl.text, _pwdCtrl.text);
        if (_state.profile == null) {
          _snack('Failed to load user :(');
        } else {
          Navigator.of(context)
              .popUntil((Route route) => route.settings.name == '/');
        }
      } catch (e) {
        _snack('Registration failed :(');
      }
      _loading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'registration',
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
