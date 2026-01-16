import 'package:fquery_core/fquery_core.dart';

final queryCache = QueryCache(
  defaultQueryOptions: DefaultQueryOptions(
    cacheDuration: const Duration(minutes: 5),
    staleDuration: const Duration(seconds: 30),
  ),
);
