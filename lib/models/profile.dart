class Profile {
  int _id;
  String _firstName;
  String _lastName;
  String _email;
  String _phone;
  String _position;
  DateTime _startDate;

  Profile(Map data) {
    if (data != null) {
      if (data != null) {
        if (data['id'] != null) {
          _id = int.parse(data['id']);
        } else if (data['userId'] != null) {
          _id = int.parse(data['userId']);
        }
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

  get id => _id;
  get name => '$_firstName $_lastName';
  get firstName => _firstName;
  get lastName => _lastName;
  get email => _email;
  get phone => _phone;
  get position => _position;
  get startDate => _startDate;
}
