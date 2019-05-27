import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/api/gql.dart' as gql;
import 'package:needoff/models/leave.dart';

create(int workspaceId, Leave leave) async {
  QueryResult res = await gql.rawMutation('''
mutation CreateLeave {
  createDayOff(
    type: "${leave.type}",
    startDate: "${leave.startDate}",
    endDate: "${leave.endDate}",
    comment: "${leave.comment}",
    workspaceId: $workspaceId
    ) {
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

fetch(int workspaceId) async {
  QueryResult res = await gql.rawQuery('''
query FetchLeaves {
  leaves: myLeaves(workspaceId: $workspaceId) {
    id,
    leaveType,
    startDate,
    endDate,
    comment,
  }
}
  ''');
  return res;
}
