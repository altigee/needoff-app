import 'package:flutter/material.dart';
import 'package:needoff/parts/app_scaffold.dart';

class VacLeavesScreen extends StatefulWidget {
  @override
  _VacLeavesScreenState createState() => _VacLeavesScreenState();
}

class _VacLeavesScreenState extends State<VacLeavesScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'vacations',
      body: Container(
        child: Text('Vac leaves screen'),
      ),
    );
  }
}
