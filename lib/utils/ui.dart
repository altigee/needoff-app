import 'package:flutter/material.dart';

void snack(source, String text, {Duration duration = const Duration(milliseconds: 1000)}) {
  var scaff;
  if (source is BuildContext) scaff = Scaffold.of(source);
  if (source is ScaffoldState) scaff = source;
  scaff
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), duration: duration,),
    );
}

Future openConfirmation(BuildContext ctx,
    {String title, String okLabel = 'ok', String cancelLable = 'cancel'}) {
  return showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? ''),
          actions: <Widget>[
            FlatButton(
              child: Text(
                cancelLable,
                style: TextStyle(
                    inherit: true, color: Theme.of(context).primaryColor),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text(
                okLabel,
                style: TextStyle(
                    inherit: true, color: Theme.of(context).accentColor),
              ),
              onPressed: () => Navigator.pop(context, {'ok': true}),
            )
          ],
        );
      });
}

Future<DateTime> openDatePicker(BuildContext ctx,
    {DateTime firstDate, DateTime lastDate, DateTime initialDate}) {
  return showDatePicker(
      context: ctx,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime(2020),
      initialDate: initialDate ?? DateTime.now());
}

Future openEditFormDialog(BuildContext ctx,
    {@required String dialogTitle,
    Widget form,
    Function onOk,
    Function onCancel}) {
  return showDialog(
      context: ctx,
      builder: (BuildContext context) {
        final Widget actions = ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: onCancel,
              ),
              FlatButton(
                child: Text('Ok'),
                onPressed: onOk,
              ),
            ],
          ),
        );

        return SimpleDialog(
          title: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                dialogTitle,
                style: Theme.of(context)
                    .textTheme
                    .title
                    .apply(color: Colors.white),
              ),
            ),
          ),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.fromLTRB(16, 32, 16, 0),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                height: 250,
                child: form,
              ),
            ),
            actions,
          ],
        );
      });
}
