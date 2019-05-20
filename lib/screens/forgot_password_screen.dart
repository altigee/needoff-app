import 'package:flutter/material.dart';


class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reset password', style: TextStyle(fontFamily: 'Orbitron')),
      ),
      body: Container(
        child: Center(child: Text('Ooops :(')),
      ),
    );
  }
}
