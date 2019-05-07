class UserProfile {
  String _name;
  String _email;
  String _phone;
  String _position;
  DateTime _startDate;
  Map<String, List<Leave>> _leaves = {};

  UserProfile(userData) {
    if (userData != null) {
      final profile = userData['profile'];
      Map leaves = userData['leaves'];
      if (profile != null) {
        _name = profile['name'];
        _email = profile['email'];
        _phone = profile['phone'];
        _position = profile['position'];
        _startDate =  DateTime.fromMillisecondsSinceEpoch(profile['start_date'].millisecondsSinceEpoch);
      }
      if (leaves != null) {
        for (var k in leaves.keys) {
          _leaves[k] = List.from(leaves[k].map((leave){
            return Leave(leave['start_date'], leave['end_date'], leave['comment']);
          }));
        }
      }
    }
    print(_name);
    print(_email);
  }

  get name => _name;
  get email => _email;
  get phone => _phone;
  get position => _position;
  get leaves => _leaves;
  get startDate => _startDate;

  addSickLeave(Leave sl) {
    if (sl != null) {
      this._leaves['sick_days'].add(sl);
    }
  }
}

class Leave {
  DateTime _startDate;
  DateTime _endDate;
  String _comment;

  Leave(this._startDate, this._endDate, this._comment);

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String get comment => _comment;
}
