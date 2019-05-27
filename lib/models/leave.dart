class Leave {
  String _type;
  DateTime _startDate;
  DateTime _endDate;
  String _comment;

  Leave(this._type, this._startDate, this._endDate, this._comment);

  String get type => _type;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String get comment => _comment;
}

class LeaveTypes {
  static const SICK_LEAVE = 'SICK_LEAVE';
  static const VACATION = 'VACATION_PAID';
  static const WFH = 'WFH';
  static const DAY_OFF = 'VACATION_UNPAID';
}