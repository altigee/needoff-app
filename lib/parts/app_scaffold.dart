import 'package:flutter/material.dart';
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/app_state.dart';

class AppScaffold extends StatefulWidget {
  final String _title;
  final bool _banner;
  final Widget _body;
  final Widget _floatingActionButton;
  final Key _key;
  final List<Widget> tabs;
  final TabBar tabBar;
  AppScaffold(this._title,
      {bool banner = true,
      Widget body,
      Widget floatingActionButton,
      Key key,
      List<Widget> tabs,
      TabBar tabBar})
      : this._banner = banner,
        this._body = body,
        this._floatingActionButton = floatingActionButton,
        this._key = key != null ? key : GlobalKey<ScaffoldState>(),
        this.tabs = tabs,
        this.tabBar = tabBar;

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _wsSelected = true;

  _checkWorkspace() {
    storage.getWorkspace().then((wsId) {
      setState(() {
        _wsSelected = wsId != null;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _checkWorkspace();
    storage.changes.addListener(_checkWorkspace);
  }

  @override
  void dispose() {
    storage.changes.removeListener(_checkWorkspace);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
        key: widget._key,
        appBar: AppBar(
            title:
                Text(widget._title, style: TextStyle(fontFamily: 'Orbitron')),
            bottom: widget.tabBar),
        body: Container(
          child: Stack(
            children: <Widget>[
              if (widget._banner && !_wsSelected) NoWorkspaceBanner(),
              widget._body,
            ],
          ),
        ),
        floatingActionButton: widget._floatingActionButton);

    return scaffold;
  }
}

class NoWorkspaceBanner extends StatelessWidget {
  const NoWorkspaceBanner({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // key: appState.noWorkspaceBannerKey,
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Text('No workspace selected.',
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(letterSpacing: 2, fontWeight: FontWeight.w500)
                .apply(color: Colors.white)),
      ]),
      padding: EdgeInsets.all(8),
      color: Theme.of(context).accentColor,
    );
  }
}
