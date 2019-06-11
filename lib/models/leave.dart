import 'package:flutter/material.dart';

class Leave {
  String _type;
  DateTime _startDate;
  DateTime _endDate;
  String _comment;
  Map _userData;

  Leave(this._type, this._startDate, this._endDate, this._comment, { Map userData }) : this._userData = userData;

  Leave.fromJson(Map data)
    : this._type = data['leaveType'],
      this._startDate = DateTime.parse(data['startDate']),
      this._endDate = DateTime.parse(data['endDate']),
      this._comment = data['comment'],
      this._userData = data['user'] ?? data['userData'];

  String get type => _type;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String get comment => _comment;
  Map get userData => _userData;
}

class LeaveTypes {
  static const SICK_LEAVE = 'SICK_LEAVE';
  static const VACATION = 'VACATION_PAID';
  static const WFH = 'WFH';
  static const DAY_OFF = 'VACATION_UNPAID';
}

const LeaveTypeLabels = {
  LeaveTypes.SICK_LEAVE: 'Sick leave',
  LeaveTypes.VACATION: 'Vacation',
  LeaveTypes.DAY_OFF: 'Day Off',
  LeaveTypes.WFH: 'WFH',
};
const LeaveTypeColors = {
  LeaveTypes.SICK_LEAVE: Colors.red,
  LeaveTypes.VACATION: Colors.green,
  LeaveTypes.DAY_OFF: Colors.blue,
  LeaveTypes.WFH: Colors.purple
};