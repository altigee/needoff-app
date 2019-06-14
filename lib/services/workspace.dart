import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/api/gql.dart' as gql;
import 'package:needoff/models/workspace.dart';
import 'package:needoff/utils/dates.dart';

Future<QueryResult> create(Workspace ws) async {
  String membersStr = '[${ws.members.map((m) => '"$m"').toList().join(',')}]';
  QueryResult res = await gql.rawMutation('''
mutation CreateWS {
  createWorkspace(name: "${ws.name}", description: "${ws.description}", members: $membersStr) {
    ok,
    ws {
      id,
      name,
      description
    }
  }
}
  ''');

  return res;
}

Future<QueryResult> update(int wsId, String name, String description) async {
  QueryResult res = await gql.rawMutation('''
mutation UpdateWS {
  updateWorkspace(wsId: $wsId, name: "$name", description: "$description") {
    ok,
  }
}
  ''');

  return res;
}

Future<QueryResult> setPolicy(
    int wsId, int maxPaidVacs, int maxUnpaidVacs, int maxSickDays) async {
  QueryResult res = await gql.rawMutation('''
mutation SetPolicy {
  setWorkspacePolicy(maxPaidVacationsPerYear: $maxPaidVacs, maxSickLeavesPerYear: $maxSickDays, maxUnpaidVacationsPerYear: $maxUnpaidVacs, wsId: $wsId) {
    ok,
  }
}
  ''');

  return res;
}

Future<QueryResult> fetch() async {
  QueryResult res = await gql.rawQuery('''
query MyWorkspaces {
  workspaces: myWorkspaces {
    id,
    name,
    description,
  }
}
  ''');
  return res;
}

Future<QueryResult> fetchWorkspace(int id) async {
  QueryResult res = await gql.rawQuery('''
query LoadWorkspace {
  owner: workspaceOwner(workspaceId: $id) {
    firstName,
    lastName,
    email,
    userId,
  }
  info: workspaceById(workspaceId: $id) {
    id,
    name,
    description,
  }
  invitations: workspaceInvitations(workspaceId: $id) {
    id,
    email,
    status
  }
  dates: workspaceDates(workspaceId: $id) {
    id,
    name,
    date,
    isOfficialHoliday
  }
}
  ''');

  return res;
}

Future<QueryResult> fetchOwner(int workspaceId) async {
  QueryResult res = await gql.rawQuery('''
query GetOwner {
  owner: workspaceOwner(workspaceId: $workspaceId) {
    firstName,
    lastName,
    email,
    userId,
  }
}  
  ''');

  return res;
}

Future<QueryResult> addMember(
    String email, DateTime startDate, int workspaceId) async {
  QueryResult res = await gql.rawMutation('''
mutation AddMember {
  addWorkspaceMember(email: "$email", startDate: "${formatForGQL(startDate)}", wsId: $workspaceId){
    ok
  }
}
  ''');

  return res;
}

Future<QueryResult> removeMember(String email, int workspaceId) async {
  QueryResult res = await gql.rawMutation('''
mutation RemoveMember {
  removeWorkspaceMember(email: "$email", wsId: $workspaceId){
    ok
  }
}
  ''');

  return res;
}

Future<QueryResult> fetchWorkspaceDates(int workspaceId) async {
  QueryResult res = await gql.rawQuery('''
query LoadWorkspaceDates {
  dates: workspaceDates(workspaceId: $workspaceId) {
    id,
    name,
    date,
    isOfficialHoliday
  }
}
  ''');

  return res;
}

Future<QueryResult> removeWorkspaceDate(int workspaceDateId) async {
  QueryResult res = await gql.rawMutation('''
mutation RemoveWorkspaceDate {
  removeWorkspaceDate(id: $workspaceDateId) {
    ok
  }
}
  ''');

  return res;
}

Future<QueryResult> addWorkspaceDate(
    int workspaceId, DateTime date, String name, bool isOfficialHoliday) async {
  QueryResult res = await gql.rawMutation('''
mutation AddWorkspaceDate {
  addWorkspaceDate(wsId: $workspaceId, date: "${formatForGQL(date)}", name: "$name", isOfficialHoliday: $isOfficialHoliday) {
    ok
  }
}
  ''');

  return res;
}
