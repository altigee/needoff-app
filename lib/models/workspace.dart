import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:needoff/models/profile.dart' show Profile;

typedef WorkspaceUpdateCallback({int id, String name, String description});
typedef WorkspaceInvitationAddCallback(
    {@required String email, @required int workspaceId});
typedef WorkspaceInvitationRemoveCallback(
    {@required String email, @required int workspaceId});
typedef WorkspaceCalendarAddCallback(
    {@required String name, @required int workspaceId});
typedef WorkspaceCalendarRemoveCallback(int id);

class Workspace {
  var _id;
  String _name;
  String _description;
  List _members;
  List<WorkspaceInvitation> _invitations;
  List<Calendar> _calendars;
  Profile _owner;
  Workspace(this._name,
      {String description: '',
      int id,
      List members,
      List<WorkspaceInvitation> invitations,
      List<Calendar> calendars,
      Profile owner})
      : this._description = description,
        this._id = id,
        this._members = members,
        this._invitations = invitations,
        this._calendars = calendars,
        this._owner = owner;
  Workspace.fromJson(Map data,
      {List invitations, Map ownerData, List calendars})
      : this._description = data['description'],
        this._id = int.parse(data['id']),
        this._name = data['name'],
        this._invitations = invitations.map((item) {
          return WorkspaceInvitation.fromJson(item);
        }).toList(),
        this._calendars = calendars.map((item) {
          return Calendar.fromJson(item);
        }).toList(),
        this._owner = Profile(ownerData);

  set invitations(List<WorkspaceInvitation> invitations) {
    _invitations = invitations;
  }

  get id => _id;
  String get name => _name;
  String get description => _description;
  List get members => _members ?? [];
  List<WorkspaceInvitation> get invitations => _invitations ?? [];
  List<Calendar> get calendars => _calendars ?? [];
  Profile get owner => _owner;
}

class WorkspaceInvitation {
  int _id;
  String _email;
  String _status;
  WorkspaceInvitation(this._id, this._email, this._status);
  WorkspaceInvitation.fromJson(Map data)
      : _id = int.parse(data['id']),
        _email = data['email'],
        _status = data['status'];
  int get id => _id;
  String get email => _email;
  String get status => _status;
}

class WorkspaceInvitationStatus {
  static const PENDING = 'PENDING';
  static const ACCEPTED = 'ACCEPTED';
  static const REVOKED = 'REVOKED';
}

class Calendar {
  int _id;
  String _name;
  int _workspaceId;
  Calendar(this._id, this._name);
  Calendar.fromJson(Map data)
      : _id = int.parse(data['id']),
        _name = data['name'],
        _workspaceId = data['wsId'] ?? data['workspaceId'];
  int get id => _id;
  String get name => _name;
  int get workspaceId => _workspaceId;

  static final colors = [
    Colors.orange,
    Colors.teal,
    Colors.pink[200],
    Colors.cyanAccent,
    Colors.indigo,
    Colors.lime
  ];
}

class Holiday {
  int _id;
  String _name;
  int _calendarId;
  DateTime _date;

  Holiday(this._id, this._name, this._calendarId, this._date);
  Holiday.fromJson(Map data)
    : _id = int.parse(data['id']),
      _name = data['name'],
      _calendarId = data['calendarId'],
      _date = DateTime.parse(data['date']);

  int get id => _id;
  int get calendarId => _calendarId;
  String get name => _name;
  DateTime get date => _date;
}
