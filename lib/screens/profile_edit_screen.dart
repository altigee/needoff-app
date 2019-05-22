import 'package:flutter/material.dart';
import 'package:needoff/parts/app_scaffold.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'edit profile',
      body: Container(
        child: Text('Edit'),
      ),
    );
  }
}