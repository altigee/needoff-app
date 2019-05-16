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
    _profile = userData == null ? null : UserProfile(userData);
    notifyListeners();
  }

  Future fetchProfile() async {
    var data = await auth.getProfile();
    _profile = data == null ? null : UserProfile(data);
    return _profile;
  }

  addSickLeave(Leave sl) async {
    await _profile.addSickLeave(sl);
    fetchProfile();
  }
}
