import 'package:go_router/go_router.dart';
import 'package:soundsalike/features/recording/presentation/pages/recording_page.dart';

GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return RecordingPage(key: state.pageKey);
        },
      ),
    ],
  );
}
