import 'package:flutter/material.dart';

void snack(source, String text) {
  var scaff;
  if (source is BuildContext) scaff = Scaffold.of(source);
  if (source is ScaffoldState) scaff = source;
  scaff
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
