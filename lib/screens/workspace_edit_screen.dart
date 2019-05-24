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
  List members = [];
  appState.AppStateModel _state;
  bool _isLoading = false;
  bool _autovalidate = false;
  final _formKey = GlobalKey<FormState>();
  final _memberFormKey = GlobalKey<FormState>();
  TextEditingController _nameInpCtrl = TextEditingController();
  TextEditingController _descInpCtrl = TextEditingController();
  TextEditingController _memberInpCtrl = TextEditingController();

  _loading(bool val) {
    setState(() {
      _isLoading = val;
    });
  }

  _handleAddMember() {
    if(_memberFormKey.currentState.validate()) {
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
      _loading(true);
      try {
        await wsService.createWorkspace(_nameInpCtrl.text, _descInpCtrl.text, members);
        if (_state != null) {
          await _state.fetchProfile();
        }
        Navigator.of(context).pop();
      } catch (e) {
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
                      height: 40,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'Members:',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Form(
                            key: _memberFormKey,
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _memberInpCtrl,
                              validator: (value) {
                                bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                                if (emailValid == false) {
                                  return 'Enter valid email';
                                }
                              },
                              decoration: InputDecoration(
                                  hintText: "enter person's email"),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _handleAddMember,
                        ),
                      ],
                    ),
                    Container(
                      height: 280,
                      padding: EdgeInsets.only(top:16, bottom: 16),
                      child: _buildMembersList(),
                    ),
                  ],
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
        ),
      ),
    );
  }
}
