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

  addSickLeave(Leave sl) async {
    this._profile.addSickLeave(sl);
    notifyListeners();
  }
}