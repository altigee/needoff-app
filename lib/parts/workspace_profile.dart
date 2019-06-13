import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:needoff/models/workspace.dart'
    show
        Workspace,
        WorkspaceInvitation,
        WorkspaceUpdateCallback,
        WorkspaceInvitationRemoveCallback,
        WorkspaceDate,
        WorkspaceDateRemoveCallback,
        Policy;
import 'package:needoff/parts/info_row.dart';
import 'package:needoff/utils/dates.dart';
import 'package:needoff/utils/ui.dart';
import 'package:needoff/utils/validation.dart';

class WorkspaceInfoView extends StatefulWidget {
  final Workspace workspace;
  final WorkspaceUpdateCallback handleUpdateCallback;
  final editable;
  final loading;
  WorkspaceInfoView(this.workspace,
      {this.handleUpdateCallback, this.editable = false, this.loading = false});
  @override
  _WorkspaceInfoViewState createState() => _WorkspaceInfoViewState();
}

class _WorkspaceInfoViewState extends State<WorkspaceInfoView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _descrCtrl = TextEditingController();
  TextEditingController _paidCtrl = TextEditingController(text: '0');
  TextEditingController _unpaidCtrl = TextEditingController(text: '0');
  TextEditingController _sickCtrl = TextEditingController(text: '0');

  void _handleUpdate() {
    if (widget.handleUpdateCallback != null &&
        _formKey.currentState.validate()) {
      widget.handleUpdateCallback(
          id: widget.workspace.id,
          name: _nameCtrl.text,
          description: _descrCtrl.text,
          policy: Policy(
            int.parse(_paidCtrl.text),
            int.parse(_unpaidCtrl.text),
            int.parse(_sickCtrl.text),
          ));
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
      child: SingleChildScrollView(
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
                    SizedBox(
                      height: 32,
                    ),
                    TextFormField(
                      controller: _paidCtrl,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty || int.tryParse(value) == null) {
                          return 'Enter number of days';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Paid vacation days per year',
                      ),
                    ),
                    TextFormField(
                      controller: _unpaidCtrl,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty || int.tryParse(value) == null) {
                          return 'Enter number of days';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Unpaid vacation days per year',
                      ),
                    ),
                    TextFormField(
                      controller: _sickCtrl,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty || int.tryParse(value) == null) {
                          return 'Enter number of days';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Sick leaves per year',
                      ),
                    ),
                  ],
                ),
              ),
            if (!widget.editable) ...[
              InfoRow(title: 'Name', value: widget.workspace?.name),
              InfoRow(
                  title: 'Description', value: widget.workspace?.description),
            ],
            SizedBox(
              height: 32,
            ),
            InfoRow(title: 'Owner', value: widget.workspace?.owner?.name),
            SizedBox(
              height: 64,
            ),
            if (widget.editable)
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  child: Text('Update'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: widget.loading ? null : _handleUpdate,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WorkspaceInvitationsView extends StatefulWidget {
  final Workspace workspace;
  final bool editable;
  final WorkspaceInvitationRemoveCallback removeCallback;
  WorkspaceInvitationsView(this.workspace,
      {this.removeCallback, this.editable = false});

  @override
  _WorkspaceInvitationsViewState createState() =>
      _WorkspaceInvitationsViewState();
}

class _WorkspaceInvitationsViewState extends State<WorkspaceInvitationsView> {
  List<Widget> _buildList(List data) {
    return data.map((invite) {
      return ListTile(
        title: Text(invite.email),
        subtitle: Text(invite.status),
        onTap: () {
          print('tap tap tap');
        },
        trailing: widget.editable
            ? IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  var res = await openConfirmation(context,
                      title: 'Are you sure?', okLabel: 'remove');
                  if (res != null &&
                      res['ok'] &&
                      widget.removeCallback is Function) {
                    widget.removeCallback(
                        email: invite.email, workspaceId: widget.workspace.id);
                  }
                },
              )
            : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<WorkspaceInvitation> data = widget.workspace?.invitations ?? [];
    return Container(
      child: data.length == 0
          ? Center(
              child: Text('No invitations found.'),
            )
          : ListView(
              children: _buildList(data),
            ),
    );
  }
}

class WorkspaceDatesListView extends StatefulWidget {
  final Workspace workspace;
  final bool editable;
  final WorkspaceDateRemoveCallback removeCallback;
  WorkspaceDatesListView(this.workspace,
      {this.editable = false, this.removeCallback});
  @override
  _WorkspaceDatesListViewState createState() => _WorkspaceDatesListViewState();
}

class _WorkspaceDatesListViewState extends State<WorkspaceDatesListView> {
  List<Widget> _buildList(List data) {
    return data.map((hol) {
      var _dateTxt = Text(formatDate(hol.date));
      var _official = hol.isOfficialHoliday;
      return ListTile(
        title: Text(hol.name),
        subtitle: Text(_official ? 'Public Holiday' : 'Workday'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (widget.editable) _dateTxt,
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                var res = await openConfirmation(context,
                    title: 'Are you sure?', okLabel: 'remove');
                if (res != null &&
                    res['ok'] &&
                    widget.removeCallback is Function) {
                  widget.removeCallback(hol.id);
                }
              },
            )
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<WorkspaceDate> data = widget.workspace?.workspaceDates ?? [];
    return Container(
      child: data.length == 0
          ? Center(
              child: Text('No dates found.'),
            )
          : ListView(
              children: _buildList(data),
            ),
    );
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
          keyboardType: TextInputType.emailAddress,
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
            var res = await openDatePicker(context,
                firstDate: DateTime.now().subtract(Duration(days: 365)));
            if (res != null) {
              _startInpCtrl.text = formatDate(res);
            }
          },
          controller: _startInpCtrl,
          focusNode: fn,
          enableInteractiveSelection: false,
          decoration: InputDecoration(
            labelText: 'First day:',
          ),
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

Future openAddWorkspaceDateDialog(BuildContext context) {
  var formKey = GlobalKey<FormState>();
  var nameCtrl = TextEditingController();
  var dateCtrl = TextEditingController();
  bool _isOfficial = false;
  var fn = FocusNode();
  return openEditFormDialog(context,
      dialogTitle: 'Add date',
      form: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: nameCtrl,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a name';
                }
              },
              decoration: InputDecoration(
                labelText: 'Title:',
              ),
            ),
            FormField(validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date';
              }
            }, builder: (FormFieldState<String> state) {
              return TextField(
                onTap: () async {
                  fn.unfocus();
                  var res = await openDatePicker(context,
                      firstDate: DateTime.now().subtract(Duration(days: 365)));
                  if (res != null) {
                    dateCtrl.text = formatDate(res);
                    state.didChange(formatDate(res));
                  }
                },
                onChanged: state.didChange,
                controller: dateCtrl,
                focusNode: fn,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                    labelText: 'Date:', errorText: state.errorText),
              );
            }),
            SizedBox(
              height: 32,
            ),
            FormField(
              builder: (FormFieldState state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Checkbox(
                      onChanged: (value) {
                        print('changed to $value');
                        _isOfficial = value;
                        state.didChange(value);
                      },
                      value: _isOfficial,
                    ),
                    Text('Official Holiday'),
                  ],
                );
              },
            )
          ],
        ),
      ), onCancel: () {
    Navigator.of(context).pop();
  }, onOk: () {
    if (formKey.currentState.validate()) {
      Navigator.of(context).pop({
        'name': nameCtrl.text,
        'date': parseFormatted(dateCtrl.text),
        'isOfficialHoliday': _isOfficial
      });
    }
  });
}
