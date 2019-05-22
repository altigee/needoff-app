import 'package:flutter/material.dart';
import 'package:needoff/parts/app_scaffold.dart';

class WfhLeavesScreen extends StatefulWidget {
  @override
  _WfhLeavesScreenState createState() => _WfhLeavesScreenState();
}

class _WfhLeavesScreenState extends State<WfhLeavesScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'work from *',
      body: Container(
        child: Text('Wfh leaves screen'),
      ),
    );
  }
}
