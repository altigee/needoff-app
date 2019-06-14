import 'package:flutter/material.dart';
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/app_state.dart';
import 'package:needoff/models/leave.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/widget_mixins.dart';
import 'package:needoff/services/leaves.dart' as leavesServ;
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/utils/dates.dart';
import 'package:needoff/utils/ui.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with LoadingState, ScaffoldKey {
  int _wsId;
  List<Leave> _leaves;
  List<Leave> get leaves => _leaves ?? [];
  Future<bool> _isOwner() async {
    var ownerRes = await workspaceServ.fetchOwner(_wsId);
    int ownerId;
    if (ownerRes.hasErrors ||
        ownerRes.data == null ||
        ownerRes.data['owner'] == null ||
        (ownerId = int.tryParse(ownerRes.data['owner']['userId'])) == null)
      return false;

    return ownerId == appState.profile.id;
  }

  void loadLeavesForApproval() async {
    _wsId = await storage.getWorkspace();
    if (_wsId == null) return;
    try {
      if (await _isOwner()) {
        loading = true;
        var res = await leavesServ.fetchLeavesForApproval(_wsId);
        if (res.hasErrors || res.data == null) {
          snack(scaffKey, 'Failed to load leaves for approval');
        } else {
          _leaves = List.castFrom<dynamic, Leave>(res.data['dayOffsForApproval']
              .map((item) => Leave.fromJson(item))
              .toList());
          print(leaves);
        }
      }
    } catch (e) {
      snack(scaffKey, 'Something went wrong :(');
    } finally {
      loading = false;
    }
  }

  _buildLeavesList() {
    return ListView(
      children: ListTile.divideTiles(
        context: context,
        tiles: leaves.map((leave) {
          Map user = leave.userData;
          var type = leave.type;

          String userDisplay = '${user['firstName']} ${user['lastName']}';
          if (userDisplay.isEmpty) {
            userDisplay = user['email'];
          }

          String _userInits = user["name"] ?? user['email'][0];

          Widget _userAvatar = CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Text(
              '$_userInits',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );

          String typeLabel = LeaveTypeLabels[type];
          var start = leave.startDate;
          var end = leave.endDate;
          String daysLabel = start != end
              ? '${formatDate(start)} - ${formatDate(end)}'
              : '${formatDate(start)} (1 day)';
          return ListTile(
            leading: _userAvatar,
            title: Text(userDisplay),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$typeLabel',
                  style: TextStyle(color: LeaveTypeColors[type]),
                ),
                Text(
                  daysLabel,
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(leave.comment),
              ],
            ),
            isThreeLine: true,
            trailing: FlatButton(
              child: Text(
                'Approve',
                style: TextStyle(inherit: true, color: Colors.green),
              ),
              onPressed: () {
                _handleApprove(leave);
              },
            ),
          );
        }),
      ).toList(),
    );
  }

  void _handleApprove(Leave leave) async {
    try {
      var res = await leavesServ.approve(leave.id);
      if (res.hasErrors) {
        snack(scaffKey, 'Failed to approve leave request.');
      } else {
        snack(scaffKey, 'Approved.');
        loadLeavesForApproval();
      }
    } catch (e) {
      snack(scaffKey, 'Something went wrong.');
    } finally {}
  }

  @override
  void initState() {
    super.initState();
    setStateFn = setState;
    loadLeavesForApproval();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'Todo',
      key: scaffKey,
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: leaves.length > 0
                  ? _buildLeavesList()
                  : Center(
                      child: Text('No items.'),
                    ),
            ),
    );
  }
}
