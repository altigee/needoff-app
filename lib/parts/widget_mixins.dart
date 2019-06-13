import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

mixin LoadingState {
  Function setStateFn;
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool val) {
    if (setStateFn != null) {
      setStateFn(() {
        _loading = val;
      });
    } else {
      _loading = val;
    }
  }
}

mixin ScaffoldKey {
  var scaffKey = GlobalKey<ScaffoldState>();
}