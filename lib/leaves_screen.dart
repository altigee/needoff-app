import 'package:flutter/material.dart';

class LeavesScreen extends StatefulWidget {
  @override
  _LeavesScreenState createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  Widget _btnMore({VoidCallback onPressed}) {
    return FlatButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'more',
            style: Theme.of(context)
                .textTheme
                .overline
                .apply(fontFamily: 'Orbitron'),
          ),
          Icon(
            Icons.arrow_forward,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[ BUILD ] :: LeavesScreen');
    Widget sick = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Sick days:',
            style: Theme.of(context).textTheme.headline,
          ),
          Text(
            '9',
            style: Theme.of(context)
                .textTheme
                .display1
                .copyWith(color: Theme.of(context).accentColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text(
                  'Sick today',
                  style: Theme.of(context)
                      .textTheme
                      .overline
                      .apply(fontFamily: 'Orbitron'),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/leaves/sick', arguments: {
                    'addSickToday': true,
                  });
                },
              ),
              _btnMore(onPressed: () {
                Navigator.of(context).pushNamed('/leaves/sick');
              }),
            ],
          )
        ],
      ),
    );
    Widget vacation = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Vacations:',
            style: Theme.of(context).textTheme.headline,
          ),
          Text(
            '12',
            style: Theme.of(context)
                .textTheme
                .display1
                .copyWith(color: Theme.of(context).accentColor),
          ),
          _btnMore(onPressed: () {
            Navigator.of(context).pushNamed('/leaves/vac');
          }),
        ],
      ),
    );
    Widget wfh = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'WFH',
            style: Theme.of(context).textTheme.headline,
          ),
          Icon(
            Icons.all_inclusive,
            color: Theme.of(context).accentColor,
            size: 32,
          ),
          _btnMore(onPressed: () {
            Navigator.of(context).pushNamed('/leaves/wfh');
          }),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('leaves', style: TextStyle(fontFamily: 'Orbitron')),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              sick,
              vacation,
              wfh,
            ],
          ),
        ),
      ),
    );
  }
}
