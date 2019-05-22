import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/services/workspace.dart' as wsService;
import 'package:needoff/app_state.dart' as appState;

class WorkspaceEditScreen extends StatefulWidget {
  @override
  _WorkspaceEditScreenState createState() => _WorkspaceEditScreenState();
}

class _WorkspaceEditScreenState extends State<WorkspaceEditScreen> {
  var id;
  appState.AppStateModel _state;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameInpCtrl = TextEditingController();
  TextEditingController _descInpCtrl = TextEditingController();

  _loading(bool val) {
    setState(() {
      _isLoading = val;
    });
  }

  _handleCreateWorkspace() async {
    if (_formKey.currentState.validate()) {
      _loading(true);
      try {
        await wsService.createWorkspace(_nameInpCtrl.text, _descInpCtrl.text);
        if (_state != null) {
          await _state.fetchProfile();
        }
        Navigator.of(context).pop();
      } catch(e) {
        print('![ERROR] Fail create ws');
      }
      _loading(false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = ScopedModel.of<appState.AppStateModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      id == null ? 'New Workspace' : 'Edit Workspace',
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameInpCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a name';
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  TextFormField(
                    controller: _descInpCtrl,
                    maxLines: 2,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a short description';
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                  )
                ],
              ),
            ),
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: _isLoading ? null : _handleCreateWorkspace,
            child: Text('Create Workspace'),
          ),
        ],
      ),
    );
  }
}
