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
  calendars: workspaceCalendars(workspaceId: $id) {
    id,
    name,
    wsId
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

Future createCalendar(String name, int workspaceId) async {
  QueryResult res = await gql.rawMutation('''
mutation CreateCalendar {
  createWorkspaceCalendar(name: "$name", wsId: $workspaceId) {
    ok
  }
}
  ''');

  return res;
}

Future removeCalendar(int calendarId) async {
  QueryResult res = await gql.rawMutation('''
mutation RemoveCalendar {
  removeWorkspaceCalendar(id: $calendarId) {
    ok
  }
}
  ''');

  return res;
}
