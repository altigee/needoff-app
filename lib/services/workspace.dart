import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/api/gql.dart' as gql;
import 'package:needoff/models/workspace.dart';
import 'package:needoff/utils/dates.dart';

Future create(Workspace ws) async {
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

Future fetch() async {
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

Future fetchWorkspace(int id) async {
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

Future fetchOwner(int workspaceId) async {
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

Future addMember(String email, DateTime startDate, int workspaceId) async {
  QueryResult res = await gql.rawMutation('''
mutation AddMember {
  addWorkspaceMember(email: "$email", startDate: "${formatForGQL(startDate)}", wsId: $workspaceId){
    ok
  }
}
  ''');

  return res;
}

Future removeMember(String email, int workspaceId) async {
  QueryResult res = await gql.rawMutation('''
mutation RemoveMember {
  removeWorkspaceMember(email: "$email", wsId: $workspaceId){
    ok
  }
}
  ''');

  return res;
}

Future fetchWorkspaceDates(int workspaceId) async {
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

Future removeWorkspaceDate(int workspaceDateId) async {
  QueryResult res = await gql.rawMutation('''
mutation RemoveWorkspaceDate {
  removeWorkspaceDate(id: $workspaceDateId) {
    ok
  }
}
  ''');

  return res;
}

Future addWorkspaceDate(int workspaceId, DateTime date, String name, bool isOfficialHoliday) async {
  QueryResult res = await gql.rawMutation('''
mutation AddWorkspaceDate {
  addWorkspaceDate(wsId: $workspaceId, date: "${formatForGQL(date)}", name: "$name", isOfficialHoliday: $isOfficialHoliday) {
    ok
  }
}
  ''');

  return res;
}
