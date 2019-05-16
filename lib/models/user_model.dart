import 'package:needoff/services/leaves.dart' as leavesService;

class UserProfile {
  String _firstName;
  String _lastName;
  String _email;
  String _phone;
  String _position;
  DateTime _startDate;
  Map<String, List<Leave>> _leaves = {'sick_days': []};

  UserProfile(userData) {
    if (userData != null) {
      final profile = userData['profile'];
      List leaves = userData['leaves'];
      if (profile != null) {
        _firstName = profile['firstName'];
        _lastName = profile['lastName'];
        _email = profile['email'];
        _phone = profile['phone'];
        _position = profile['position'];
        _startDate = profile['start_date'] != null
            ? DateTime.parse(profile['start_date'])
            : null;
      }
      if (leaves != null) {
        for (var item in leaves) {
          switch (item['leaveType']) {
            case 'LEAVE_SICK_LEAVE':
              _leaves['sick_days'].add(Leave(
                  DateTime.parse(item['startDate']),
                  DateTime.parse(item['endDate']),
                  item['comment']));
          }
        }
      }
    }
    print(_firstName);
    print(_email);
  }

  get name => '${_firstName} ${_lastName}';
  get email => _email;
  get phone => _phone;
  get position => _position;
  get leaves => _leaves;
  get startDate => _startDate;

  addSickLeave(Leave leave) async {
    if (leave != null) {
      var res =
          await leavesService.addSickLeave(leave.startDate, leave.endDate);
      print('!!!!!!!!!!');
      print(res);
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
