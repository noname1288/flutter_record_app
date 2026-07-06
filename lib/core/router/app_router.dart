import 'package:go_router/go_router.dart';
import 'package:record_app/features/record-detail/presentation/detail_record_page.dart';
import 'package:record_app/features/record-list/presentation/list_record_page.dart';

class AppRouter {
  AppRouter._();

  static const String recordListPath = '/record-list';
  static const String recordDetailPath = '/record-detail';

  static final GoRouter router = GoRouter(
    initialLocation: recordListPath,
    routes: [
      GoRoute(
        path: recordListPath,
        builder: (context, state) => ListRecordPage(),
      ),
      GoRoute(
        path: recordDetailPath,
        builder: (context, state) => DetailRecordPage(),
      ),
    ],
  );
}
