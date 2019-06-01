import 'package:flutter/material.dart';
import 'package:needoff/models/workspace.dart'
    show
        Workspace,
        WorkspaceInvitation,
        WorkspaceUpdateCallback,
        WorkspaceInvitationAddCallback,
        WorkspaceInvitationRemoveCallback;

class WorkspaceInfoView extends StatefulWidget {
  final Workspace workspace;
  final WorkspaceUpdateCallback handleUpdateCallback;
  final editable;
  WorkspaceInfoView(this.workspace,
      {this.handleUpdateCallback, this.editable: false});
  @override
  _WorkspaceInfoViewState createState() => _WorkspaceInfoViewState();
}

class _WorkspaceInfoViewState extends State<WorkspaceInfoView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _descrCtrl = TextEditingController();

  void _handleUpdate() {
    if (widget.handleUpdateCallback != null &&
        _formKey.currentState.validate()) {
      widget.handleUpdateCallback(
        id: widget.workspace.id,
        name: _nameCtrl.text,
        description: _descrCtrl.text,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.workspace?.name;
    _descrCtrl.text = widget.workspace?.description;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: <Widget>[
          if (widget.editable)
            Form(
              key: _formKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameCtrl,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter the name of the workspace.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  TextFormField(
                    controller: _descrCtrl,
                    maxLines: 2,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter short description of the workspace.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                ],
              ),
            ),
          if (!widget.editable) ...[
            InfoRow(title: 'Name', value: widget.workspace?.name),
            InfoRow(title: 'Description', value: widget.workspace?.description),
          ],
          SizedBox(
            height: 32,
          ),
          InfoRow(title: 'Owner', value: widget.workspace?.owner?.name),
          if (widget.editable)
            RaisedButton(
              child: Text('Update'),
              onPressed: _handleUpdate,
            )
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const InfoRow({Key key, @required this.title, @required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.caption,
              ),
              Text(
                value,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class WorkspaceInvitationsView extends StatefulWidget {
  final Workspace workspace;
  final WorkspaceInvitationAddCallback addCallback;
  final WorkspaceInvitationRemoveCallback removeCallback;
  WorkspaceInvitationsView(this.workspace,
      {this.addCallback, this.removeCallback});
  // : this.addCallback = addCallback,
  // this.removeCallback = removeCallback;
  @override
  _WorkspaceInvitationsViewState createState() =>
      _WorkspaceInvitationsViewState();
}

class _WorkspaceInvitationsViewState extends State<WorkspaceInvitationsView> {
  List<Widget> _buildList() {
    List<WorkspaceInvitation> data = widget.workspace?.invitations ?? [];
    return data.map((invite) {
      return ListTile(
        title: Text(invite.email),
        subtitle: Text(invite.status),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: _buildList(),
      ),
    );
  }
}
