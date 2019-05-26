class Profile {
  String _firstName;
  String _lastName;
  String _email;
  String _phone;
  String _position;
  DateTime _startDate;

  Profile(data) {
    if (data != null) {
      if (data != null) {
        _firstName = data['firstName'];
        _lastName = data['lastName'];
        _email = data['email'];
        _phone = data['phone'];
        _position = data['position'];
        _startDate = data['start_date'] != null
            ? DateTime.parse(data['start_date'])
            : null;
      }
    }
  }

  get name => '$_firstName $_lastName';
  get email => _email;
  get phone => _phone;
  get position => _position;
  get startDate => _startDate;
}
