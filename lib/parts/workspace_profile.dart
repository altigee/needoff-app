import 'package:flutter/material.dart';
import 'package:needoff/models/workspace.dart'
    show
        Workspace,
        WorkspaceInvitation,
        WorkspaceUpdateCallback,
        WorkspaceInvitationAddCallback,
        WorkspaceInvitationRemoveCallback,
        WorkspaceCalendarAddCallback,
        WorkspaceCalendarRemoveCallback;
import 'package:needoff/parts/info_row.dart';
import 'package:needoff/utils/dates.dart';
import 'package:needoff/utils/ui.dart';
import 'package:needoff/utils/validation.dart';

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


class WorkspaceInvitationsView extends StatefulWidget {
  final Workspace workspace;
  final WorkspaceInvitationRemoveCallback removeCallback;
  WorkspaceInvitationsView(this.workspace, {this.removeCallback});
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
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            var res = await openConfirmation(context, title: 'Are you sure?');
            if (res['ok'] && widget.removeCallback is Function) {
              widget.removeCallback(
                  email: invite.email, workspaceId: widget.workspace.id);
            }
          },
        ),
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

class WorkspaceCalendarsListView extends StatefulWidget {
  final Workspace workspace;
  final WorkspaceCalendarAddCallback addCallback;
  final WorkspaceCalendarRemoveCallback removeCallback;
  WorkspaceCalendarsListView(this.workspace,
      {this.addCallback, this.removeCallback});
  @override
  _WorkspaceCalendarsListViewState createState() =>
      _WorkspaceCalendarsListViewState();
}

class _WorkspaceCalendarsListViewState
    extends State<WorkspaceCalendarsListView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

Future openAddMemberDialog(BuildContext context) {
  var formKey = GlobalKey<FormState>();
  TextEditingController _startInpCtrl =
      TextEditingController(text: formatDate(DateTime.now()));
  TextEditingController _emailInpCtrl = TextEditingController();
  FocusNode fn = FocusNode();
  Widget form = Form(
    key: formKey,
    child: Column(
      children: <Widget>[
        TextFormField(
          controller: _emailInpCtrl,
          validator: (value) {
            if (value.isEmpty || !isValidEmail(value)) {
              return 'Please enter a valid email';
            }
          },
          decoration: InputDecoration(
            labelText: 'Email:',
          ),
        ),
        TextField(
          onTap: () async {
            fn.unfocus();
            var res = await openDatePicker(context);
            if (res != null) {
              _startInpCtrl.text = formatDate(res);
            }
          },
          controller: _startInpCtrl,
          focusNode: fn,
          enableInteractiveSelection: false,
          decoration: InputDecoration(labelText: 'First day:'),
        ),
      ],
    ),
  );

  return openEditFormDialog(
    context,
    form: form,
    dialogTitle: 'Invite a person',
    onCancel: () {
      Navigator.pop(context);
    },
    onOk: () {
      if ((form.key as GlobalKey<FormState>).currentState.validate()) {
        Navigator.pop(context, {
          'email': _emailInpCtrl.text,
          'startDate': parseFormatted(_startInpCtrl.text),
        });
      }
    },
  );
}
