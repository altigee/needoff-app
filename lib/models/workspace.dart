import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'package:needoff/models/profile.dart' show Profile;

typedef WorkspaceUpdateCallback(
    {int id, String name, String description, Policy policy});
typedef WorkspaceInvitationAddCallback(
    {@required String email, @required int workspaceId});
typedef WorkspaceRemoveMemberCallback(
    {@required String email, @required int workspaceId});
typedef WorkspaceUpdateMemberCallback(
    {@required int memberId, @required int workspaceId, @required DateTime startDate});
typedef WorkspaceDateRemoveCallback(int id);

class Workspace {
  var _id;
  String _name;
  String _description;
  List _members;
  List<WorkspaceInvitation> _invitations;
  List<WorkspaceDate> _workspaceDates;
  Profile _owner;
  Workspace(this._name,
      {String description: '',
      int id,
      List members,
      List<WorkspaceInvitation> invitations,
      List<WorkspaceDate> workspaceDates,
      Profile owner})
      : this._description = description,
        this._id = id,
        this._members = members,
        this._invitations = invitations,
        this._workspaceDates = workspaceDates,
        this._owner = owner;
  Workspace.fromJson(Map data,
      {List invitations, List members, List workspaceDates, Map ownerData})
      : this._description = data['description'],
        this._id = int.parse(data['id']),
        this._name = data['name'],
        this._members = members.map((item) {
          return WorkspaceMember.fromJson(item);
        }).toList(),
        this._invitations = invitations.map((item) {
          return WorkspaceInvitation.fromJson(item);
        }).toList(),
        this._workspaceDates = workspaceDates.map((item) {
          return WorkspaceDate.fromJson(item);
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
  List<WorkspaceDate> get workspaceDates => _workspaceDates ?? [];
  Profile get owner => _owner;
}

class WorkspaceMember {
  int _userId;
  DateTime _startDate;
  Profile _profile;
  WorkspaceMember.fromJson(Map data)
      : this._userId = int.tryParse(data['userId']),
        this._startDate = DateTime.tryParse(data['startDate']),
        this._profile = Profile(data['profile']);
  
  int get userId => _userId;
  DateTime get startDate => _startDate;
  Profile get profile => _profile;
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

class WorkspaceDate {
  int _id;
  String _name;
  DateTime _date;
  bool isOfficialHoliday;

  WorkspaceDate(this._id, this._name, this._date,
      {this.isOfficialHoliday = true});
  WorkspaceDate.fromJson(Map data)
      : _id = int.parse(data['id']),
        _name = data['name'],
        _date = DateTime.parse(data['date']),
        isOfficialHoliday = data['isOfficialHoliday'] ?? true;

  int get id => _id;
  String get name => _name;
  DateTime get date => _date;
}

class Policy {
  int paidDays;
  int unpaidDays;
  int sickDays;
  Policy(this.paidDays, this.unpaidDays, this.sickDays);
}
