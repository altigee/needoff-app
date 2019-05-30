import 'package:flutter/material.dart';
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/utils/ui.dart';

class WorkspaceProfileScreen extends StatefulWidget {
  @override
  _WorkspaceProfileScreenState createState() => _WorkspaceProfileScreenState();
}

class _WorkspaceProfileScreenState extends State<WorkspaceProfileScreen> {
  GlobalKey _scaffKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map args = ModalRoute.of(context).settings.arguments;
      int id;
      if (args != null && (id = Map.from(args)['id']) != null) {
        workspaceServ.fetchWorkspace(id).then((res) {
          if (res.hasErrors || res.data == null) {
            snack(_scaffKey.currentState, 'Failed to load workspace data.');
          } else {
            print(res.data);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'workspace',
      key: _scaffKey,
      body: Center(child: Text('workspace profile.'),),
    );
  }
}
