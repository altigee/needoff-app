import 'package:needoff/api/gql.dart' as gql;

addSickLeave(DateTime startDate, DateTime endDate) async {
  String type = 'LEAVE_SICK_LEAVE';
  var res = await gql.rawMutation('''
    mutation CreateLeave {
      createDayOff(leaveType: "$type", startDate: "${startDate}", endDate: "${endDate}") {
        dayOff {
          id,
          userId,
          leaveType
        }
        ok
      }
    }
  ''');
}

fetchLeaves() async {
  var res = await gql.rawQuery('''
    query FetchLeaves {
      myLeaves {
        id,
        leaveType,
        startDate,
        endDate,
        user
      }
    }
  ''');
}