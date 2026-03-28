import 'package:firebase_core/firebase_core.dart';
import 'env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    appId: EnvConfig.firebaseAppId,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
    authDomain: EnvConfig.firebaseAuthDomain,
    storageBucket: EnvConfig.firebaseStorageBucket,
  );
}
