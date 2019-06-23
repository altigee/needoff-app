import 'package:flutter/material.dart';
import 'package:needoff/models/workspace.dart';

import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/utils/ui.dart';
import 'package:needoff/parts/widget_mixins.dart' show LoadingState;
import 'package:needoff/utils/validation.dart';

class WorkspaceCreateScreen extends StatefulWidget {
  @override
  _WorkspaceCreateScreenState createState() => _WorkspaceCreateScreenState();
}

class _WorkspaceCreateScreenState extends State<WorkspaceCreateScreen>
    with LoadingState {
  var id;
  List members = [];

  bool _autovalidate = false;
  final _formKey = GlobalKey<FormState>();
  final _memberFormKey = GlobalKey<FormState>();
  TextEditingController _nameInpCtrl = TextEditingController();
  TextEditingController _descInpCtrl = TextEditingController();
  TextEditingController _memberInpCtrl = TextEditingController();

  _handleAddMember() {
    if (_memberFormKey.currentState.validate()) {
      setState(() {
        members.insert(0, _memberInpCtrl.text);
        _memberInpCtrl.text = '';
        print(members.length);
      });
    }
  }

  _handleRemoveMember(int i) {
    setState(() {
      members.removeAt(i);
    });
  }

  _buildMembersList() {
    if (members.length > 0) {
      return ListView.builder(
        itemCount: members.length,
        itemBuilder: (BuildContext ctx, int i) {
          return ListTile(
            key: UniqueKey(),
            title: Text(members[i]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _handleRemoveMember(i);
              },
            ),
          );
        },
      );
    }
    return Container();
  }

  _handleCreateWorkspace() async {
    setState(() {
      _autovalidate = true;
    });
    if (_formKey.currentState.validate()) {
      loading = true;
      try {
        var res = await appState.addWorkspace(Workspace(_nameInpCtrl.text,
            description: _descInpCtrl.text, members: members));
        int id = int.tryParse(res.data['createWorkspace']['ws']['id']);
        Navigator.of(context)
            .popAndPushNamed('/workspace-profile', arguments: {'id': id});
      } on AppStateException catch (e) {
        snack(_formKey.currentContext, e.message);
      } catch (e) {
        snack(_formKey.currentContext, 'Something went wrong :(');
      }
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      id == null ? 'New Workspace' : 'Edit Workspace',
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Form(
                autovalidate: _autovalidate,
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
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
                    ),
                    SizedBox(
                      height: 48,
                    )
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: loading ? null : _handleCreateWorkspace,
                  child: Text('Create Workspace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
