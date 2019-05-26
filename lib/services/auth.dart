import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:needoff/api/gql.dart' as gql;
import 'package:needoff/models/credentials.dart';

Future<QueryResult> signUp(Credentials creds) async {
  QueryResult res = await gql.rawMutation('''
mutation CreateAccount {
  register(email: "${creds.email}", password: "${creds.password}") {
    ok,
    response {
      id,
      email
    }
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
