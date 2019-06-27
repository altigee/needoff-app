import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/api/gql.dart';
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
  List _listenersList = [];
  notify() {
    notifyListeners();
  }

  @override
  void addListener(listener) {
    _listenersList.add(listener);
    super.addListener(listener);
  }

  void removeAllListeners() {
    for (var listener in _listenersList) {
      super.removeListener(listener);
    }
  }
}

class AppState {
  AppStateNotifier _changes = AppStateNotifier();
  AppStateNotifier get changes => _changes;

  Profile _profile;
  List<Workspace> _workspaces = [];
  List<Leave> _leaves = [];
  List<Leave> _leavesForApproval = [];

  AppState() {
    invalidTokenNotifier.addListener(() {
      print('GQL ERROR : Invalid token : logout');
      logout();
    });
  }

  Profile get profile => _profile;
  List<Workspace> get workspaces => _workspaces ?? [];
  List<Leave> get leaves => _leaves ?? [];
  List<Leave> get leavesForApproval => _leavesForApproval ?? [];

  set profile(Profile profile) {
    _profile = profile;
    _changes.notify();
  }

  set workspaces(List<Workspace> workspaces) {
    _workspaces = workspaces;
    _changes.notify();
  }

  set leavesForApproval(List<Leave> leaves) {
    _leavesForApproval = leaves;
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

    return fetchProfile().then((res) => fetchWorkspaces());
  }

  Future signup(Credentials creds, {Map userData}) async {
    QueryResult res = await authServ.signUp(creds, userData: userData);
    if (!res.hasErrors &&
        res.data != null &&
        res.data['register']['accessToken'] != null) {
      storage.setToken(res.data['register']['accessToken']);
    } else {
      throw AppStateException('Failed to create account.');
    }

    return fetchProfile().then((res) => fetchWorkspaces());
  }

  Future logout() async {
    storage.removeToken();
    storage.removeWorkspace();
    profile = null;
    leaves = null;
    leavesForApproval = null;
    workspaces = null;
    _changes.removeAllListeners();
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
          tmpLeaves.add(Leave.fromJson(item));
        }
        leaves = tmpLeaves;
        return leaves;
      }
    } else {
      leaves = [];
      throw AppStateException('Failed to load leaves.');
    }
  }

  Future<bool> _isOwner() async {
    int workspaceId = await storage.getWorkspace();
    if (workspaceId == null) return false;
    var ownerRes = await workspaceServ.fetchOwner(workspaceId);
    int ownerId;
    if (ownerRes.hasErrors ||
        ownerRes.data == null ||
        ownerRes.data['owner'] == null ||
        (ownerId = int.tryParse(ownerRes.data['owner']['userId'])) == null)
      return false;

    return ownerId == appState.profile.id;
  }

  Future fetchLeavesForApproval() async {
    if (await _isOwner() == false) {
      leavesForApproval = [];
      return leavesForApproval;
    }
    int workspaceId = await storage.getWorkspace();
    QueryResult res = await leavesServ.fetchLeavesForApproval(workspaceId);
    if (!res.hasErrors && res.data != null) {
      if (res.data['leaves'] != null) {
        List<Leave> tmpLeaves = [];
        for (var item in res.data['leaves']) {
          tmpLeaves.add(Leave.fromJson(item));
        }
        leavesForApproval = tmpLeaves;
        print(res.data['leaves']);
        return leavesForApproval;
      }
    } else {
      leaves = [];
      throw AppStateException('Failed to load leaves.');
    }
  }

  Future addLeave(Leave leave) async {
    QueryResult res =
        await leavesServ.create(await storage.getWorkspace(), leave);
    if (res.hasErrors) {
      throw AppStateException('Failed to add new leave.');
    }
    await fetchLeaves();
    return res;
  }

  Future fetchTeamLeaves() async {
    int workspaceId = await storage.getWorkspace();
    QueryResult res = await leavesServ.fetchTeamLeaves(workspaceId);
    if (!res.hasErrors && res.data != null) {
      return (res.data['leaves'] ?? []).map((item) {
        return Leave.fromJson(item);
      }).toList();
    } else {
      throw AppStateException('Failed to load team calendar.');
    }
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
        int wsId = await storage.getWorkspace();
        if (wsId == null && tmpWorkspaces.length == 1) {
          storage.setWorkspace(tmpWorkspaces[0].id);
        }
        workspaces = tmpWorkspaces;
        return workspaces;
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

    await fetchWorkspaces();
    return res;
  }

  Future fetchTeamWorkspaceDates() async {
    int wsId = await storage.getWorkspace();
    if (wsId != null) {
      var wsDates = [];
      var holData = await workspaceServ.fetchWorkspaceDates(wsId);
      if (!holData.hasErrors && holData.data != null) {
        var dates = holData.data['dates'] ?? [];
        wsDates = dates.map((item) => WorkspaceDate.fromJson(item)).toList();
      }
      return wsDates;
    } else {
      throw AppStateException('Failed to load data, no workspace selected.');
    }
  }
}

final appState = AppState();
