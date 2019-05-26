import 'package:flutter/material.dart';

import 'package:needoff/parts/app_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'reset password',
      banner: false,
      body: Container(
        child: Center(child: Text('Ooops :(')),
      ),
    );
  }
}
