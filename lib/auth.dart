import 'package:needoff/api/http.dart' as http;

class Auth {
  final _auth = {};

  get auth {
    return _auth;
  }

  Future signIn(String email, String pwd) async {
    var user;
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
    } catch (e) {
      print('**** error ****');
      print(e.message);
    }
    if (user == null || user.uid == null) {
      return null;
    }
    return await getUserData(user.uid);
  }

  Future getUserData(userId) async {
    var userData;

    if (userData.data == null || userData.data == null) {
      print('!!! USER NOT FOUND');
      return null;
    }

    print('***USER FOUND***');
    return userData.data;
  }
}
