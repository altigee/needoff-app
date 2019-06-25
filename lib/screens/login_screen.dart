import 'package:flutter/material.dart';

import 'package:needoff/config.dart' show appConfig;
import 'package:needoff/models/credentials.dart';
import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/utils/ui.dart';
import 'package:needoff/parts/widget_mixins.dart' show LoadingState;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with LoadingState {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailCtrl = TextEditingController(text: '@alt.com');
  TextEditingController _pwdCtrl = TextEditingController(text: 'ssssss');

  Future _handleLogin() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        loading = true;
      });
      try {
        await appState.signin(Credentials(_emailCtrl.text, _pwdCtrl.text));
        Navigator.of(context).pushReplacementNamed('/');
      } on AppStateException catch (e) {
        snack(_formKey.currentContext, e.message);
      } catch (e) {
        snack(_formKey.currentContext, 'Something went wrong :(');
      }
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'login(${appConfig.get('env')})',
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
                              keyboardType: TextInputType.emailAddress,
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
                            SizedBox(
                              height: 48,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                onPressed: loading ? null : _handleLogin,
                                child: Text('Login'),
                              ),
                            ),
                          ],
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // FlatButton(
                        //   child: Text(
                        //     'Forgot Password?',
                        //     style: Theme.of(context)
                        //         .textTheme
                        //         .overline
                        //         .apply(fontFamily: 'Orbitron'),
                        //   ),
                        //   onPressed: () {
                        //     Navigator.of(context).pushNamed('/forgot-pwd');
                        //   },
                        // ),
                        FlatButton(
                          child: Text(
                            'Create Account',
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                .apply(fontFamily: 'Orbitron'),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/registration');
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
