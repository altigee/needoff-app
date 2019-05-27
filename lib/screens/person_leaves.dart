import 'package:flutter/material.dart';

class PersonLeaves extends StatefulWidget {
  @override
  _PersonLeavesState createState() => _PersonLeavesState();
}

class _PersonLeavesState extends State<PersonLeaves> {
  String _userName = '';

  @override
  Widget build(BuildContext context) {
    // print(_leaves);

    Map _args = ModalRoute.of(context).settings.arguments;
    String _userName = Map.from(_args)['user']['name'];

    return Scaffold(
      appBar: AppBar(
        title: Text('$_userName'),
      ),
      body: Container(
        child: _buildLeaves(),
      ),
    );
  }

  Widget _buildLeaves() {
    return Container(
      child: Text('$_userName'),
    );
  }
}
