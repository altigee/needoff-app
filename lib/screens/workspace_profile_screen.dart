import 'package:flutter/material.dart';
import 'package:needoff/app_state.dart';
import 'package:needoff/models/workspace.dart' show Workspace;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/utils/ui.dart';
import 'package:needoff/parts/workspace_profile.dart'
    show WorkspaceInfoView, WorkspaceInvitationsView;

class WorkspaceProfileScreen extends StatefulWidget {
  @override
  _WorkspaceProfileScreenState createState() => _WorkspaceProfileScreenState();
}

class _WorkspaceProfileScreenState extends State<WorkspaceProfileScreen> {
  GlobalKey _scaffKey = GlobalKey<ScaffoldState>();
  Map _wsData;
  Workspace _workspace;
  bool _isOwner = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map args = ModalRoute.of(context).settings.arguments;
      int id;
      if (args != null && (id = Map.from(args)['id']) != null) {
        workspaceServ.fetchWorkspace(id).then((res) {
          if (res.hasErrors || res.data == null) {
            snack(_scaffKey.currentState, 'Failed to load workspace data.');
          } else {
            print(res.data);
            _wsData = res.data;
            _workspace = Workspace.fromJson(
                _wsData['info'], _wsData['invitations'], _wsData['owner']);
            _isOwner = _workspace.owner?.id == appState.profile.id;
            setState(() {});
          }
        }).whenComplete(() {
          setState(() {});
        });
      }
    });
  }

  updateWorkspace({
    id,
    name,
    description,
  }) {}

  addInvitation({String email, int workspaceId}) {}

  removeInvitation({int invitationId, int workspaceId}) {}

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'workspace',
      key: _scaffKey,
      body: _workspace != null
          ? TabBarView(
              children: <Widget>[
                WorkspaceInfoView(_workspace,
                    handleUpdateCallback: _isOwner ? updateWorkspace : null,
                    editable: _isOwner),
                WorkspaceInvitationsView(_workspace,
                    addCallback: addInvitation,
                    removeCallback: removeInvitation),
                Center(
                  child: Text('workspace holidays.'),
                ),
              ],
            )
          : Center(
              child: Text('No data.'),
            ),
      tabs: <Widget>[
        Tab(
          icon: Icon(Icons.info),
        ),
        Tab(
          icon: Icon(Icons.people),
        ),
        Tab(
          icon: Icon(Icons.date_range),
        ),
      ],
    );
  }
}
