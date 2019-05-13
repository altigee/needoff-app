import 'dart:convert';
import 'package:needoff/api/http.dart' as http;
import 'package:needoff/api/storage.dart' as storage;

class Auth {
  final _auth = {};

  get auth {
    return _auth;
  }

  Future signIn(String email, String pwd) async {
    try {
      var data = await http.post(
        '/auth/login',
        headers: {
          'Content-Type': 'application/json',
        },
        body: {
          'username': email,
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
      print(e.message);
    }
  }

  Future getProfile() async {
    if (await storage.getToken() == null) {
      print('[GET PROFILE] : NO TOKEN');
      return null;
    }
    return { 'profile': {
      "email": "nmarchuk@altigee.com",
      "name": "Nazar Marchuk",
      "phone": "+380991110099",
      "position": "UI developer",
      "start_date":"2017-02-27",
    }, 'leaves': {
      'sick_days': [
        {
          'comment': 'Feel bad (',
          'start_date': '2017-05-05',
          'end_date': '2017-05-05',
        }
      ],
    }};
    // return http.get('/profile');
  }
}
