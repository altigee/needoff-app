import 'package:needoff/api/gql.dart' as gql;

addSickLeave(DateTime startDate, DateTime endDate) async {
  String type = 'LEAVE_SICK_LEAVE';
  var res = await gql.rawMutation('''
    mutation CreateLeave {
      createDayOff(leaveType: "$type", startDate: "$startDate", endDate: "$endDate", workspaceId: 1) {
        dayOff {
          id,
          userId,
          leaveType
        }
        ok
      }
    }
  ''');
  return res;
}

fetchLeaves(int workspaceId) async {
  var res = await gql.rawQuery('''
    query FetchLeaves {
      leaves: myLeaves(workspaceId: $workspaceId) {
        id,
        leaveType,
        startDate,
        endDate,
        user
      }
    }
  ''');
  return res;
}
