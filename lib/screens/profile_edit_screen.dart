import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit profile', style: TextStyle(fontFamily: 'Orbitron')),
      ),
      body: Container(
        child: Text('Edit'),
      ),
    );
  }
}