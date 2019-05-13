import 'package:scoped_model/scoped_model.dart';
import 'models/user_model.dart';
import 'auth.dart';

Auth auth = Auth();

class AppStateModel extends Model {
  UserProfile _profile;

  get profile {
    return _profile;
  }

  set profile(userData) {
    if (userData == null) {
      _profile = null;
    } else {
      _profile = UserProfile(userData);
    }
    notifyListeners();
  }

  Future checkForUser() async {
    var data = await auth.getProfile();
    _profile = data == null ? null : UserProfile(data);
    return _profile;
  } 

  addSickLeave(Leave sl) async {
    _profile.addSickLeave(sl);
    notifyListeners();
  }
}