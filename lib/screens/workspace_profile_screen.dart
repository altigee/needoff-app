import 'package:flutter/material.dart';
import 'package:needoff/app_state.dart';
import 'package:needoff/models/workspace.dart' show Workspace;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/workspace_profile.dart';
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/utils/ui.dart';
import 'package:needoff/parts/workspace_profile.dart'
    show WorkspaceInfoView, WorkspaceInvitationsView, openAddMemberDialog, openAddCalendarDialog;

class WorkspaceProfileScreen extends StatefulWidget {
  @override
  _WorkspaceProfileScreenState createState() => _WorkspaceProfileScreenState();
}

class _WorkspaceProfileScreenState extends State<WorkspaceProfileScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey _scaffKey = GlobalKey<ScaffoldState>();
  TabController _tabCtrl;
  int _wsId;
  Workspace _workspace;
  bool _isOwner = false;
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(vsync: this, length: 3, initialIndex: 0);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map args = ModalRoute.of(context).settings.arguments;
      if (args != null && (_wsId = Map.from(args)['id']) != null) {
        loadWorkspace().whenComplete(() {
          if(mounted) setState(() {});
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
            calendars: wsData['calendars'],
            ownerData: wsData['owner']);
        _isOwner = _workspace.owner?.id == appState.profile.id;
        if (mounted) setState(() {});
      }
    });
  }

  updateWorkspace({
    id,
    name,
    description,
  }) {}

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

  removeCalendar(int calendarId) async {
    try {
      var res = await workspaceServ.removeCalendar(calendarId);
      if (res.hasErrors) {
        snack(_scaffKey.currentState, 'Failed to remove calendar.');
      }
      await loadWorkspace();
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
              _handleAddCalendar(context);
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

  _handleAddCalendar(BuildContext ctx) async {
    Map calendarData = await openAddCalendarDialog(ctx);
    if (calendarData != null) {
      try {
        var res = await workspaceServ.createCalendar(
            calendarData['name'], _workspace.id);
        if (res.hasErrors || res.data == null) {
          snack(_scaffKey.currentState, 'Failed to create calendar.');
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
                WorkspaceInfoView(_workspace,
                    handleUpdateCallback: _isOwner ? updateWorkspace : null,
                    editable: _isOwner),
                WorkspaceInvitationsView(_workspace,
                    removeCallback: _isOwner ? removeInvitation : null,
                    editable: _isOwner),
                WorkspaceCalendarsListView(_workspace,
                    removeCallback: _isOwner ? removeCalendar : null,
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
