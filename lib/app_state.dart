import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/models/credentials.dart';

import 'package:needoff/models/profile.dart';
import 'package:needoff/models/leave.dart';
import 'package:needoff/models/workspace.dart';

import 'package:needoff/services/auth.dart' as authServ;
import 'package:needoff/services/leaves.dart' as leavesServ;
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/services/profile.dart' as profileServ;

import 'package:needoff/api/storage.dart' as storage;

class AppStateException implements Exception {
  String message;
  AppStateException(this.message);
}

class AppStateNotifier extends ChangeNotifier {
  notify() {
    notifyListeners();
  }
}

class AppState {
  AppStateNotifier _changes = AppStateNotifier();
  AppStateNotifier get changes => _changes;

  Profile _profile;
  List<Workspace> _workspaces = [];
  List<Leave> _leaves = [];

  Profile get profile => _profile;
  List<Workspace> get workspaces => _workspaces ?? [];
  List<Leave> get leaves => _leaves ?? [];

  set profile(Profile profile) {
    _profile = profile;
    _changes.notify();
  }

  set workspaces(List<Workspace> workspaces) {
    _workspaces = workspaces;
    _changes.notify();
  }

  set leaves(List<Leave> leaves) {
    _leaves = leaves;
    _changes.notify();
  }

  Future signin(Credentials creds) async {
    QueryResult res = await authServ.signIn(creds);
    if (!res.hasErrors &&
        res.data != null &&
        res.data['login']['accessToken'] != null) {
      storage.setToken(res.data['login']['accessToken']);
    } else {
      await storage.removeToken();
      throw AppStateException('Failed to login.');
    }

    return fetchProfile();
  }

  Future signup(Credentials creds) async {
    QueryResult res = await authServ.signUp(creds);
    if (!res.hasErrors &&
        res.data != null &&
        res.data['register']['accessToken'] != null) {
      storage.setToken(res.data['register']['accessToken']);
    } else {
      throw AppStateException('Failed to create account.');
    }

    return fetchProfile();
  }

  Future logout() async {
    storage.removeToken();
    storage.removeWorkspace();
    profile = null;
  }

  Future fetchProfile() async {
    QueryResult res = await profileServ.fetchProfile();
    if (!res.hasErrors && res.data != null) {
      profile = Profile(res.data['profile']);
    } else {
      profile = null;
      throw AppStateException('Failed to load profile.');
    }
  }

  Future fetchLeaves() async {
    int workspaceId = await storage.getWorkspace();
    QueryResult res = await leavesServ.fetch(workspaceId);
    if (!res.hasErrors && res.data != null) {
      if (res.data['leaves'] != null) {
        List<Leave> tmpLeaves = [];
        for (var item in res.data['leaves']) {
          tmpLeaves.add(Leave(
            item['leaveType'],
            DateTime.parse(item['startDate']),
            DateTime.parse(item['endDate']),
            item['comment'],
          ));
        }
        leaves = tmpLeaves;
      }
    } else {
      leaves = [];
      throw AppStateException('Failed to load leaves.');
    }
  }

  Future addLeave(Leave leave) async {
    QueryResult res = await leavesServ.create(await storage.getWorkspace(), leave);
    if (res.hasErrors) {
      throw AppStateException('Failed to add new leave.');
    }
    return fetchLeaves();
  }

  Future fetchWorkspaces() async {
    QueryResult res = await workspaceServ.fetch();
    if (!res.hasErrors && res.data != null) {
      if (res.data['workspaces'] != null) {
        List<Workspace> tmpWorkspaces = [];
        for (var item in res.data['workspaces']) {
          tmpWorkspaces.add(Workspace(
            item['name'],
            id: int.parse(item['id']),
            description: item['description'],
          ));
        }
        workspaces = tmpWorkspaces;
        int wsId = await storage.getWorkspace();
        if (wsId == null && workspaces.length == 1) {
          storage.setWorkspace(workspaces[0].id);
        } 
      }
    } else {
      workspaces = [];
      throw AppStateException('Failed to load workspaces.');
    }
  }

  Future addWorkspace(Workspace ws) async {
    QueryResult res = await workspaceServ.create(ws);
    if (res.hasErrors) {
      throw AppStateException('Failed to add workspace.');
    }

    return fetchWorkspaces();
  }
}

final appState = AppState();
