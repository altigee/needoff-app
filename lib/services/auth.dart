import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:needoff/api/gql.dart' as gql;
import 'package:needoff/models/credentials.dart';

Future<QueryResult> signUp(Credentials creds, {Map userData}) async {
  var ud = '{firstName: "${userData['firstName']}", lastName: "${userData['lastName']}"}';
  QueryResult res = await gql.rawMutation('''
mutation CreateAccount {
  register(email: "${creds.email}", password: "${creds.password}", userData: $ud) {
    ok,
    userId,
    accessToken,
  }
}
  ''');
  return res;
}

Future<QueryResult> signIn(Credentials creds) async {
  QueryResult res = await gql.rawMutation('''
mutation Login {
  login(email: "${creds.email}", password: "${creds.password}") {
    ok,
    accessToken,
  }
}
  ''');
  return res;
}
Future<QueryResult> registerDeviceToken(String token) async {
  QueryResult res = await gql.rawMutation('''
mutation RegisterDeviceToken {
  saveUserDevice(token: "$token") {
    userId,
    token
  }
}
  ''');
  return res;
}
Future<QueryResult> removeDeviceToken(String token) async {
  QueryResult res = await gql.rawMutation('''
mutation RemoveDeviceToken {
  removeUserDevice(token: "$token") {
    userId,
    token
  }
}
  ''');
  return res;
}
