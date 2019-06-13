import 'package:flutter/material.dart';
import 'package:needoff/app_state.dart';
import 'package:needoff/models/workspace.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/widget_mixins.dart';
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/utils/ui.dart';
import 'package:needoff/parts/workspace_profile.dart';

class WorkspaceProfileScreen extends StatefulWidget {
  @override
  _WorkspaceProfileScreenState createState() => _WorkspaceProfileScreenState();
}

class _WorkspaceProfileScreenState extends State<WorkspaceProfileScreen>
    with SingleTickerProviderStateMixin, LoadingState {
  GlobalKey _scaffKey = GlobalKey<ScaffoldState>();
  TabController _tabCtrl;
  int _wsId;
  Workspace _workspace;
  bool _isOwner = false;
  @override
  void initState() {
    super.initState();
    setStateFn = setState;
    _tabCtrl = TabController(vsync: this, length: 3, initialIndex: 0);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map args = ModalRoute.of(context).settings.arguments;
      if (args != null && (_wsId = Map.from(args)['id']) != null) {
        loadWorkspace().whenComplete(() {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future loadWorkspace() {
    return workspaceServ.fetchWorkspace(_wsId).then((res) {
      if (res.hasErrors || res.data == null) {
        snack(_scaffKey.currentState, 'Failed to load workspace data.');
      } else {
        print(res.data);
        Map wsData = res.data;
        _workspace = Workspace.fromJson(wsData['info'],
            invitations: wsData['invitations'],
            workspaceDates: wsData['dates'],
            ownerData: wsData['owner']);
        _isOwner = _workspace.owner?.id == appState.profile.id;
        if (mounted) setState(() {});
      }
    });
  }

  updateWorkspace({
    int id,
    String name,
    String description,
    Policy policy,
  }) async {
    try {
      loading = true;
      var res = await workspaceServ.update(id, name, description);
      if (res.hasErrors) {
        snack(_scaffKey.currentState, 'Failed to update workspace');
      } else {
        snack(_scaffKey.currentState, 'Workspace info updated.',
            duration: Duration(milliseconds: 300));
      }
      res = await workspaceServ.setPolicy(
          id, policy.paidDays, policy.unpaidDays, policy.sickDays);
      if (res.hasErrors) {
        snack(_scaffKey.currentState, 'Failed to update policy');
      } else {
        snack(_scaffKey.currentState, 'Policy pdated.',
            duration: Duration(milliseconds: 300));
      }
      await loadWorkspace();
      await appState.fetchWorkspaces();
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    } finally {
      loading = false;
    }
  }

  removeInvitation({String email, int workspaceId}) async {
    try {
      var res = await workspaceServ.removeMember(email, workspaceId);
      if (res.hasErrors) {
        snack(_scaffKey.currentState, 'Failed to remove invitation.');
      }
      await loadWorkspace();
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    }
  }

  removeWorkspaceDate(int id) async {
    try {
      var res = await workspaceServ.removeWorkspaceDate(id);
      if (res.hasErrors) {
        snack(_scaffKey, 'Failed to remove date from calendar.');
      } else {
        loadWorkspace();
      }
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    }
  }

  _buildFAB() {
    Widget fab;
    switch (_tabCtrl.index) {
      case 1:
        if (_isOwner) {
          fab = FloatingActionButton(
            backgroundColor: Theme.of(context).accentColor,
            onPressed: () {
              _handleAddMember(context);
            },
            child: Icon(Icons.add),
          );
        }
        break;
      case 2:
        if (_isOwner) {
          fab = FloatingActionButton(
            backgroundColor: Theme.of(context).accentColor,
            onPressed: () {
              _handleAddWorkspaceDate(context);
            },
            child: Icon(Icons.add),
          );
        }
        break;
      default:
    }
    return fab;
  }

  _handleAddMember(BuildContext ctx) async {
    print('OPEN ADD MEMBER DIALOG');
    Map memberData = await openAddMemberDialog(ctx);
    if (memberData != null) {
      try {
        var res = await workspaceServ.addMember(
            memberData['email'], memberData['startDate'], _workspace.id);
        if (res.hasErrors || res.data == null) {
          snack(_scaffKey.currentState, 'Failed to invite new member.');
        }
        await loadWorkspace();
      } catch (e) {
        snack(_scaffKey.currentState, 'Something went wrong :(');
      }
    }
  }

  _handleAddWorkspaceDate(BuildContext ctx) async {
    Map data = await openAddWorkspaceDateDialog(ctx);
    if (data != null) {
      try {
        var res = await workspaceServ.addWorkspaceDate(_workspace.id,
            data['date'], data['name'], data['isOfficialHoliday']);
        if (res.hasErrors) {
          snack(_scaffKey.currentState, 'Failed to add date.');
        }
        await loadWorkspace();
      } catch (e) {
        snack(_scaffKey.currentState, 'Something went wrong :(');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var tabs = <Widget>[
      Tab(
        icon: Icon(Icons.info),
      ),
      Tab(
        icon: Icon(Icons.people),
      ),
      Tab(
        icon: Icon(Icons.date_range),
      ),
    ];
    return AppScaffold(
      'workspace',
      key: _scaffKey,
      tabBar: TabBar(
        tabs: tabs,
        indicatorColor: Colors.white,
        controller: _tabCtrl,
      ),
      body: _workspace != null
          ? TabBarView(
              controller: _tabCtrl,
              children: <Widget>[
                WorkspaceInfoView(
                  _workspace,
                  handleUpdateCallback: _isOwner ? updateWorkspace : null,
                  editable: _isOwner,
                  loading: loading,
                ),
                WorkspaceInvitationsView(_workspace,
                    removeCallback: _isOwner ? removeInvitation : null,
                    editable: _isOwner),
                WorkspaceDatesListView(_workspace,
                    removeCallback: _isOwner ? removeWorkspaceDate : null,
                    editable: _isOwner),
              ],
            )
          : Center(
              child: Text('No data.'),
            ),
      floatingActionButton: _buildFAB(),
    );
  }
}
