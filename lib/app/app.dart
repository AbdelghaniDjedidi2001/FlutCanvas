import 'package:flutter/material.dart';

import 'package:flutcanvas/app/providers/app_bloc_providers.dart';
import 'package:flutcanvas/app/view/app_view.dart';

/// Root application widget for FlutCanvas.
class WhiteboardApp extends StatelessWidget {
  const WhiteboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppBlocProviders(
      child: AppView(),
    );
  }
}
