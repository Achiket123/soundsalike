import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soundsalike/features/recording/presentation/pages/recording_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: RecordingPage.routePath,
    routes: [
      GoRoute(
        path: RecordingPage.routePath,
        builder: (context, state) => const RecordingPage(key: Key('recording_page')),
      ),
    ],
  );
}