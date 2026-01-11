import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    enabled: !kReleaseMode,
    useConsoleLogs: true,
    useHistory: true,
  ),
);
