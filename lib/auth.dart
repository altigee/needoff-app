import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:needoff/api/http.dart' as http;
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/api/gql.dart' as gql;

class Auth {
  final _auth = {};

  get auth {
    return _auth;
  }

  Future signUp(String email, String pwd) async {
    try {
      QueryResult res = await gql.rawMutation('''
      mutation CreateAccount {
        register(email: "$email", password: "$pwd") {
          ok,
          response {
            id,
            email
          }
        }
      }
      ''');
      print(res);
      if (!res.hasErrors) {
        return signIn(email, pwd);
      } else {
        return null;
      }

    } catch (e) {
      print('![ERROR] Registration failed');
      rethrow;
    }
  }

  Future signIn(String email, String pwd) async {
    try {
      var data = await http.post(
        '/auth/login',
        headers: {
          'Content-Type': 'application/json',
        },
        body: {
          'email': email,
          'password': pwd,
        },
      );
      print(data.body);
      try {
        await storage.setToken(json.decode(data.body)['access_token']);
        return getProfile();
      } catch (e) {
        print('![ERROR] Set token failed!');
      }
    } catch (e) {
      print('**** error ****');
      print(e);
    }
  }

  Future getProfile() async {
    if (await storage.getToken() == null) {
      print('[GET PROFILE] : NO TOKEN');
      return null;
    }
    try{
      var p = await gql.rawQuery('''
query MyProfile{
  profile{ 
    firstName,
    lastName,
    email,
    position,
    phone
  }
  leaves: myLeaves(workspaceId: 1){
    startDate,
    endDate,
    leaveType,
  }
  workspaces: myWorkspaces {
    id,
    name,
    description,
  }
}
''');
      print(p);
      if (p.data == null || p.hasErrors) {
        throw Error();
      }
      return p.data;
    } catch(e) {
      print('FAIL GET PROFILE');
      storage.removeToken();
    }
  }
}
