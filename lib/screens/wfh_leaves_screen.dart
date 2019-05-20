import 'package:flutter/material.dart';

class WfhLeavesScreen extends StatefulWidget {
  @override
  _WfhLeavesScreenState createState() => _WfhLeavesScreenState();
}

class _WfhLeavesScreenState extends State<WfhLeavesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('work from *', style: TextStyle(fontFamily: 'Orbitron')),
      ),
      body: Container(
        child: Text('Wfh leaves screen'),
      ),
    );
  }
}