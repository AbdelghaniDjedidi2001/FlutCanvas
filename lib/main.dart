import 'package:flutter/material.dart';

import 'package:flutcanvas/app/app.dart';
import 'package:flutcanvas/core/di/injection.dart';

export 'package:flutcanvas/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const WhiteboardApp());
}