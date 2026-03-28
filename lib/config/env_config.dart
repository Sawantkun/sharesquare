import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get firebaseApiKey => dotenv.env['NEXT_PUBLIC_FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId => dotenv.env['NEXT_PUBLIC_FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['NEXT_PUBLIC_FIREBASE_APP_ID'] ?? '';
  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get openRouterModel => dotenv.env['OPENROUTER_MODEL'] ?? 'stepfun/step-3.5-flash:free';
}
