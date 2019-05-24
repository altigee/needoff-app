import 'package:needoff/api/gql.dart' as gql;
import 'package:needoff/api/storage.dart' as storage;

addSickLeave(DateTime startDate, DateTime endDate, String comment) async {
  String type = 'LEAVE_SICK_LEAVE';
  int wsId = await storage.getWorkspace();
  var res = await gql.rawMutation('''
    mutation CreateLeave {
      createDayOff(leaveType: "$type", startDate: "$startDate", endDate: "$endDate", workspaceId: $wsId, comment: "$comment") {
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
