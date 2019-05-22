import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget floatingActionButton;
  AppScaffold(
    this.title,
    {
      Widget body,
      Widget floatingActionButton
    }
  ): this.body = body, this.floatingActionButton = floatingActionButton;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.title, style: TextStyle(fontFamily: 'Orbitron')),
        ),
        body: this.body,
        floatingActionButton: this.floatingActionButton);
  }
}
