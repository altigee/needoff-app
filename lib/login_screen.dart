import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:needoff/config.dart' show cfg;

import 'app_state.dart' as appState;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var _state;

  TextEditingController _loginCtrl = TextEditingController(text: 'nmarchuk');
  TextEditingController _pwdCtrl = TextEditingController(text: 'nm1234');

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

  Future _handleLogin() async {
    if (_formKey.currentState.validate()) {
      _loading(true);
      _state.profile = await appState.auth.signIn(_loginCtrl.text, _pwdCtrl.text);
      if (_state.profile == null) {
        _snack('Failed to load user :(');
      }
      _loading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login(${cfg.env})', style: TextStyle(fontFamily: 'Orbitron')),
      ),
      body: Container(
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
                            controller: _loginCtrl,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter your email.";
                              }
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'Password'),
                            controller: _pwdCtrl,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter your password.";
                              }
                            },
                          ),
                        ],
                      )),
                ),
                RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: _isLoading ? null : _handleLogin,
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
