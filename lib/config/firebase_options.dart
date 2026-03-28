import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final webAppId = EnvConfig.firebaseAppId;
    final String appId;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      appId = EnvConfig.firebaseIosAppId.isNotEmpty
          ? EnvConfig.firebaseIosAppId
          : webAppId.replaceFirst(':web:', ':ios:');
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      appId = EnvConfig.firebaseAndroidAppId.isNotEmpty
          ? EnvConfig.firebaseAndroidAppId
          : webAppId.replaceFirst(':web:', ':android:');
    } else {
      appId = webAppId;
    }

    return FirebaseOptions(
      apiKey: EnvConfig.firebaseApiKey,
      appId: appId,
      messagingSenderId: EnvConfig.firebaseMessagingSenderId,
      projectId: EnvConfig.firebaseProjectId,
      storageBucket: EnvConfig.firebaseStorageBucket,
    );
  }
}
