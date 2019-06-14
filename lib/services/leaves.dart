import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/api/gql.dart' as gql;
import 'package:needoff/models/leave.dart';
import 'package:needoff/utils/dates.dart';

Future<QueryResult> create(int workspaceId, Leave leave) async {
  QueryResult res = await gql.rawMutation('''
mutation CreateLeave {
  createDayOff(
    type: "${leave.type}",
    startDate: "${formatForGQL(leave.startDate)}",
    endDate: "${formatForGQL(leave.endDate)}",
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

Future<QueryResult> fetch(int workspaceId) async {
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

Future<QueryResult> fetchMyBalance(int workspaceId) async {
  QueryResult res = await gql.rawQuery('''
query MyBalance {
  balance: myBalance(workspaceId: $workspaceId) {
    leftPaidLeaves,
    leftUnpaidLeaves,
    leftSickLeaves,
    totalPaidLeaves,
    totalUnpaidLeaves,
    totalSickLeaves,
  }
}
  ''');

  return res;
}

Future<QueryResult> fetchTeamLeaves(int workspaceId) async {
  QueryResult res = await gql.rawQuery('''
query TeamCalendar {
  leaves: teamCalendar(workspaceId: $workspaceId) {
    id,
    leaveType,
    userId,
    startDate,
    endDate,
    comment,
    user {
      firstName,
      lastName,
      email,
    }
  }
}
  ''');

  return res;
}

Future<QueryResult> fetchLeavesForApproval(int workspaceId) async {
  QueryResult res = await gql.rawQuery('''
query LeavesForApproval {
  dayOffsForApproval(workspaceId: $workspaceId) {
    id,
    leaveType,
    startDate,
    endDate,
    comment,
    user {
      firstName,
      lastName,
      email
    }
  }
}
  ''');

  return res;
}

Future<QueryResult> approve(int leaveId) async {
  QueryResult res = await gql.rawMutation('''
mutation CreateLeave {
  approveDayOff(dayOffId: $leaveId) {
    ok
  }
}
  ''');
  return res;
}