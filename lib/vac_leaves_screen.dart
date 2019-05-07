import 'package:flutter/material.dart';

class VacLeavesScreen extends StatefulWidget {
  @override
  _VacLeavesScreenState createState() => _VacLeavesScreenState();
}

class _VacLeavesScreenState extends State<VacLeavesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vacations', style: TextStyle(fontFamily: 'Orbitron')),
      ),
      body: Container(
        child: Text('Vac leaves screen'),
      ),
    );
  }
}