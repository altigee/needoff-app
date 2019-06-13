import 'package:flutter/material.dart';
import 'package:needoff/models/leave.dart' show LeaveTypes, LeaveTypeColors;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/parts/widget_mixins.dart';
import 'package:needoff/services/leaves.dart' as leavesServ;
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/utils/ui.dart';

class LeavesBalanceScreen extends StatefulWidget {
  @override
  _LeavesBalanceScreenState createState() => _LeavesBalanceScreenState();
}

class _LeavesBalanceScreenState extends State<LeavesBalanceScreen>
    with LoadingState, ScaffoldKey {
  int _wsId;
  Map _balance;
  void initState() {
    super.initState();
    setStateFn = setState;
    loadBalance();
  }

  loadBalance() async {
    loading = true;
    try {
      int _wsId = await storage.getWorkspace();
      if (_wsId != null) {
        var res = await leavesServ.fetchMyBalance(_wsId);
        if (res.hasErrors || res.data == null) {
          snack(scaffKey.currentState, 'Failed to load balances.');
        } else {
          _balance = res.data['balance'];
          print(_balance);
        }
      }
    } catch (e) {
      snack(scaffKey.currentState, 'Something went wrong :(');
    }

    loading = false;
  }

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
    Widget sick() => Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Sick days:',
                style: Theme.of(context).textTheme.headline,
              ),
              BalanceRemaining(
                type: LeaveTypes.SICK_LEAVE,
                total: _balance['totalSickLeaves'],
                left: _balance['leftSickLeaves'],
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
                      Navigator.of(context)
                          .pushNamed('/leaves/sick', arguments: {
                        'addLeave': true,
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
    Widget vacation() => Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Vacations:',
                style: Theme.of(context).textTheme.headline,
              ),
              BalanceRemaining(
                type: LeaveTypes.VACATION,
                total: _balance['totalPaidLeaves'],
                left: _balance['leftPaidLeaves'],
              ),
              _btnMore(onPressed: () {
                Navigator.of(context).pushNamed('/leaves/vac');
              }),
            ],
          ),
        );
    Widget wfh() => Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'WF*',
                style: Theme.of(context).textTheme.headline,
              ),
              Icon(
                Icons.all_inclusive,
                color: LeaveTypeColors[LeaveTypes.WFH],
                size: 32,
              ),
              _btnMore(onPressed: () {
                Navigator.of(context).pushNamed('/leaves/wfh');
              }),
            ],
          ),
        );
    return AppScaffold(
      'leaves',
      key: scaffKey,
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    sick(),
                    vacation(),
                    wfh(),
                  ],
                ),
              ),
            ),
    );
  }
}

class BalanceRemaining extends StatelessWidget {
  final String type;
  final int total;
  final int left;
  const BalanceRemaining({
    @required type,
    @required total,
    @required left,
    Key key,
  })  : this.type = type,
        this.total = total,
        this.left = left,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            width: 50,
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  'left',
                  style: Theme.of(context).textTheme.caption,
                ))),
        Text(
          '$left',
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: LeaveTypeColors[type]),
        ),
        Container(
            width: 50,
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  ' of $total',
                  style: Theme.of(context).textTheme.caption,
                )))
      ],
    );
  }
}
