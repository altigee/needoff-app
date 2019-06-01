import 'package:meta/meta.dart';

import 'package:needoff/models/profile.dart' show Profile;

typedef WorkspaceUpdateCallback({int id, String name, String description});
typedef WorkspaceInvitationAddCallback({@required String email, @required int workspaceId});
typedef WorkspaceInvitationRemoveCallback({@required int invitationId, @required int workspaceId});

class Workspace {
  var _id;
  String _name;
  String _description;
  List _members;
  List<WorkspaceInvitation> _invitations;
  Profile _owner;
  Workspace(this._name,
      {String description: '',
      int id,
      List members,
      List<WorkspaceInvitation> invitations,
      Profile owner})
      : this._description = description,
        this._id = id,
        this._members = members,
        this._invitations = invitations,
        this._owner = owner;
  Workspace.fromJson(Map data, List invitations, Map ownerData)
      : this._description = data['description'],
        this._id = int.parse(data['id']),
        this._name = data['name'],
        this._invitations = invitations.map((item) {
          return WorkspaceInvitation.fromJson(item);
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