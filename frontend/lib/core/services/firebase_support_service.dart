import 'package:flutter/foundation.dart';

class FirebaseSupportService {
  const FirebaseSupportService._();

  static bool get supportsMessaging {
    if (kIsWeb) return false;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.windows => false,
    };
  }
}
